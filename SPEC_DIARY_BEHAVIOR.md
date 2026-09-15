# Diary + Behavior Profile Feature Specification

**Date:** 2026-08-22
**Last Updated:** 2026-08-24
**Status:** ✅ MVP Specification Finalized (Diary-Only Testing)
**Current Implementation:** Phase 1 MVP (DiaryScreen + POST /api/user-activity)
**Scope:** Manual diary writes to PostgreSQL (no batching, no screen tracking, no reminders)

---

## 1. Overview

MiAjudAI will track user behavior and diary entries to enrich agent personalization. Users explicitly write diary entries (happy/sad/neutral mood, categorized tags). The app implicitly tracks screen navigation and interactions. Only diary entries are exposed to LLM agents; behavioral data is stored for future analytics.

### Goals
- Enable Luna, Otto, and Tina to understand user context deeply
- Build a data foundation for future personalization features
- Respect user privacy with explicit opt-in

---

## 2. Data Model
**✅ STATUS: DONE — Tables migrated to backend/run-migration.js**

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

## 3. Frontend - Diary Service (Flutter)

### ✅ MVP Implementation (Current)

**Scope:** Direct POST on diary save (no batching, no screen tracking, no events buffering)

#### DiaryService
```dart
Future<void> saveDiaryEntry(DiaryEntry entry) async {
  final response = await apiService.post(
    '/api/user-activity',
    body: {
      'events': [{
        'type': 'diary',
        'text': entry.text,
        'mood': entry.mood,
        'tags': entry.tags,
      }]
    },
  );
  // Immediate response (success/error)
}
```

#### Event Format
```dart
{
  "type": "diary",
  "text": "User's journal text",
  "mood": "happy|sad|neutral",
  "tags": ["finance", "food", "domestic", "calendar"] // optional, multi-select
}
```

---

### TODO upgrade: Full EventsService (Phase 2)

> ⏸️ DEFERRED — Implement after MVP testing confirms diary persistence

#### Planned Features
- **Event Batching:** Buffer events in memory (diary, screen, interaction)
  - Batch sending: **every 5 minutes OR when user leaves a screen** (whichever first)
  - Hard limit: max 100 events per batch request
  - Failed batches retry 3x with exponential backoff, then discard
- **Screen Event Tracking:**
  ```dart
  {
    "type": "screen",
    "screen_name": "/accounts or /calendar or /chat, etc",
    "dwell_time_seconds": 120,
    "source_screen": "previous screen name"
  }
  ```
- **Interaction Event Tracking:**
  ```dart
  {
    "type": "interaction",
    "interaction_type": "clicked_add_income|submitted_chat|etc",
    "screen_name": "current screen"
  }
  ```
- **Initialization:** Start after `AuthProvider` successfully authenticates user
- **Opt-in Check:** Verify permission before tracking (see section 7)

**When to implement:** After confirming diary entries persist and sync correctly with database

---

## 4. Frontend - DiaryScreen (Flutter)

### ✅ MVP Implementation (Current)

#### Design
- Clean, minimal journal aesthetic (whitespace, soft shadows)
- Calendar view with note blocks
- Tap date to view/edit entry for that day

#### UI Flow
1. User taps date on calendar
2. Show entry form with:
   - Text input (multiline, ~200 chars suggested)
   - Mood selector (buttons: happy | sad | neutral)
   - Category tags (checkboxes: finance, food, domestic, calendar)
3. On save: Direct POST to `/api/user-activity`
4. Show success/error toast

---

### TODO upgrade: Smart Daily Reminder (Phase 2)

> ⏸️ DEFERRED — Implement after testing confirms diary persistence

#### Planned Features
- Check on app launch if user has diary entry for today
- If not, schedule local notification at 8pm: "How was your day? 📖"
- Only one reminder per day
- User can customize reminder time in settings (Phase 3)

**When to implement:** After Phase 2 completes EventsService initialization

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

### ✅ MVP Status
**No opt-in required for MVP** — Testing assumes user consent. Diary tracking is enabled by default.

---

### TODO upgrade: Opt-in Modal (Phase 2)

> ⏸️ DEFERRED — Implement after core diary persistence works

#### Planned Flow
- On first app launch, show modal: "MiAjudAI learns from your behavior to personalize recommendations. Allow tracking?"
- User must tap "Allow" or "Not Now"
- Store permission in user profile
- Respect permission on future launches
- If opted out: disable all event collection (screen, interaction, diary)

#### Data Deletion Policy
- After 30 days, raw `diary_entries`, `screen_events`, `interaction_events` are deleted
- Aggregates (mood trends, patterns) may be kept longer for analytics
- Users can request full data deletion (Phase 3)

**When to implement:** After MVP testing confirms user wants to see consent flow

---

## 8. Database Migrations
**✅ STATUS: DONE — All migrations implemented in backend/run-migration.js**

### Migration Strategy
- Use Sequelize migrations (for now; review after Supabase sync)
- Create migration file: `migrations/YYYYMMDD-create-diary-and-behavior-tables.js`
- Defines all three tables with indexes
- Reversible in case of rollback

### Post-Supabase
- After migration to Supabase (Task #1), reassess if Sequelize or Supabase migrations are better

---

## 9. Implementation Phases

### Phase 1 MVP (Current) - Diary-Only Testing
**Goal:** Verify diary entries save to PostgreSQL via DiaryScreen

✅ **Implemented:**
- ✅ Database schema (`diary_entries` table + indexes)
- ✅ Backend endpoint `POST /api/user-activity` with strict validation
- ✅ DiaryScreen UI (calendar + form)
- ✅ DiaryService (direct POST on save, no batching)
- ✅ Integration with Luna (context builder reads diary_entries)

🎯 **Test Checklist:**
- [ ] Start backend: `npm run dev`
- [ ] Start frontend: `flutter run`
- [ ] Login with test account
- [ ] Open Diary screen
- [ ] Write entry + select mood/tags
- [ ] Tap Save → verify success toast
- [ ] Check database: `SELECT * FROM diary_entries ORDER BY created_at DESC LIMIT 1;`
- [ ] Chat with Luna → verify diary context appears in response

---

### TODO upgrade: Phase 2 (EventsService + Screen Tracking)

> ⏸️ AFTER MVP testing confirms diary persistence

**Tasks:**
- EventsService with event batching (5min flush + screen-leave trigger)
- Screen event tracking + dwell time
- Interaction event tracking
- Opt-in permission modal
- Smart daily reminder notifications
- Unit + integration tests

---

### TODO upgrade: Phase 3 (Otto & Tina + Auto-Aggregation)

> ⏸️ AFTER Phase 2 completes screen/interaction tracking

**Tasks:**
- Auto-summarization job (daily mood/pattern summaries)
- Otto integration (food tag context)
- Tina integration (domestic tag context)
- Mood trend visualization
- Export diary entries feature

---

## 10. Example Workflows

### ✅ MVP: User Writes Diary Entry
```
1. User opens app → Logs in
2. User navigates to Diary screen
3. User taps date on calendar
4. User writes "Paid bills today, relieved" → mood: happy, tag: finance
5. User taps Save button
6. DiaryService POSTs to /api/user-activity
7. Backend validates, stores in diary_entries table
8. Success toast shown to user
```

**Test this first.**

---

### TODO upgrade: Luna Uses Diary Context (Phase 2+)

> ⏸️ AFTER confirming diary persistence works

```
1. User: "What should I save this month?"
2. Backend builds user_profile_prompt:
   - Query: diary entries tagged "finance" from last 7 days
   - Format: "Recent diary: 2 days ago you felt relieved after paying bills"
3. Luna sees context, responds: "Great, you're keeping up with bills! Let's build on that momentum..."
```

---

### TODO upgrade: Smart Reminder (Phase 2+)

> ⏸️ DEFERRED — Implement after EventsService initialization

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

### ✅ MVP Complete (Current Phase)
- [x] PostgreSQL setup with diary schema
- [x] `diary_entries` table created + indexed
- [x] `/api/user-activity` endpoint validates and stores **diary events only**
- [x] DiaryScreen works (user can write entries via calendar UI)
- [x] DiaryService posts directly to backend on save
- [ ] **Test:** Entry appears in database within 2s after save
- [ ] **Test:** Luna receives diary context in next message

---

### TODO upgrade: Phase 2 Complete

- [ ] EventsService batches screen/interaction events (5min + screen-leave)
- [ ] Opt-in permission modal on first launch
- [ ] Smart daily reminder schedules correctly
- [ ] Unit + integration tests pass (EventsService, event validation)

### TODO upgrade: Phase 3 Complete

- [ ] Auto-summarization job runs daily
- [ ] Otto & Tina use diary context (food, domestic tags)
- [ ] Mood trends visible to user
- [ ] Export diary entries feature
- [ ] Data deletion after 30 days (automated job)

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
