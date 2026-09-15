# MiAjudAI - Cronograma de Evolução (4 Meses) - Versão Detalhada

**Período**: 5 de Agosto de 2026 - 23 de Novembro de 2026
**Equipe**: 3 Desenvolvedores (15 pts/semana cada = 45 pts/semana)
**Total**: 16 semanas × 45 pts = 720 story points
**Status**: Planejamento de alto nível — aguardando detalhamento de user stories

---

## 🎯 Prioridades Estratégicas

### P1: Upgrade LLM - User Profile Tracking (CRÍTICO)
Rastrear perfil do usuário diariamente baseado em uso real no app. Cada entrada em chat LLM envia perfil atualizado para melhorar respostas personalizadas.

**Por quê**: Diferenciador principal — LLMs mais inteligentes = maior engagement

### P2: MiAjudAki - Plataforma de Serviços (INOVAÇÃO)
Novo marketplace integrado: contratar eletricistas, diaristas, encanadores, etc.

**Por quê**: Expande MiAjudAI além de assistência virtual para serviços reais

### P3: SMS Emergency Contact (SEGURANÇA)
Enviar SMS quando contatando emergência — crítico para segurança do usuário

**Por quê**: Garante que contatos de emergência recebam notificação imediata

---

## 📅 Timeline Completa (16 Semanas)

### **FASE 1: User Profile Tracking Architecture (Semanas 1-3 | 135 pts)**

#### Épico 1.1: Profile Data Model & Collection

**Sprint 1 (Semana de 05/08 - 17/08)**

| Dev | Escopo | Responsabilidades |
|-----|--------|-------------------|
| **Backend** | Schema e Data Model | Criar tabelas `user_profile_snapshots` e `user_behavior_logs` no PostgreSQL |
| **Frontend** | Behavior Tracking | Implementar hooks para rastrear: telas visitadas, tempo gasto em cada tela, ações do usuário (clicks, submissões) |
| **DevOps** | Infraestrutura | Setup de logging pipeline, monitoramento de evento ingestion |

**Story Points**: 45
**Saída**: Schema pronto, hooks de tracking no frontend enviando eventos ao backend

---

**Sprint 2 (Semana de 18/08 - 24/08)**

| Dev | Escopo | Responsabilidades |
|-----|--------|-------------------|
| **Backend** | Profile Service | Criar job diário que computa: interesses (baseado em chats), padrões de uso (horas mais ativas), preferências (extrair de contexto) |
| **Frontend** | Event Integration | Confirmar que eventos estão chegando ao backend, validar payload |
| **DevOps** | Monitoring | Setup de alertas para falhas no job de profile computation |

**Story Points**: 45
**Saída**: Profile computado diariamente com accuracy baseline

---

**Sprint 3 (Semana de 25/08 - 31/08)**

| Dev | Escopo | Responsabilidades |
|-----|--------|-------------------|
| **Backend** | LLM Integration | Modificar `chatService.js` para: 1) buscar profile diário 2) incluir em system prompt Luna/Otto/Tina 3) validar impacto em token count |
| **Frontend** | Chat Service Update | Atualizar para receber profile context, nenhuma mudança visual |
| **DevOps** | Testing & Monitoring | Testes de integração (behavior log → profile → LLM), performance baseline |

**Story Points**: 45
**Saída**: Profile atualizado automaticamente em cada chat, LLM responde usando contexto

---

### **FASE 2: Advanced Analytics Dashboard (Semanas 4-6 | 135 pts)**

#### Épico 2.1: Personal Analytics & Insights

**Sprint 4 (Semana de 01/09 - 07/09)**

| Dev | Escopo | Responsabilidades |
|-----|--------|-------------------|
| **Backend** | Analytics APIs | Criar endpoints: `GET /api/analytics/spending` (gastos por categoria), `GET /api/analytics/trends` (últimos 30 dias), `GET /api/analytics/habits` (padrões) |
| **Frontend** | Dashboard Screen | Nova tela "Analytics" com: cards de spending total, gráficos de pizza (por categoria), sparklines (últimos 7 dias) |
| **DevOps** | Caching | Implementar Redis cache para analytics (TTL 1 hora), estratégia de invalidação |

**Story Points**: 45
**Saída**: Dashboard MVP com 3-5 métricas principais

---

**Sprint 5 (Semana de 08/09 - 14/09)**

| Dev | Escopo | Responsabilidades |
|-----|--------|-------------------|
| **Backend** | Predictive Model | Implementar forecast de gastos (próximos 30 dias): usar histórico 90 dias, média móvel, sazonalidade |
| **Frontend** | Prediction Charts | Visualizar: spending forecast em gráfico de linha, comparação real vs. previsto |
| **DevOps** | Performance | Otimizar queries de analytics, adicionar índices no DB, profiling |

**Story Points**: 45
**Saída**: Previsões de gastos aparecendo no dashboard com ±10% accuracy

---

**Sprint 6 (Semana de 15/09 - 21/09)**

| Dev | Escopo | Responsabilidades |
|-----|--------|-------------------|
| **Backend** | Habit Tracking | Computar métricas: refeições planejadas (via Otto), exercícios (extrair de chats/contexto), padrões de sono (futuro: wearable integration) |
| **Frontend** | Wellness Dashboard | Nova section: Streaks (dias consecutivos de hábito X), charts de progresso, badges de achievement |
| **DevOps** | Analytics Pipeline | Atualizar data pipeline para hábitos, monitoramento de acurácia |

**Story Points**: 45
**Saída**: Dashboard completo com insights personalizados + previsões + wellness

---

### **FASE 3: SMS Emergency Alert System (Semanas 7-8 | 90 pts)**

#### Épico 3.1: Emergency SMS Notifications

**Sprint 7 (Semana de 22/09 - 28/09)**

| Dev | Escopo | Responsabilidades |
|-----|--------|-------------------|
| **Backend** | Twilio Integration | Integrar Twilio API: conta, autenticação, serviço de SMS, template system |
| **Frontend** | Emergency Button | Adicionar botão na HomeScreen: "Chamar Emergência", com modal de confirmação (nome do contato, mensagem customizável) |
| **DevOps** | SMS Monitoring | Setup de webhooks Twilio para delivery status, logging de SMS enviados |

**Story Points**: 45
**Saída**: SMS enviado quando acionado, com feedback visual

---

**Sprint 8 (Semana de 29/09 - 05/10)**

| Dev | Escopo | Responsabilidades |
|-----|--------|-------------------|
| **Backend** | Retry Logic & Compliance | Implementar: 3 tentativas de envio, delay exponencial, log de todas as tentativas, GDPR compliance |
| **Frontend** | Status Tracking UI | Tela de histórico: "Emergências acionadas", status de SMS (enviado, entregue, falhou), timestamp |
| **DevOps** | Alert System | Thresholds para alertar ops: SMS delivery failure > 5%, retry exhaustion |

**Story Points**: 45
**Saída**: SMS robusto com retry, delivery confirmation, compliance logging

---

### **PHASE 4: MiAjudAki Platform - MVP Foundation (Semanas 9-14 | 270 pts)**

#### Épico 4.1-4.3: Marketplace Architecture, Provider Mgmt, Booking & Payment

**Sprint 9 (Semana de 06/10 - 12/10)**

| Dev | Escopo | Responsabilidades |
|-----|--------|-------------------|
| **Backend** | Data Model | Criar tabelas: `services` (id, name, category, description, avg_price), `providers` (id, service_id, name, phone, rating, location, verified_at), `bookings` (id, user_id, provider_id, date, time, status, payment_id) |
| **Frontend** | App Structure | Decidir: nova app "MiAjudAki" ou deep link em MiAjudAI? Setup inicial, navigation |
| **DevOps** | Infrastructure | Docker setup para novo serviço (se app separada), staging environment |

**Story Points**: 45
**Saída**: Schema pronto, app structure definida

---

**Sprint 10 (Semana de 13/10 - 19/10)**

| Dev | Escopo | Responsabilidades |
|-----|--------|-------------------|
| **Backend** | Provider Auth & Listing | Fluxo de login provider, API `GET /api/services` (listar categorias), `GET /api/services/{category}/providers` (filtrar por categoria) |
| **Frontend** | Browse UI | Telas: Categories screen (eletricista, diarista, encanador, etc.), Provider list com cards (foto, nome, rating, preço/hora) |
| **DevOps** | Staging | Deploy de teste, monitoring setup |

**Story Points**: 45
**Saída**: Browseable marketplace com 3-5 categorias

---

**Sprint 11 (Semana de 20/10 - 26/10)**

| Dev | Escopo | Responsabilidades |
|-----|--------|-------------------|
| **Backend** | Provider Management | Fluxo de registro: email, verificação via OTP, profile data (foto, bio, horários), sistema de rating (1-5 stars), reviews |
| **Frontend** | Provider Profile | Tela detalhada: foto, nome, rating, reviews, calendar de disponibilidade, botão "Contratar" |
| **DevOps** | Verification Workflow | Automação: enviar OTP, validade 15min, notify ops para verificação de documentos |

**Story Points**: 45
**Saída**: Provider registration completo, profile públicos

---

**Sprint 12 (Semana de 27/10 - 02/11)**

| Dev | Escopo | Responsabilidades |
|-----|--------|-------------------|
| **Backend** | Search & Filter | APIs: `GET /api/providers?category=X&location=Y&minRating=Z&maxPrice=W` (com elasticsearch ou indexed queries) |
| **Frontend** | Search Screen | Filtros: categoria, localização (map view com pins), rating slider, preço, sort (rating, preço, distância) |
| **DevOps** | Indexing | Otimizar queries de search, considerar Elasticsearch para scale |

**Story Points**: 45
**Saída**: Search/filter funcional, UX de descoberta

---

**Sprint 13 (Semana de 03/11 - 09/11)**

| Dev | Escopo | Responsabilidades |
|-----|--------|-------------------|
| **Backend** | Booking & Payment API | Criar booking: `POST /api/bookings` (user_id, provider_id, date, time), Payment gateway: Stripe ou PagSeguro? |
| **Frontend** | Booking Flow | Fluxo: 1) Confirmação (data/hora), 2) Inserir dados (descrição serviço), 3) Checkout (card, digital wallet), 4) Confirmação |
| **DevOps** | Payment Gateway | Integração Stripe/PagSeguro, webhook handling, PCI compliance |

**Story Points**: 45
**Saída**: Primeira booking + pagamento possível

---

**Sprint 14 (Semana de 10/11 - 16/11)**

| Dev | Escopo | Responsabilidades |
|-----|--------|-------------------|
| **Backend** | Order History & Refunds | APIs: `GET /api/bookings` (histórico), `POST /api/bookings/{id}/cancel` (com refund), status tracking (agendado, confirmado, concluído, cancelado) |
| **Frontend** | Tracking & Notifications | Tela "Meus Pedidos": status atual, timeline de status, botão cancelar, in-app notifications |
| **DevOps** | Webhook Management | Twilio/Stripe webhooks para status changes, retry logic, error handling |

**Story Points**: 45
**Saída**: MVP do marketplace completo — usuários podem contratar + rastrear serviços

---

### **PHASE 5: Polish, Testing & Optimization (Semanas 15-16 | 90 pts)**

#### Épico 5.1: Integration, QA & Performance

**Sprint 15 (Semana de 17/11 - 19/11)**

| Dev | Escopo | Responsabilidades |
|-----|--------|-------------------|
| **Backend** | Integration Tests | Testes: Profile → LLM (context sendo usado?), Analytics → Dashboard (dados corretos?), SMS → Delivery (SMS chegando?), Booking → Payment (transação completa?) |
| **Frontend** | E2E Tests | Testes de user flow: login → profile acumulado → chat com contexto → browse marketplace → booking → order tracking |
| **DevOps** | Performance | DB optimization (índices, query plans), load testing (100 concurrent users), profiling de endpoints lentos |

**Story Points**: 45
**Saída**: 70%+ test coverage, latência p95 < 500ms

---

**Sprint 16 (Semana de 20/11 - 23/11)**

| Dev | Escopo | Responsabilidades |
|-----|--------|-------------------|
| **Backend** | Security Audit | Verificar: SMS não expõe números, payments são PCI compliant, emergency contacts validados, rate limiting em APIs, OWASP Top 10 |
| **Frontend** | UI/UX Polish | Refinamentos finais: acessibilidade (contrast, font sizes), animations, offline mode preparado |
| **DevOps** | Release | Deploy v2.0 to Play Store, release notes, rollback procedures, monitoring setup |

**Story Points**: 45
**Saída**: v2.0 pronto para Play Store com todos os recursos

---

## 📊 Distribuição de Story Points por Fase

| Fase | Semanas | Story Points | % do Total | Dev Backend | Dev Frontend | DevOps |
|------|---------|-------------|-----------|------------|-------------|--------|
| P1 - User Profile Tracking | 1-3 | 135 | 18.75% | 45 | 45 | 45 |
| P2 - Analytics Dashboard | 4-6 | 135 | 18.75% | 45 | 45 | 45 |
| P3 - Emergency SMS | 7-8 | 90 | 12.5% | 30 | 30 | 30 |
| P4 - MiAjudAki MVP | 9-14 | 270 | 37.5% | 90 | 90 | 90 |
| P5 - Polish & QA | 15-16 | 90 | 12.5% | 30 | 30 | 30 |
| **TOTAL** | **16** | **720** | **100%** | **240** | **240** | **240** |

---

## 👥 Alocação Detalhada por Developer

### Dev Backend (15 pts/semana × 16 semanas = 240 pts)
- **Semanas 1-3**: Schema de user profile, job de computation, integração LLM
- **Semanas 4-6**: APIs de analytics, modelo preditivo, habit tracking
- **Semanas 7-8**: Integração Twilio, retry logic, compliance
- **Semanas 9-14**: Arquitetura marketplace, provider auth, search, booking, payment
- **Semanas 15-16**: Testes de integração, security audit, otimização DB

### Dev Flutter (15 pts/semana × 16 semanas = 240 pts)
- **Semanas 1-3**: Hooks de tracking, events ao backend, chat service update
- **Semanas 4-6**: Dashboard screens, charts, analytics UI, wellness streaks
- **Semanas 7-8**: Emergency button, confirmation UI, SMS history tracking
- **Semanas 9-14**: MiAjudAki UI (browse, provider profiles, booking flow, payment checkout)
- **Semanas 15-16**: E2E tests, UI polish, acessibilidade, release prep

### Dev Ops/QA (15 pts/semana × 16 semanas = 240 pts)
- **Semanas 1-3**: Event logging pipeline, monitoring de profile computation
- **Semanas 4-6**: Redis caching, query optimization, performance baseline
- **Semanas 7-8**: SMS webhook management, delivery tracking, compliance logging
- **Semanas 9-14**: Marketplace infrastructure, payment gateway integration, staging env
- **Semanas 15-16**: Load testing, security audit, release automation, monitoring

---

## 📍 Marcos Principais

| Marco | Data | Critério de Sucesso | Dev Responsável |
|-------|------|--------|-----------------|
| **M1** | 31/08/2026 | User profile salvo diariamente, LLM recebendo contexto automático em chats | Backend + DevOps |
| **M2** | 21/09/2026 | Dashboard com 5+ analytics, previsões funcionando com ±10% accuracy | Backend + Frontend |
| **M3** | 05/10/2026 | SMS enviado quando acionado, delivery confirmado, retry logic testado | Backend + DevOps |
| **M4** | 19/10/2026 | MiAjudAki browsable, 3+ categorias, 10+ providers de teste | Frontend + Backend |
| **M5** | 16/11/2026 | Primeira booking completa com pagamento processado com sucesso | Backend + DevOps |
| **M6** | 23/11/2026 | v2.0 no Play Store, 70%+ test coverage, latência p95 < 500ms | DevOps + Todos |

---

## 🚨 Riscos & Mitigação

| Risco | Probabilidade | Impacto | Mitigação | Owner |
|-------|--------------|---------|-----------|-------|
| Profile computation lento (queries pesadas) | Média | Alto | Usar async jobs, cache, índices no DB, profiling cedo | Backend |
| MiAjudAki scope creep (mais categorias, features) | Alta | Alto | MVP strict: 3 categorias, pagamento básico, review system depois | PO/Backend |
| SMS delivery falha ou latência | Baixa | Crítico | Twilio é confiável, mas implementar retry 3x, fallback email | Backend |
| Performance analytics em escala | Média | Médio | Materialized views, data archival (6 meses), query optimization | DevOps |
| Payment integration delays (Stripe/PagSeguro) | Média | Alto | Integrar cedo (Sprint 13), usar sandbox para testes, ter backup | Backend |
| Flutter build size crescendo | Média | Médio | Lazy loading de screens, treeshaking, monitorar APK size | Frontend |
| User adoption de marketplace baixa | Alta | Estratégico | Lançar com 20+ providers, incentivos early adopters, marketing | PO |

---

## 🔧 Detalhes Técnicos Iniciais (Será Expandido)

### P1 - User Profile Tracking

**Database Schema**:
```sql
CREATE TABLE user_profile_snapshots (
  id UUID PRIMARY KEY,
  user_id UUID NOT NULL,
  date DATE NOT NULL,
  profile_json JSONB, -- {interests, patterns, preferences, sentiment}
  created_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(user_id, date)
);

CREATE TABLE user_behavior_logs (
  id UUID PRIMARY KEY,
  user_id UUID NOT NULL,
  event_type VARCHAR (50), -- "screen_view", "chat_message", "click", etc
  screen VARCHAR(100),
  metadata JSONB, -- {duration, button_name, etc}
  timestamp TIMESTAMP DEFAULT NOW(),
  created_at TIMESTAMP DEFAULT NOW(),
  INDEX(user_id, created_at)
);
```

**Job Diário (Job Service)**:
```javascript
// backend/src/jobs/profileSnapshotJob.js
- Roda às 23:59 UTC
- Para cada usuário ativo em 24h:
  - Busca user_behavior_logs de hoje
  - Computa: horas mais ativas, telas visitadas, chats por agente
  - Extrai interests de Luna/Otto/Tina chats
  - Insere em user_profile_snapshots
```

**LLM System Prompt Update**:
```javascript
const systemPrompt = `
Você é Luna, especialista em finanças pessoais.

Contexto do usuário hoje:
- Padrão de gasto: ${profile.spending_pattern}
- Interesses financeiros: ${profile.financial_interests}
- Horas mais ativas: ${profile.peak_hours}
- Sentimento: ${profile.sentiment}

Responda personalizadamente baseado nisso.
`;
```

### P3 - SMS Emergency

**SMS Template**:
```
Emergência acionada!
Usuário: {user_name}
Hora: {time}
Localização: {city}
App: MiAjudAI
Mensagem: {custom_message}

Clique para responder: {link}
```

**Twilio Setup**:
- Account SID: from env
- Auth Token: from env
- Phone number: +55 (to be provisioned)
- Webhook: `POST /api/webhooks/sms-status`

### P4 - MiAjudAki

**Service Categories (MVP)**:
1. Eletricista (electrical services)
2. Diarista (domestic cleaning)
3. Encanador (plumbing)
4. (Others: pedreiro, pintor, after MVP)

**Database Schema**:
```sql
-- Services & Providers
CREATE TABLE services (
  id UUID PRIMARY KEY,
  name VARCHAR(100), -- "Eletricista"
  category VARCHAR(50),
  description TEXT,
  avg_price DECIMAL(10,2),
  created_at TIMESTAMP
);

CREATE TABLE providers (
  id UUID PRIMARY KEY,
  service_id UUID,
  name VARCHAR(100),
  phone VARCHAR(20),
  email VARCHAR(100),
  location POINT, -- Geo location
  rating DECIMAL(3,2), -- 1-5
  reviews_count INT,
  verified_at TIMESTAMP,
  created_at TIMESTAMP
);

CREATE TABLE bookings (
  id UUID PRIMARY KEY,
  user_id UUID,
  provider_id UUID,
  service_date DATE,
  service_time TIME,
  status ENUM('pending', 'confirmed', 'completed', 'cancelled'),
  payment_id VARCHAR(100), -- Stripe payment_intent
  amount DECIMAL(10,2),
  notes TEXT,
  created_at TIMESTAMP
);
```

**Payment Provider**:
- Stripe (global) ou PagSeguro (Brazil-focused) — TBD em Sprint 13

---

## 📌 Próximos Passos Imediatos

1. **Antes de Sprint 1 (próxima semana)**:
   - [ ] Validar datas com equipe
   - [ ] Detailed user stories para cada sprint (AC, wireframes)
   - [ ] Setup Jira com cronograma
   - [ ] Kickoff meeting com 3 devs

2. **Sprint 1 Kickoff**:
   - [ ] Começar com schema + hooks de tracking
   - [ ] Setup de evento logging (Datadog/Grafana?)
   - [ ] First profile snapshot em 3 dias

3. **Review Points**:
   - Sprint 3: Profile funcionando? LLM melhorou?
   - Sprint 6: Analytics útil? Previsões acuradas?
   - Sprint 8: SMS confiável?
   - Sprint 14: Marketplace pronto para beta?

---

## 📊 Resumo Executivo

- **Duração**: 4 meses (16 sprints de 1 semana)
- **Equipe**: 3 devs (45 pts/semana = 240 pts cada dev)
- **Total**: 720 story points distribuídos
- **Foco Principal**: User profile tracking (diferenciador LLM) + MiAjudAki marketplace
- **Release**: v2.0 com profile tracking + SMS + MVP marketplace
- **Diferenciais**:
  - Personalisação LLM melhorada dia a dia
  - Marketplace integrado (nova revenue stream)
  - SMS seguro para emergências

---

**Documento criado**: 5 de Agosto de 2026
**Status**: Planejamento de alto nível — aguardando detalhamento de user stories
**Próxima revisão**: Após kickoff com equipe
