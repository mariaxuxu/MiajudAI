# MiAjudAI Backend API

Backend Node.js + Express for MiAjudAI - Intelligent Support App for people living alone.

## 🚀 Quick Start

### Prerequisites
- Node.js >= 18.0.0
- npm >= 9.0.0
- PostgreSQL — local (docker-compose) or remote (Supabase)
- Firebase project
- OpenAI or Anthropic Claude API key

### Installation

1. **Clone and setup**
```bash
cd backend
npm install
```

2. **Configure environment**
```bash
cp .env.example .env
```

Edit `.env` with your credentials:
- **Database**: Supabase `DATABASE_URL`, or local docker-compose Postgres (see "Database Setup" below)
- **Firebase**: Service account keys from Firebase Console
- **LLM**: OpenAI API key or Anthropic Claude key
- **Twilio**: SMS service credentials (optional, for emergency contacts)

3. **Start the database and run migrations**

Local (docker-compose):
```bash
docker compose up -d
npm run migrate
```

For Supabase, set `DATABASE_URL` in `.env` instead — see "Database Setup" below.

4. **Run development server**
```bash
npm run dev
```

Server runs on `http://localhost:5000`

### Health Check

```bash
curl http://localhost:5000/health
```

Response:
```json
{
  "status": "ok",
  "message": "MiAjudAI API is operational",
  "timestamp": "2026-04-20T14:30:00.000Z",
  "environment": "development",
  "version": "1.0.0",
  "uptime": 123.456,
  "checks": {
    "api": "healthy"
  }
}
```

---

## 📁 Project Structure

```
backend/
├── src/
│   ├── app.js                    # Express app
│   ├── server.js                 # Server startup
│   ├── config/
│   │   ├── env.js                # Environment configuration
│   │   ├── database.js           # Sequelize + PostgreSQL (Épico 1.2)
│   │   ├── firebase.js           # Firebase Admin SDK (Épico 2)
│   │   └── llm.js                # LLM configuration (Épico 5)
│   ├── controllers/              # Business logic
│   │   ├── healthController.js   # Health check
│   │   ├── authController.js     # Auth endpoints (Épico 2)
│   │   ├── usersController.js    # User endpoints (Épico 2)
│   │   └── ...
│   ├── routes/                   # API routes
│   │   ├── index.js              # Main router
│   │   ├── health.js             # Health route
│   │   ├── auth.js               # Auth routes (Épico 2)
│   │   └── ...
│   ├── models/                   # Sequelize models (Épico 1.2)
│   │   ├── User.js
│   │   ├── Event.js
│   │   └── ...
│   ├── services/                 # Business services
│   │   ├── authService.js        # Auth logic (Épico 2)
│   │   ├── llmService.js         # LLM integration (Épico 5)
│   │   └── ...
│   ├── middleware/               # Express middleware
│   │   ├── errorHandler.js       # Global error handler
│   │   ├── logger.js             # Request logging
│   │   ├── cors.js               # CORS configuration
│   │   ├── auth.js               # Token verification (Épico 2)
│   │   └── ...
│   ├── utils/                    # Utilities
│   │   ├── constants.js          # Constants
│   │   ├── validators.js         # Input validators (Épico 2)
│   │   └── formatters.js         # Response formatters
│   ├── jobs/                     # Background jobs
│   │   ├── cleanupOldChats.js    # Chat cleanup (Épico 5)
│   │   └── securityMonitoring.js # Security logs (Épico 6)
│   └── migrations/               # Database migrations
│       └── ...
├── tests/                        # Test files
├── package.json
├── .env.example                  # Environment variables template
├── .gitignore
└── README.md
```

---

## 📚 Available Scripts

| Command | Purpose |
|---------|---------|
| `npm start` | Run production server |
| `npm run dev` | Run development server with auto-reload |
| `npm test` | Run tests with coverage |
| `npm run test:watch` | Run tests in watch mode |
| `npm run lint` | Check code style |
| `npm run lint:fix` | Auto-fix style issues |
| `npm run migrate` | Apply pending migrations (Umzug) |
| `npm run migrate:down` | Revert the last applied migration |
| `npm run migrate:status` | List executed and pending migrations |

---

## 🔐 Environment Variables

### Required
- `DATABASE_URL` - Supabase connection string (takes priority over the `POSTGRES_*` fields below)
- `POSTGRES_HOST` - Database host (local docker-compose fallback)
- `POSTGRES_USER` - Database user
- `POSTGRES_PASSWORD` - Database password
- `POSTGRES_SSL` - Set `false` for local docker-compose Postgres (SSL is on by default)
- `FIREBASE_PROJECT_ID` - Firebase project ID
- `JWT_SECRET` - JWT signing secret (min 32 chars)

### Optional
- `OPENAI_API_KEY` - OpenAI API key
- `ANTHROPIC_API_KEY` - Anthropic Claude API key
- `TWILIO_*` - SMS service credentials

See `.env.example` for all options.

---

## 🗄️ Database Setup

The backend connects to Postgres through a single factory that accepts either a
Supabase `DATABASE_URL` or local `POSTGRES_*` fields. Migrations (Umzug) are the
single source of truth for the schema — `sequelize.sync()` is no longer run on boot.

### Local (docker-compose)
1. Start PostgreSQL:
   ```bash
   docker compose up -d
   ```
2. In `.env`, keep `POSTGRES_SSL=false` and the default `POSTGRES_*` values
   (`localhost:5432`, db `miajudai_dev`, user/password `postgres`).
3. Apply migrations:
   ```bash
   npm run migrate
   ```

### Supabase (remote)
1. Copy the connection string from **Supabase → Settings → Database → Connection string**
   (use **direct**, port `5432`; the pooler on `6543` is a fallback if you hit network errors).
2. In `.env`, set `DATABASE_URL` (it takes priority over `POSTGRES_*`) and
   remove `POSTGRES_SSL=false` — Supabase requires SSL. URL-encode special
   characters (`@ : / # ? % space`) in the password.
3. Apply migrations:
   ```bash
   npm run migrate
   ```

### Main Tables (Épico 1-2)
- `users` - User accounts
- `user_context` - User preferences & learning
- `emergency_contacts` - Emergency contact info
- `security_logs` - Activity logs

---

## 🔑 Firebase Setup

1. Create Firebase project: https://firebase.google.com
2. Enable Authentication (Google/Apple OAuth)
3. Generate service account key:
   - Project Settings > Service Accounts > Generate New Private Key
4. Copy values to `.env`:
   - `FIREBASE_PROJECT_ID`
   - `FIREBASE_PRIVATE_KEY`
   - `FIREBASE_CLIENT_EMAIL`

---

## 🤖 LLM Integration

Choose one provider:

### OpenAI
```bash
LLM_PROVIDER=openai
OPENAI_API_KEY=sk-...
OPENAI_MODEL=gpt-4-turbo
```

### Anthropic Claude
```bash
LLM_PROVIDER=anthropic
ANTHROPIC_API_KEY=sk-ant-...
ANTHROPIC_MODEL=claude-3-sonnet-20240229
```

---

## 📋 Épicos

### ✅ Épico 1: Setup Inicial (Sprint 1)
- [x] Health check endpoint
- [x] Express app structure
- [x] Environment configuration
- [ ] Database connection (next phase)

### 🔄 Épico 2: Autenticação (Sprints 2-3)
- [ ] Firebase Admin SDK integration
- [ ] `/auth/verify-token` endpoint
- [ ] `/users/register` endpoint
- [ ] Auth middleware

### 📅 Épico 3: Calendário (Sprint 4)
- [ ] Event CRUD endpoints

### 💰 Épico 4: Finanças (Sprints 5-6)
- [ ] Transaction endpoints
- [ ] Analytics & predictions

### 💬 Épico 5: Chat LLM (Sprints 7-9)
- [ ] Chat endpoints
- [ ] Context learning
- [ ] Agent specialization

### 🔒 Épico 6: Segurança & Deploy (Sprint 10)
- [ ] Security audit
- [ ] E2E tests
- [ ] Production deployment

---

## 🧪 Testing

```bash
# Run all tests
npm test

# Watch mode
npm run test:watch

# With coverage
npm test -- --coverage
```

---

## 🐛 Troubleshooting

### Port Already in Use
```bash
lsof -i :5000
kill -9 <PID>
```

### Database Connection Error
- Check `DATABASE_URL` (Supabase) or the `POSTGRES_*` environment variables (local docker)
- Verify PostgreSQL is running (`docker compose ps` for local, Supabase dashboard for remote)
- For Supabase, confirm SSL is enabled (do not set `POSTGRES_SSL=false`)
- Test connection with pgAdmin

### Firebase Error
- Verify `serviceAccountKey.json` values in `.env`
- Check Firebase project exists
- Enable required APIs in Firebase Console

---

## 📝 API Documentation

See `docs/api.md` for detailed endpoint documentation (coming soon).

### Base URL
```
http://localhost:5000/api
```

### Health Check
```
GET /health
```

---

## 🤝 Contributing

1. Create feature branch: `git checkout -b feature/xxx`
2. Commit changes: `git commit -am 'Add feature'`
3. Push to branch: `git push origin feature/xxx`
4. Create Pull Request

---

## 📄 License

MIT

---

**Last Updated**: 2026-04-20
**Status**: Épico 1 - Phase 1 Complete (Health Check)
