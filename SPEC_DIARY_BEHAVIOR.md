# Diary + Behavior Profile Feature Specification

**Date:** 2026-08-22
**Status:** ✅ Specification Complete (Ready for Implementation)
**Phase:** Phase 1 (Backend + Manual Diary MVP)

---

## 1. Overview

MiAjudAI will track user behavior and diary entries to enrich agent personalization. Users explicitly write diary entries (happy/sad/neutral mood, categorized tags). The app implicitly tracks screen navigation and interactions. Only diary entries are exposed to LLM agents; behavioral data is stored for future analytics.

### Goals
- Enable Luna, Otto, and Tina to understand user context deeply
- Build a data foundation for future personalization features
- Respect user privacy with explicit opt-in

---

## 2. Data Model

### Storage
- **Database:** PostgreSQL (Supabase cloud)
- **Retention:** 30 days raw data, on-demand aggregation for older patterns
- **Deletion:** Raw entries deleted after 30 days; aggregates kept for trend analysis

### Tables

#### `diary_entries`
```sql
CREATE TABLE diary_entries (
  id SERIAL PRIMARY KEY,
  user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  text TEXT NOT NULL,
  mood VARCHAR(50) NOT NULL CHECK (mood IN ('happy', 'sad', 'neutral')),
  tags VARCHAR(50)[] DEFAULT '{}', -- finance, food, domestic, calendar
  emotion_score INTEGER NOT NULL, -- auto-derived: happy=80, sad=20, neutral=50
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_diary_user_date ON diary_entries(user_id, created_at DESC);
CREATE INDEX idx_diary_tags ON diary_entries USING GIN(tags);
```

#### `screen_events`
```sql
CREATE TABLE screen_events (
  id SERIAL PRIMARY KEY,
  user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  screen_name VARCHAR(100) NOT NULL,
  dwell_time_seconds INTEGER,
  source_screen VARCHAR(100),
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_screen_user_date ON screen_events(user_id, created_at DESC);
CREATE INDEX idx_screen_name ON screen_events(screen_name);
```

#### `interaction_events`
```sql
CREATE TABLE interaction_events (
  id SERIAL PRIMARY KEY,
  user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  interaction_type VARCHAR(100) NOT NULL,
  screen_name VARCHAR(100),
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_interaction_user_date ON interaction_events(user_id, created_at DESC);
CREATE INDEX idx_interaction_type ON interaction_events(interaction_type);
```

---

## 3. Frontend - EventsService (Flutter)

### Purpose
Single service handling all event tracking and batching. Initialized after user login.

### Features

#### Initialization
- Start after `AuthProvider` successfully authenticates user
- Check opt-in permission; if opted out, disable all tracking
- Schedule smart daily diary reminder (local notification, 8pm default)

#### Event Batching
- Buffer events in memory (diary, screen, interaction)
- Batch sending: **every 5 minutes OR when user leaves a screen** (whichever first)
- Hard limit: max 100 events per batch request
- Failed batches retry 3x with exponential backoff, then discard

#### Event Types

**Diary Entry:**
```dart
{
  "type": "diary",
  "text": "User's journal text",
  "mood": "happy|sad|neutral",
  "tags": ["finance", "food", "domestic", "calendar"] // optional, multi-select
}
```

**Screen Event:**
```dart
{
  "type": "screen",
  "screen_name": "/accounts or /calendar or /chat, etc",
  "dwell_time_seconds": 120,
  "source_screen": "previous screen name"
}
```

**Interaction Event:**
```dart
{
  "type": "interaction",
  "interaction_type": "clicked_add_income|submitted_chat|etc",
  "screen_name": "current screen"
}
```

### API Integration
- Sends to `POST /api/user-activity` (single endpoint)
- Respects opt-in permission; checks daily before showing reminder

---

## 4. Frontend - DiaryScreen (Flutter)

### Design
- Clean, minimal journal aesthetic (whitespace, soft shadows)
- Calendar view with note blocks
- Tap date to view/edit entry for that day

### UI Flow
1. User taps date on calendar
2. Show entry form with:
   - Text input (multiline, ~200 chars suggested)
   - Mood selector (buttons: happy | sad | neutral)
   - Category tags (checkboxes: finance, food, domestic, calendar)
3. On save: Send diary entry via EventsService

### Smart Daily Reminder
- Check on app launch if user has diary entry for today
- If not, schedule local notification at 8pm: "How was your day? 📖"
- Only one reminder per day
- User can customize reminder time in settings (not in MVP)

---

## 5. Backend - User Activity Endpoint

### Endpoint
```
POST /api/user-activity
Authorization: Bearer <jwt_token>
Content-Type: application/json

{
  "events": [
    { "type": "diary", "text": "...", "mood": "happy", "tags": ["finance"] },
    { "type": "screen", "screen_name": "/accounts", "dwell_time_seconds": 120, "source_screen": "/home" },
    { "type": "interaction", "interaction_type": "clicked_add_income", "screen_name": "/income" }
  ]
}
```

### Response
```json
{
  "success": true,
  "events_stored": 3,
  "timestamp": "2026-08-22T14:30:00Z"
}
```

### Validation (Strict)

**All events:**
- `user_id` from JWT token (not from client)
- `type` must be one of: "diary", "screen", "interaction"
- `created_at` set by server (not client)
- Reject batch if > 100 events

**Diary events:**
- `text` required, non-empty
- `mood` must be: happy, sad, neutral
- `tags` must be subset of: finance, food, domestic, calendar
- Emotion score auto-derived: happy=80, sad=20, neutral=50

**Screen events:**
- `screen_name` required (validate against known screens)
- `dwell_time_seconds` must be integer ≥ 0

**Interaction events:**
- `interaction_type` required
- `screen_name` optional

### Implementation
- Single `UserActivityController` that routes by event type
- All events validated before insertion
- Log validation errors (don't expose to client)

---

## 6. Agent Integration - user_profile_prompt

### Context Building

When user sends message to Luna/Otto/Tina, backend builds `user_profile_prompt`:

#### Query Pattern
```javascript
// Separate queries (not JOIN)
const recent7d = await diaryEntries.findAll({
  where: {
    user_id: userId,
    tags: { contains: agentRelevantTag }, // Luna: 'finance', Otto: 'food', Tina: 'domestic'
    created_at: { gte: 7.days.ago() }
  },
  order: [['created_at', 'DESC']]
});

const older30d = await buildAggregate(userId, agentRelevantTag, 7.daysAgo(), 30.daysAgo());
```

#### Prompt Format (Freeform Narrative)

```
Recent diary context:
- 2 days ago (sad): "Stressed about rent payment" [finance]
- 4 days ago (neutral): "Planning grocery shopping" [food]
- 1 week ago (happy): "Got a raise!" [finance]

Mood trend: User has been more anxious about finances lately. Kitchen planning is calm.
```

#### Context Scoping

| Agent | Relevant Tags | Context |
|-------|---------------|---------|
| **Luna** | finance | Diary entries tagged "finance" + older patterns |
| **Otto** | food | Diary entries tagged "food" + older patterns |
| **Tina** | domestic | Diary entries tagged "domestic" + older patterns |

#### Size Limit
- Hard cap: 1000 characters
- Truncation priority: Recent entries first, then agent-relevant tags, then older data
- Never drop agent-relevant data for unrelated entries

#### NOT Included
- Screen events (stored for future analytics, not for LLM)
- Interaction events (too noisy)
- Raw event logs

### Agent Behavior

Agents may proactively reference diary context when relevant:
- Luna: "I see you were stressed about finances 2 days ago — let's make a plan"
- Otto: "You mentioned planning groceries; let me suggest recipes"
- Tina: "Domestic tasks on your mind — let's organize a schedule"

---

## 7. Opt-in & Privacy

### Opt-in Flow
- On first app launch, show modal: "MiAjudAI learns from your behavior to personalize recommendations. Allow tracking?"
- User must tap "Allow" or "Not Now"
- Store permission in user profile
- Respect permission on future launches

### Data Deletion
- After 30 days, raw `diary_entries`, `screen_events`, `interaction_events` are deleted
- Aggregates (mood trends, patterns) may be kept longer for analytics
- Users can request full data deletion (future feature)

---

## 8. Database Migrations

### Migration Strategy
- Use Sequelize migrations (for now; review after Supabase sync)
- Create migration file: `migrations/YYYYMMDD-create-diary-and-behavior-tables.js`
- Defines all three tables with indexes
- Reversible in case of rollback

### Post-Supabase
- After migration to Supabase (Task #1), reassess if Sequelize or Supabase migrations are better

---

## 9. Implementation Phases

### Phase 1 (MVP - Backend First)
- ✅ Supabase PostgreSQL setup (Task #1)
- Database schema (3 tables + indexes)
- Backend endpoint `/api/user-activity` with validation
- Build `user_profile_prompt` context builder
- Test with Luna (curl/Postman manual testing)
- DiaryScreen UI (calendar + form)
- EventsService (batch events)
- Opt-in modal

### Phase 2 (Enhanced)
- Auto-summarization job (daily mood/pattern summaries)
- Unit + integration tests
- Otto & Tina integration (food, domestic diary)
- Export diary entries feature
- Mood charts / trend visualization

---

## 10. Example Workflows

### User Writes Diary Entry
```
1. User opens app → EventsService initializes
2. User taps calendar → DiaryScreen opens
3. User selects date, writes "Paid bills today, relieved" → mood: happy, tag: finance
4. User taps Save → EventsService buffers event
5. EventsService flushes at 5-min mark → POST /api/user-activity
6. Backend validates, stores in diary_entries table
```

### Luna Uses Diary Context
```
1. User: "What should I save this month?"
2. Backend builds user_profile_prompt:
   - Query: diary entries tagged "finance" from last 7 days
   - Format: "Recent diary: 2 days ago you felt relieved after paying bills"
3. Luna sees context, responds: "Great, you're keeping up with bills! Let's build on that momentum..."
```

### Smart Reminder
```
1. App launches at 7pm → EventsService checks: "Did user write diary today?"
2. No diary entry → Schedule local notification at 8pm
3. 8pm → Notification: "How was your day? 📖"
4. User dismisses or taps → Opens DiaryScreen
```

---

## 11. Risk Mitigations

| Risk | Mitigation |
|------|-----------|
| Storage bloat (30d raw data) | Automatic deletion after 30d; monitor disk usage |
| LLM token costs | Hard 1000-char limit on user_profile_prompt |
| Privacy concerns | Explicit opt-in, clear communication, deletion after 30d |
| Behavioral data misuse | Behavioral events NOT sent to LLM (only diary) |
| Failed event uploads | 3x retry with backoff, then graceful discard |

---

## 12. Testing Strategy (Phase 2)

- **Unit:** Event validation, emotion score derivation, context truncation
- **Integration:** Event upload → storage → agent query
- **Manual:** curl/Postman with fake events, observe Luna responses

---

## 13. Success Criteria

### MVP Complete (Phase 1)
- [ ] Supabase PostgreSQL synced
- [ ] 3 tables + indexes created
- [ ] `/api/user-activity` endpoint validates and stores events
- [ ] Luna uses diary context in responses (manual testing)
- [ ] DiaryScreen works (user can write entries)
- [ ] EventsService batches screen/interaction events
- [ ] Opt-in modal shows on app launch
- [ ] Smart daily reminder schedules correctly

### Phase 2 Complete
- [ ] Auto-summarization job runs daily
- [ ] Unit + integration tests pass
- [ ] Otto & Tina use diary context
- [ ] Mood trends visible to user

---

## 14. References

### Related Tasks
- Task #1: Migrate PostgreSQL to Supabase cloud
- Task #2: Implement auto-summarization job
- Task #3: Build user_profile_prompt from diary tables
- Task #4: Add opt-in permission modal
- Task #5: Create EventsService (Flutter)
- Task #6: Create DiaryScreen UI
- Task #7: Define mood tags (happy, sad, neutral)
- Task #8: Define category tags (finance, food, domestic, calendar)
- Task #9: Implement smart daily reminder
- Task #10: Review migration strategy (post-Supabase)
- Task #11: Add unit + integration tests (Phase 2)
- Task #12: Clarify diary-only in user_profile_prompt

### Existing Code
- `backend/src/services/chatService.js` — Luna integration point
- `backend/src/models/UserContext.js` — Existing persona structure
- `frontend/lib/screens/chat/financial_chat_screen.dart` — Chat UI reference

---

**Document prepared by:** Claude Code
**Last updated:** 2026-08-22
