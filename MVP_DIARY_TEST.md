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

## Debug Commands

### Backend Logs
```bash
# Watch backend logs
tail -f backend/logs/debug.log

# Or run with verbose output
npm run dev 2>&1 | grep -i diary
```

### Frontend Debug
```dart
// In DiaryService.saveDiaryEntry()
print('📝 Saving diary entry...');  // Before POST
print('✅ Diary entry saved: ${response['events_stored']} event(s) stored');  // After POST
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

## Troubleshooting

| Issue | Cause | Fix |
|-------|-------|-----|
| "Not authenticated" | No token in request | Ensure login completed, check `authProvider.authToken` |
| "Invalid mood" | typo in mood value | Use exactly: `happy`, `sad`, `neutral` |
| Network error | Backend not running | Start backend: `npm run dev` |
| No database row | Validation failed | Check backend logs for validation error |
| Wrong emotion_score | Mood derivation bug | Happy=80, sad=20, neutral=50 |

---

**Document prepared by:** Claude Code
**Last updated:** 2026-08-24
