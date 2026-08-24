# 🛠️ MiAjudAI - Stack Tecnológico Completo

**Última atualização:** 26 de Maio de 2026

---

## 📊 Visão Geral

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
│     │  Firebase    │  OpenAI/Grok  │   Twilio     │               │
│     │  Auth        │   LLM         │   SMS        │               │
│     └──────────────┴───────────────┴──────────────┘               │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 🎯 Stack por Camada

### **1. FRONTEND (Flutter/Dart)**

| Categoria | Tecnologia | Versão | Propósito |
|-----------|-----------|--------|----------|
| **Framework** | Flutter | ≥3.0.0 | UI móvel Android |
| **Linguagem** | Dart | ≥3.0.0 | Lógica do app |
| **Autenticação** | Firebase Auth | 6.4.0 | Login Google/Apple |
| **State Mgmt** | Provider | 6.1.0 | Gerenciar estado global |
| **HTTP Client** | http + dio | 1.1.0 / 5.3.0 | Requisições API |
| **Storage Local** | SharedPrefs + sqflite | 2.2.2 / 2.3.0 | Dados offline |
| **UI Components** | Flutter SVG, cached_image | 2.0.7 / 3.3.0 | Ícones, imagens |
| **Gráficos** | FL Chart | 1.2.0 | Dashboard financeiro |
| **Calendário** | Table Calendar | 3.0.9 | Eventos/agendamentos |
| **Notificações** | local_notifications | 21.0.0 | Push notifications |
| **Utilities** | uuid, validators, get_it | 4.0.0+ | Auxiliares |
| **Dev Tools** | flutter_test, mockito | - | Testes |

**Tamanho Estimado:** ~200-300MB (após compilar)

---

### **2. BACKEND (Node.js)**

| Categoria | Tecnologia | Versão | Propósito |
|-----------|-----------|--------|----------|
| **Runtime** | Node.js | ≥18.0.0 | Ambiente JavaScript servidor |
| **Framework** | Express.js | 4.18.2 | HTTP REST API |
| **ORM 1** | Sequelize | 6.35.2 | Query builder + migrations |
| **ORM 2** | Prisma | 7.8.0 | Type-safe schema |
| **Database** | PostgreSQL | 14 | Banco relacional |
| **DB Client** | pg | 8.11.3 | Driver PostgreSQL |
| **Autenticação** | Firebase Admin SDK | 12.1.0 | Verificar JWT Firebase |
| **JWT** | jsonwebtoken | 9.0.2 | Tokens customizados |
| **LLM - OpenAI** | openai | 4.52.7 | GPT API |
| **LLM - Anthropic** | @anthropic-ai/sdk | 0.9.1 | Claude API |
| **LLM - Grok** | Compatible com OpenAI | - | Grok (compatível) |
| **SMS** | Twilio | 4.10.0 | Enviar SMS contactos |
| **HTTP Client** | axios | 1.6.8 | Requisições internas |
| **Validação** | express-validator | 7.1.0 | Validar inputs |
| **Segurança** | helmet | 7.1.0 | Headers de segurança |
| **Hash Senha** | bcryptjs | 2.4.3 | Criptografar senhas |
| **Logging** | morgan | 1.10.0 | Logs HTTP |
| **Env Variables** | dotenv | 16.4.5 | Configurações |
| **Testes** | Jest | 29.7.0 | Testes unitários |
| **Testes API** | Supertest | 6.3.3 | Testes integração |
| **Linting** | ESLint | 8.56.0 | Análise código |
| **Dev Watch** | Nodemon | 3.1.0 | Auto-reload |
| **Cross-platform** | cross-env | 10.1.0 | Variáveis env multiplataforma |

**Tamanho Estimado:** ~600-800MB (node_modules)

---

### **3. BANCO DE DADOS**

| Componente | Tecnologia | Config |
|-----------|-----------|--------|
| **Database Engine** | PostgreSQL | v14 |
| **Containerização** | Docker | v20+ |
| **Orquestração** | Docker Compose | v3.8 |
| **Port** | 5432 (padrão) | localhost:5432 |
| **Storage** | Docker volume | postgres_data |
| **User** | postgres | senha: postgres (dev) |
| **Database** | miajudai_dev | miajudai_prod (produção) |

**Tamanho Estimado:** ~2-5GB (com dados de teste)

---

### **4. INFRAESTRUTURA & DEPLOYMENT**

| Componente | Tecnologia | Responsabilidade |
|-----------|-----------|----------|
| **Versionamento** | Git + GitHub | Source control |
| **CI/CD** | GitHub Actions | Build/Test/Deploy automático |
| **Containerização** | Docker | Isolação ambiente |
| **Orquestração** | Docker Compose | Multi-container local |
| **Cloud** | Oracle Cloud Free Tier | PostgreSQL 20GB always-free |
| **App Distribution** | Google Play Store | Deploy Android final |

---

### **5. SERVIÇOS EXTERNOS (APIs)**

| Serviço | Propósito | Autenticação |
|---------|----------|--------------|
| **Firebase** | Autenticação OAuth (Google/Apple) | Service Account |
| **OpenAI** | GPT-4/3.5 turbo para LLM | API Key |
| **Anthropic** | Claude API para LLM alternativo | API Key |
| **Grok** | Grok LLM (via API OpenAI-compatível) | API Key |
| **Google Gemini** | Google's LLM (Luna - chat financeiro) | API Key |
| **Twilio** | SMS para contatos de emergência | Account SID + Token |

---

## 📦 Dependências por Camada

### **Frontend - Top Packages**
```
firebase_core (4.7.0)
firebase_auth (6.4.0)
provider (6.1.0)
table_calendar (3.0.9)
fl_chart (1.2.0)
flutter_local_notifications (21.0.0)
shared_preferences (2.2.2)
http (1.1.0)
```

### **Backend - Top Packages**
```
express (4.18.2)
sequelize (6.35.2)
firebase-admin (12.1.0)
openai (4.52.7)
@anthropic-ai/sdk (0.9.1)
jsonwebtoken (9.0.2)
bcryptjs (2.4.3)
twilio (4.10.0)
jest (29.7.0)
```

---

## 🔧 Requisitos Mínimos - macOS

### **Hardware**
- **Processador:** Intel Core i5 ou Apple Silicon M1+
- **RAM:** 8GB (mínimo), 16GB recomendado
- **Armazenamento:** 20GB livres (backend + frontend + emulator)
- **Internet:** Conexão estável para APIs

### **Software**
- **macOS:** 12.0+ (Monterey+)
- **Node.js:** 18.0.0+
- **npm:** 9.0.0+
- **Docker Desktop:** Última versão
- **Flutter:** 3.0.0+
- **Dart:** 3.0.0+ (vem com Flutter)
- **Git:** 2.x
- **Xcode Command Tools:** xcrun funcionando

### **Instalação Rápida (Homebrew)**
```bash
brew install node@18 git flutter docker
```

---

## 📈 Versões Mínimas Suportadas

| Componente | Mínimo | Recomendado | Máximo |
|-----------|--------|------------|--------|
| Node.js | 18.0.0 | 20.x | - |
| npm | 9.0.0 | 10.x | - |
| Flutter | 3.0.0 | 3.19+ | <4.0.0 |
| Dart | 3.0.0 | 3.1+ | <4.0.0 |
| Docker | 20.x | 24.x+ | - |
| PostgreSQL | 12.0 | 14+ | 15+ |
| Android SDK | 31 | 33+ | - |

---

## 🚀 Performance Esperada

### **Frontend**
- **Build APK (debug):** ~2-3 minutos
- **Build APK (release):** ~5-8 minutos
- **Hot reload:** ~1-2 segundos
- **Tamanho APK (release):** ~40-60MB

### **Backend**
- **Startup:** ~2 segundos
- **Resposta API REST:** <500ms (local)
- **Chat com LLM:** ~800ms-2s (depende da API)
- **Testes Jest:** ~10-30 segundos (completos)

### **Database**
- **Query simples:** <50ms
- **Histórico 7 dias (100 msgs):** <200ms
- **Insert transação:** <100ms

---

## 🔐 Segurança

### **Frontend**
- ✅ Firebase Auth (OAuth seguro)
- ✅ JWT tokens com validade
- ✅ SharedPreferences para dados sensíveis
- ⚠️ Nunca armazenar chaves de API

### **Backend**
- ✅ Helmet (security headers)
- ✅ bcryptjs (password hashing)
- ✅ express-validator (input sanitization)
- ✅ CORS configurado
- ✅ Rate limiting (via middleware)
- ✅ Environment variables para secrets

### **Database**
- ✅ PostgreSQL com autenticação
- ✅ Firewall (Docker default)
- ✅ Backup automático (Cloud)
- ✅ Prepared statements (Sequelize)

---

## 📚 Documentação Relacionada

- **CLAUDE.md** - Guia de arquitetura e padrões de projeto
- **INSTALL_macOS.md** - Guia passo-a-passo de instalação
- **backend/README.md** - Setup específico backend
- **frontend/README.md** - Setup específico frontend

---

## ✅ Checklist de Stack Completo

**Backend:**
- [ ] Node.js 18+ instalado
- [ ] npm 9+ instalado
- [ ] PostgreSQL 14 (Docker) rodando
- [ ] Sequelize configurado
- [ ] Firebase Admin SDK conectado
- [ ] OpenAI/Anthropic chaves configuradas

**Frontend:**
- [ ] Flutter 3+ instalado
- [ ] Android SDK/Emulator configurado
- [ ] Firebase configurado
- [ ] Provider state management funcionando
- [ ] HTTP client conectando ao backend

**Infraestrutura:**
- [ ] Git configurado
- [ ] Docker Desktop aberto
- [ ] GitHub Actions pronto
- [ ] .env files configurados (sem secrets em git)

---

**Documento de Referência Rápida**
**Data:** 26 de Maio de 2026
**Versão do Projeto:** 1.0.0
