# MVP Diary Testing Checklist

**Date:** 2026-08-24
**Goal:** Verify diary entries are saved to PostgreSQL database
**Scope:** DiaryScreen → Save → POST /api/user-activity → diary_entries table

---

## Architecture (MVP Simplified)

### Frontend Flow
```
DiaryScreen
  ↓ (user taps Save)
DiaryProvider.saveDiary()
  ↓
DiaryService.saveDiaryEntry()
  ↓
POST /api/user-activity { events: [{ type: 'diary', text, mood, tags }] }
  ↓ (immediate response)
Success toast + clear form
```

**No batching, no screen tracking, no reminders — just direct POST on save.**

---

## Test Steps

### 1. Start Backend
```bash
cd backend
npm run dev
# Expected output:
# ✅ Database connected
# ✅ Server running on http://[IP]:5000
```

### 2. Start Frontend
```bash
cd frontend
flutter run
# Expected output:
# ✅ App launches
```

### 3. Login
- Email: `test@example.com` (or any test account)
- Password: `password123`
- Expected: Redirected to WelcomeScreen after successful login

### 4. Navigate to Diary
- Tap the "Diary" menu item or navigate to `/diary`
- Expected: DiaryScreen loads with calendar

### 5. Write & Save Entry
1. Tap today's date on calendar
2. Enter text: `"This is my first diary entry"`
3. Select mood: `happy` (😊)
4. Select tags: `finance` + `food` (checkboxes)
5. Tap **Save** button
6. Expected: Toast shows `✅ Diary entry saved to database!`

### 6. Verify Database

**Option A: Docker PostgreSQL**
```bash
docker exec -it miajudai-postgres-1 psql -U postgres -d miajudai -c \
  "SELECT id, user_id, text, mood, emotion_score, tags, created_at FROM diary_entries ORDER BY created_at DESC LIMIT 1;"
```

**Expected output:**
```
 id | user_id |              text              | mood  | emotion_score |      tags      |         created_at
----+---------+--------------------------------+-------+---------------+----------------+----------------------------
  1 |       1 | This is my first diary entry   | happy |            80 | {finance,food} | 2026-08-24 14:30:00.123456
```

**Option B: DBeaver / SQL Client**
- Connect to localhost:5432 → miajudai database
- Query: `SELECT * FROM diary_entries ORDER BY created_at DESC LIMIT 1;`

---

## Verification Checklist

- [ ] Frontend POST request succeeds (check network tab in DevTools)
- [ ] Response has `{ success: true, events_stored: 1 }`
- [ ] Database row appears with correct:
  - `text` field (your diary entry)
  - `mood` field (happy)
  - `emotion_score` (80 for happy)
  - `tags` array (`{finance,food}`)
  - `created_at` timestamp (current time)
  - `user_id` (matches logged-in user)

---

## Debug Commands & Audit Logs

### Backend Audit Logs
```bash
# When you run: npm run dev
# You'll see comprehensive audit logs like this:

============================================================
[AUDIT] 2026-08-24T14:30:00.000Z - POST /api/user-activity
[AUDIT] User ID: 1
[AUDIT] Events received: 1
[AUDIT]   Event 0: type=diary
[PROCESSING] 📤 Processing batch: 1 events for user 1
[VALIDATE] ✓ Diary event validation passed
[DB] ✅ Diary entry CREATED
[DB]   ID: 42
[DB]   User: 1
[DB]   Mood: happy (score: 80)
[DB]   Text: "This is my first diary entry"
[DB]   Tags: [finance, food]
[SUCCESS] ✅ Batch processed: 1 stored, 0 errors
[SUMMARY] Diary: 1 | Screen: 0 | Interaction: 0
============================================================
```

### Frontend Debug
```dart
// In DiaryService.saveDiaryEntry()
print('📝 Saving diary entry...');  // Before POST
print('✅ Diary entry saved: 1 event(s) stored');  // After POST (from response)
```

### Watch Logs in Real-Time
```bash
# Terminal 1: Backend
cd backend && npm run dev

# Terminal 2: Watch logs (in another terminal)
tail -f backend/logs/debug.log | grep -E '\[AUDIT\]|\[DB\]|\[ERROR\]'
```

### API Testing (curl)
```bash
curl -X POST http://localhost:5000/api/user-activity \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -d '{
    "events": [{
      "type": "diary",
      "text": "Curl test entry",
      "mood": "happy",
      "tags": ["finance"]
    }]
  }'

# Expected response:
# { "success": true, "events_stored": 1, "timestamp": "2026-08-24T14:30:00Z" }
```

---

## Expected Behavior

✅ **Success:** Diary entry appears in database within 2 seconds of Save click
❌ **Failure:** Toast shows error or no database row appears

---

## Next Steps (Phase 2+)

After confirming diary persistence works:

1. **TODO upgrade: EventsService** — Implement batching for screen/interaction tracking
2. **TODO upgrade: Read operations** — Load diary entries from DB, show in calendar
3. **TODO upgrade: Opt-in modal** — Ask user permission on first launch
4. **TODO upgrade: Smart reminder** — Daily 8pm notification
5. **TODO upgrade: Luna integration** — Verify Luna receives diary context in responses

---

## Files Changed (MVP Simplification)

### Frontend Simplified
- ✅ `DiaryService.dart` — Removed read/delete, added direct POST
- ✅ `DiaryProvider.dart` — Removed batch logic, simplified to save only
- ✅ `DiaryScreen.dart` — Removed load/delete UI, focused on write
- ✅ `AuthProvider.dart` — Removed EventsService init/dispose

### Backend (No Changes)
- ✅ `POST /api/user-activity` — Already handles diary events correctly
- ✅ Validation — Already strict on mood/tags/emotion_score
- ✅ Database — `diary_entries` table ready

### Spec Updated
- ✅ `SPEC_DIARY_BEHAVIOR.md` — MVP section clarified
- ✅ Phase 2/3 marked with `TODO upgrade` tags

---

## Audit Log Examples

### ✅ Success Case
```
============================================================
[AUDIT] 2026-08-24T14:30:00.123Z - POST /api/user-activity
[AUDIT] User ID: 1
[AUDIT] Events received: 1
[AUDIT]   Event 0: type=diary
[PROCESSING] 📤 Processing batch: 1 events for user 1
[VALIDATE] ✓ Diary event validation passed
[DB] ✅ Diary entry CREATED
[DB]   ID: 42
[DB]   User: 1
[DB]   Mood: happy (score: 80)
[DB]   Text: "Paid bills today, relieved"
[DB]   Tags: [finance]
[SUCCESS] ✅ Batch processed: 1 stored, 0 errors
[SUMMARY] Diary: 1 | Screen: 0 | Interaction: 0
============================================================
```

### ❌ Validation Error
```
============================================================
[AUDIT] 2026-08-24T14:31:00.456Z - POST /api/user-activity
[AUDIT] User ID: 1
[AUDIT] Events received: 1
[AUDIT]   Event 0: type=diary
[PROCESSING] 📤 Processing batch: 1 events for user 1
[VALIDATE] ✗ Validation failed: mood - Mood must be one of: happy, sad, neutral
[ERROR]   Event index 0: mood - Mood must be one of: happy, sad, neutral
[ERROR] Batch processed: 0 stored, 1 errors
============================================================
```

### ❌ Empty Text Error
```
[VALIDATE] ✗ Validation failed: text - Diary text is required and cannot be empty
[ERROR]   Event index 0: text - Diary text is required and cannot be empty
```

---

## Troubleshooting

| Issue | Cause | Audit Log Sign | Fix |
|-------|-------|----------------|-----|
| "Not authenticated" | No token in request | `[AUDIT]` not shown | Ensure login completed, check `authProvider.authToken` |
| "Invalid mood" | Typo in mood value | `[VALIDATE] ✗ Validation failed: mood` | Use exactly: `happy`, `sad`, `neutral` |
| Network error | Backend not running | No logs at all | Start backend: `npm run dev` |
| No database row | Validation failed | `[ERROR]` in logs | Check backend logs for validation error |
| Wrong emotion_score | Mood derivation bug | `[DB]` shows wrong score | Happy=80, sad=20, neutral=50 |
| Empty text | Text not provided | `[VALIDATE] ✗ text - required` | Ensure DiaryScreen has text input before Save

---

**Document prepared by:** Claude Code
**Last updated:** 2026-08-24
