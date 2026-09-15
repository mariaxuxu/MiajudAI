# MiAjudAI - Project Context

MiAjudAI is an intelligent mobile assistant for people living alone, combining financial management, calendar organization, and AI-powered specialized agents (Otto, Luna, Tina) to provide personalized support. The system learns user preferences through persistent context tracking and adapts agent responses accordingly.

---

## Language

### Core Entities

**User**:
A person living alone who uses MiAjudAI for financial tracking, calendar organization, and AI-powered assistance across multiple specialized domains.
_Avoid_: Client, account, person

**Agent**:
A specialized LLM personality (Otto for cooking, Luna for finances, Tina for household management) with domain-specific system prompts and access to user context.
_Avoid_: Bot, AI, chatbot, assistant

**User Context** (Context):
Persistent profile automatically updated from conversation history, storing user preferences, routines, interests, and detected patterns to enable personalized agent responses.
_Avoid_: Profile, persona, user data

**Conversation**:
A session of messages between user and a specific agent; auto-expires after 7 days; full message history retained for persona extraction.
_Avoid_: Chat session, thread

**Message**:
Single user or agent text exchange within a conversation, tagged with sender type and token count for rate limiting and analytics.
_Avoid_: Text, input, response

---

### Financial Domain

**Account**:
Financial repository (checking, savings, credit card) owned by user; serves as parent for income and expense categorization.
_Avoid_: Wallet, fund, container

**Income**:
Monetary inflow to account (salary, bonus, gift, refund), timestamped and categorized for trend analysis and forecasting.
_Avoid_: Earning, revenue, addition

**Expense**:
Monetary outflow from account (food, utilities, transport, entertainment), timestamped and categorized for spending analysis.
_Avoid_: Transaction, payment, debit

**Transaction**:
Parent concept encompassing both income and expense; shared metadata: amount, date, category, account, type.
_Avoid_: Record, entry, movement

**Dashboard**:
Real-time financial analytics surface showing account balances, spending trends, category breakdowns, and expense forecasts.
_Avoid_: Home, overview, summary

---

### Calendar & Events

**Event**:
Scheduled activity with title, date, category, and optional notification; stored in user's calendar for organization and reminders.
_Avoid_: Appointment, task, reminder

**Notification**:
Push or local alert triggered on event date; stored as per-event preference in calendar_events table.
_Avoid_: Alert, reminder, trigger

---

### Authentication & Security

**ID Token**:
Firebase-issued JWT sent by Flutter client to backend `/api/auth/verify-token` endpoint for server-side verification.
_Avoid_: Auth token, Firebase token

**JWT** (Backend):
Backend-generated token with payload `{userId, email}`; signed with JWT_SECRET (min 32 chars), stored in client SharedPreferences, sent as `Authorization: Bearer <token>`.
_Avoid_: Token, auth token

**Emergency Contact**:
Pre-registered phone number belonging to trusted person; used for SMS delivery during critical alerts or events.
_Avoid_: Contact, trusted contact

**Verification** (SMS):
Boolean flag confirming emergency contact has received and acknowledged SMS alert; updated after successful Twilio delivery.
_Avoid_: Acknowledgment, confirmation

**Security Log**:
Immutable audit record tracking authentication attempts, API access, IP addresses, and security events for compliance and investigation.
_Avoid_: Audit log, activity log

---

### Integration & Services

**Firebase Admin SDK**:
Server-side library verifying Firebase ID tokens and managing authentication without exposing private keys; configured via FIREBASE_PROJECT_ID, FIREBASE_PRIVATE_KEY, FIREBASE_CLIENT_EMAIL.
_Avoid_: Firebase backend, Auth service

**LLM Provider**:
External API service (OpenAI, Anthropic, Grok) processing user messages and generating agent responses; Grok currently deployed via `https://api.groq.com/openai/v1/chat/completions`.
_Avoid_: API service, backend service

**Grok**:
LLM model (`llama-3.3-70b-versatile`) compatible with OpenAI SDK; selected for cost-efficiency and ~850ms response time; replaces Gemini as primary provider.
_Avoid_: Model, AI service

**Twilio**:
SMS delivery service for emergency contacts; supports automatic retry and delivery confirmation via account SID and auth token.
_Avoid_: SMS service, messaging service

**PostgreSQL**:
Relational database (v14+) storing users, transactions, conversations, messages, contexts, and security logs; hosted on Oracle Cloud Free Tier (20GB always-free).
_Avoid_: Database, DB

**Oracle Cloud Free Tier**:
Infrastructure provider offering 20GB PostgreSQL, 4vCPU, 24GB RAM, and 20GB object storage with no expiration; selected for zero-cost startup viability.
_Avoid_: Cloud platform, infrastructure

---

### System Patterns

**System Prompt**:
Agent-specific instruction template injected into LLM request; establishes personality and domain expertise (e.g., Luna: "You are Luna, assistant specialized in personal finances").
_Avoid_: Instructions, template, prompt (when specificity matters)

**Context Injection**:
Process of embedding user's financial records and preferences as hidden system messages in first LLM request of session; allows agent memorization without exposing raw data to user.
_Avoid_: Context passing, data embedding

**Token Counting**:
Tracking LLM input/output tokens per message for rate limiting, cost management, and triggering fallback strategies when quota approaches limit.
_Avoid_: Token usage, consumption

**Rate Limiting**:
Quota enforcement preventing excessive LLM API calls; includes per-user message caps and token budgets to control costs and prevent abuse.
_Avoid_: Throttling, quota

**Historical Data** (7-day window):
Conversations and messages retained for 7 days post-expiration for persona extraction, then auto-deleted; balances personalization against data minimization.
_Avoid_: History, archive

**Persona Extraction**:
Automated daily job analyzing 7-day message history to detect patterns, interests, preferences; results stored in user_context for enriching future agent responses.
_Avoid_: Learning, inference, profile building

---

### Frontend Architecture

**WelcomeScreen**:
Primary post-login dashboard displaying feature cards (Finance, Calendar, Chat) and direct entry point for agent interaction after authentication.
_Avoid_: HomeScreen, Dashboard (generic), Home

**Provider** (State Management):
Dart package for reactive state sharing across Flutter widgets; MiAjudAI uses AuthProvider, AccountProvider, IncomeProvider, ExpenseProvider, ChatProvider.
_Avoid_: State manager, bloc, redux

**Dotenv**:
Environment variable loader injecting API_BASE_URL and Firebase config at startup; auto-updated by backend setup script with detected local IP address.
_Avoid_: Config file, environment settings

**API Service**:
HTTP client using `http` package (not Dio); reads API_BASE_URL from dotenv; sends JWT in Authorization header for authenticated requests.
_Avoid_: HTTP client, request handler

---

### Backend Architecture

**Route**:
HTTP endpoint mapping (POST /api/auth/verify-token, GET /api/accounts) dispatching to controller; organized by feature in routes/index.js.
_Avoid_: Endpoint, path, handler

**Controller**:
Request handler extracting HTTP data, delegating to services, and returning responses; thin layer between routes and business logic.
_Avoid_: Handler, endpoint handler

**Service**:
Business logic layer performing complex operations (auth verification, LLM calls, context extraction, SMS sending) independent of HTTP.
_Avoid_: Business logic, handler

**Middleware**:
Interceptor function (auth verification, CORS, error handling, logging) applied to routes or globally; execution order is critical.
_Avoid_: Interceptor, plugin, filter

**Model** (Sequelize):
ORM representation of database table with relations, validations, and lifecycle hooks (User, Event, Transaction, Message, UserContext, EmergencyContact, SecurityLog).
_Avoid_: Table, entity, schema

**Migration**:
Versioned database schema change tracked in source control; run via `npm run migrate` to create tables or alter structure.
_Avoid_: Schema update, database change

---

### Development & Project Management

**Epic** (Épico):
Major feature grouping spanning multiple sprints with 45-135 story points (Epic 1: Setup, Epic 2: Auth, Epic 3: Calendar, Epic 4: Finance, Epic 5: Chat/LLM, Epic 6: Deploy).
_Avoid_: Feature, module, story group

**Sprint**:
1-week development cycle with 45 story points distributed across 3 developers (Backend: 15 pts, Flutter: 15 pts, QA/Ops: 15 pts).
_Avoid_: Iteration, week, cycle

**Story Points**:
Effort estimation unit (Fibonacci scale) reflecting complexity and effort; 3 developers deliver ~45 pts/sprint total.
_Avoid_: Hours, days, size

**Milestone**:
High-level acceptance criterion marking meaningful completion: M1 (health check), M2 (login), M3 (finance ops), M6 (first booking), M7 (Play Store release).
_Avoid_: Goal, target, deadline

**GitHub Actions**:
CI/CD automation running tests, linting, and staged builds on push; verifies code quality before manual production release.
_Avoid_: Pipeline, workflow (generic), automation

**Play Store**:
Official Android application distribution channel; final deployment target after security audit and test coverage verification.
_Avoid_: App store, marketplace

---

### Future Roadmap Features (Q3-Q4 2026)

**Profile Tracking** (Aug 2026, 3 weeks):
Foundation capturing screen navigation, dwell time, and agent usage to populate user_context; enables personalization Phase 1.
_Avoid_: Behavior tracking, analytics

**Advanced Analytics** (Sep 2026, 4 weeks):
Dashboard with expense forecasting, spending trends, and category analytics; wellness tracking (habits, meals, exercise, gamified streaks).
_Avoid_: Reporting, insights, statistics

**Emergency SMS** (Sep-Oct 2026, 2 weeks):
Reliable bulk SMS delivery to emergency contacts with automatic retry, delivery confirmation, and audit logging via Twilio.
_Avoid_: Alert system, notification service, SMS service (when referring to specific feature)

**MiAjudAki** (Oct-Nov 2026, 6 weeks):
Service marketplace enabling bookings (electrician, cleaner, plumber) with catalog, contracting, payment processing, invoices, and service tracking.
_Avoid_: Marketplace, booking platform, service platform (generic)

---

## Technology Stack

### Frontend
- **Framework**: Flutter 3.0+
- **Language**: Dart 3.0+
- **Auth**: firebase_core 4.7.0, firebase_auth 6.4.0 (Google/Apple OAuth)
- **State**: Provider 6.1.0
- **HTTP**: http 1.1.0 + dio 5.3.0
- **Storage**: SharedPreferences 2.2.2, sqflite 2.3.0
- **UI**: Flutter SVG 2.0.7, cached_image 3.3.0
- **Charts**: FL Chart 1.2.0
- **Calendar**: Table Calendar 3.0.9
- **Notifications**: local_notifications 21.0.0
- **Target**: Android 8.0+
- **APK Size**: 40-60MB (release)

### Backend
- **Runtime**: Node.js 18.0+
- **Framework**: Express.js 4.18.2
- **ORM**: Sequelize 6.35.2, Prisma 7.8.0
- **Database**: PostgreSQL 14
- **Auth**: firebase-admin 12.1.0, jsonwebtoken 9.0.2
- **LLM**: openai SDK 4.52.7 (OpenAI/Grok-compatible), @anthropic-ai/sdk 0.9.1
- **SMS**: Twilio 4.10.0
- **Security**: helmet 7.1.0, bcryptjs 2.4.3, express-validator 7.1.0
- **Testing**: Jest 29.7.0, Supertest 6.3.3
- **Logging**: morgan 1.10.0
- **Tools**: Nodemon 3.1.0, ESLint 8.56.0, cross-env 10.1.0

### Infrastructure
- **Cloud**: Oracle Cloud Free Tier (PostgreSQL 20GB, 4vCPU, 24GB RAM)
- **Containerization**: Docker v20+, Docker Compose v3.8
- **Versioning**: Git + GitHub
- **CI/CD**: GitHub Actions
- **Deployment**: Manual to Play Store (Android)

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────┐
│                    MiAjudAI - Arquitetura                          │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌──────────────────┐         ┌──────────────────┐                │
│  │   FRONTEND       │         │    BACKEND       │                │
│  │   (Flutter)      │         │  (Node.js)       │                │
│  └────────┬─────────┘         └────────┬─────────┘                │
│           │                            │                          │
│      Dart v3.0+                  Node.js 18+                       │
│                                  Express 4.18                      │
│                                                                     │
│           └────────────── REST API ──────────────┘                │
│                                                                     │
│                     ┌──────────────────┐                           │
│                     │   PostgreSQL 14  │                          │
│                     │   (Docker)       │                          │
│                     └──────────────────┘                          │
│                                                                     │
│     ┌──────────────┬───────────────┬──────────────┐               │
│     │  Firebase    │  Grok LLM     │   Twilio     │               │
│     │  Auth        │   (OpenAI)    │   SMS        │               │
│     └──────────────┴───────────────┴──────────────┘               │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Database Schema (Core Tables)

| Table | Purpose |
|-------|---------|
| `users` | Firebase UID, email, phone, full_name, avatar, timestamps |
| `user_context` | Extracted persona: interests, routine_data, preferences, common_questions |
| `calendar_events` | User's events with title, date, category, notification flag |
| `accounts` | Financial accounts (checking, savings, credit card) |
| `transactions` | Income/expense records with amount, date, category, account_id |
| `llm_conversations` | Session metadata (user_id, agent_type, expires_at) |
| `messages` | Individual messages (conversation_id, sender_type, content, tokens_used) |
| `emergency_contacts` | Phone numbers, verification status |
| `security_logs` | Authentication events, IP addresses, activity audit |

---

## Development Workflow

### Backend (`cd backend`)
```bash
npm run dev       # Auto-detect IP, update frontend/.env
npm start         # Production mode
npm test          # Jest with coverage
npm run migrate   # Run database migrations
npm run seed      # Populate test data
```

### Frontend (`cd frontend`)
```bash
flutter run              # Run on emulator/device
flutter test             # Run all tests
flutter build apk        # Build Android release
flutter clean            # Clean build artifacts
```

### Health Check
```bash
curl http://localhost:5000/health  # API readiness probe
```

---

## Environment Variables

### Backend (`backend/.env`)
- `POSTGRES_HOST`, `POSTGRES_USER`, `POSTGRES_PASSWORD`, `POSTGRES_PORT`, `POSTGRES_DB`
- `FIREBASE_PROJECT_ID`, `FIREBASE_PRIVATE_KEY`, `FIREBASE_CLIENT_EMAIL`
- `JWT_SECRET` (min 32 chars, immutable after users created)
- `GEMINI_API_KEY`, `GEMINI_MODEL` (legacy; Grok now primary)
- `GROQ_API_KEY` (current LLM provider)
- `NODE_ENV` (development/production)

### Frontend (`frontend/assets/.env`)
- `API_BASE_URL` (auto-populated by backend setup script)

---

## Key Decisions & Rationale

| Decision | Why |
|----------|-----|
| **Firebase Auth** | Native OAuth (Google/Apple), no password management, Flutter integration native |
| **Grok LLM** | OpenAI-compatible API, cost-efficient, ~850ms response, easy fallback to Claude |
| **7-day retention** | Token economy vs context richness; daily extraction builds persona |
| **Hidden context injection** | First message embeds financial data as system message; reduces token leakage to user |
| **Oracle Cloud Free Tier** | Zero-cost startup infrastructure with permanent uptime guarantee |
| **Dual ORM ready** | Sequelize + Prisma setup provides migration flexibility |

---

## Related Documentation

- **TECH_STACK.md** — Detailed dependency versions, hardware requirements, performance benchmarks
- **CLAUDE.md** — Navigation flow, authentication flow details, IP dynamic detection
- **backend/README.md** — Backend setup, project structure, database schema, troubleshooting
- **frontend/README.md** — Flutter setup, design system (colors, typography), testing
- **EVOLUTION_CRONOGRAM_VISUAL_V2.md** — 4-month roadmap (Aug-Nov 2026) with phases, milestones, story points

---

**Last Updated**: August 22, 2026
**Status**: MVP (Épicos 1-6) in development; Phase 2 roadmap (Profile Tracking, Analytics, Emergency SMS, MiAjudAki) defined
**Audience**: Development team, stakeholders, new contributors
