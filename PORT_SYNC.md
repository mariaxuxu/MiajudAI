# 🔒 PORT SYNCHRONIZATION - CRITICAL

## ⚠️ IMPORTANT: These 3 locations MUST ALWAYS have the same PORT value

### Current: `3001`

---

## Locations to sync (if you change the port):

### 1. Backend - Port Config
**File:** `backend/src/config/env.js`
**Line:** ~18
```javascript
port: 3001,  // 🔒 MUST MATCH backend/scripts/setup-env.js and frontend/constants.dart
```

### 2. Backend - Setup Script
**File:** `backend/scripts/setup-env.js`
**Line:** ~12
```javascript
const BACKEND_PORT = 3001;  // 🔒 MUST MATCH backend/src/config/env.js and frontend/constants.dart
```

### 3. Frontend - API Config
**File:** `frontend/lib/config/constants.dart`
**Line:** ~204
```dart
static const int BACKEND_PORT = 3001;  // 🔒 MUST MATCH backend ports above
```

---

## How to change the port (if needed in the future):

1. Change `backend/src/config/env.js` line 18 → `port: YOUR_PORT,`
2. Change `backend/scripts/setup-env.js` line 12 → `const BACKEND_PORT = YOUR_PORT;`
3. Change `frontend/lib/config/constants.dart` line 204 → `static const int BACKEND_PORT = YOUR_PORT;`
4. Restart everything: `npm run dev` + `flutter run`

---

## Why this matters:

- Backend MUST listen on the exact port Frontend is trying to reach
- If they mismatch, the app will timeout when making API calls
- The port affects:
  - ✅ Device/Simulator connections: `http://IP:PORT/api`
  - ✅ Android Emulator: `http://10.0.2.2:PORT/api`
  - ✅ Chrome: `http://localhost:PORT/api`

---

**Last Updated:** 2026-05-27
