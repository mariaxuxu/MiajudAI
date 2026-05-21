# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Comandos

### Backend (`cd backend`)
```bash
npm run dev    # Inicia dev — detecta IP automaticamente e atualiza frontend/assets/.env
npm start      # Produção (também auto-detecta IP)
npm test       # Jest
```

### Frontend (`cd frontend`)
```bash
flutter run          # Rodar app (restart completo após mudanças em pubspec.yaml ou assets/)
flutter test         # Todos os testes
flutter build apk    # Build Android
```

### Health check
```bash
curl http://localhost:5000/health
```

## Arquitetura

### Navegação real do app
A tela principal após login é `WelcomeScreen` (não `HomeScreen`). Ela tem cards de features e o botão "Falar com MiAjudAI". O card "Finanças" navega para `/accounts`.

```
Login → WelcomeScreen
          ├── /accounts (AccountsScreen)
          │     └── /income, /expenses
          ├── /calendar
          └── /chat (FinancialChatScreen) ← chat com Gemini
```

### Fluxo de autenticação
1. Flutter → Firebase Auth → ID token
2. `POST /api/auth/verify-token` com `{ idToken, fullName }`
3. Backend verifica via Firebase Admin SDK, upserta user no PostgreSQL
4. Backend retorna JWT (payload: `{ userId, email }`) — usar `req.user.userId`, não `req.user.id`
5. Flutter salva JWT em SharedPreferences, envia como `Authorization: Bearer <token>`

### Backend (`backend/src/`)
- **Entry**: `server.js` → `app.js`
- **Config**: `env.js` (dotenv), `database.js` (Sequelize + models), `firebase.js` (Admin SDK)
- **Rotas**: `routes/index.js` monta `/auth`, `/users`, `/events`, `/accounts`, `/income`, `/expenses`, `/chat`
- **Pattern**: route → controller → service → Sequelize model
- **Chat**: `POST /api/chat/financial` — busca dados financeiros do user no DB, monta contexto e chama Gemini

### Frontend (`frontend/lib/`)
- **Entry**: `main.dart` — inicializa dotenv, Firebase, MultiProvider
- **Providers**: AuthProvider, AccountProvider, IncomeProvider, ExpenseProvider, ChatProvider
- **HTTP**: `services/api_service.dart` com `http` package; URL lida de `dotenv.env['API_BASE_URL']`
- **Design**: azul `#1B4965`, laranja `#FF8C00`, fundo `#F5F5F7`, cards brancos com sombra

### IP dinâmico
`backend/scripts/setup-env.js` detecta o IP do Wi-Fi e escreve em `frontend/assets/.env`. Roda automaticamente via hooks `predev`/`prestart` do npm. **Nunca editar o IP manualmente.**

### Chat Gemini
- Modelo: `gemini-2.0-flash` (configurável via `GEMINI_MODEL` no `.env`)
- Chave: `GEMINI_API_KEY` no `backend/.env` — obter em aistudio.google.com → "Create API key in new project"
- O `chatService.js` busca contas, receitas e despesas do user antes de cada resposta

## Variáveis de ambiente

### Backend (`backend/.env`)
| Variável | Descrição |
|---|---|
| `POSTGRES_*` | Credenciais PostgreSQL |
| `FIREBASE_PROJECT_ID/PRIVATE_KEY/CLIENT_EMAIL` | Firebase Admin SDK |
| `JWT_SECRET` | Mín. 32 chars — não trocar após usuários cadastrados |
| `GEMINI_API_KEY` | Google AI Studio — criar em novo projeto |
| `GEMINI_MODEL` | Default: `gemini-2.0-flash` |

### Frontend (`frontend/assets/.env`)
Gerenciado automaticamente pelo script npm. Contém só `API_BASE_URL`.

## Épicos de desenvolvimento
| Épico | Status | Escopo |
|---|---|---|
| 1 — Setup | ✅ | Estrutura, health check |
| 2 — Auth | 🔄 | Firebase → JWT, cadastro |
| 3 — Calendário | 📋 | CRUD de eventos |
| 4 — Finanças | 🔄 | Contas, receitas, despesas, dashboard |
| 5 — Chat/LLM | 🔄 | Chat financeiro com Gemini (implementado, pendente chave API) |
| 6 — Deploy | 📋 | Testes, segurança, produção |
