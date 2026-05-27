# MiAjudAI — Plano UX/UI Completo v2.0
> Senior Product Design + Frontend Architecture · 26/05/2026

---

## 1. Diagnóstico Atual

### Inconsistências Visuais Encontradas
| Problema | Onde | Impacto |
|---|---|---|
| Cores hardcoded (`#6B7280`, `#2C2C2C`, `#D1D5DB`, `#1E6091`) | login, signup, welcome | **Alto** |
| `CustomButton` e `CustomTextField` existem mas são ignorados | Todas as telas de auth | **Alto** |
| `_buildLabel()` duplicado | login_screen + signup_screen | Médio |
| `_inputDecoration()` duplicado | login_screen + signup_screen | Médio |
| `_logout dialog` duplicado | welcome_screen + home_screen | Médio |
| Border radius inconsistente: constants=8, auth usa 10 e 12 | Todo o app | **Alto** |
| `AppColors.textPrimary = azul brand` (semanticamente confuso para texto) | constants.dart | Médio |
| Login usa `TextField`, Signup usa `TextFormField` | auth screens | **Alto** |
| `HomeScreen` com 4 tabs nunca acessada no fluxo real | home_screen.dart | Baixo |
| Sem família tipográfica definida no pubspec | pubspec.yaml | Médio |

### Problemas de UX Identificados
| Problema | Tela | Prioridade |
|---|---|---|
| Login sem validação por campo — apenas SnackBar genérico | Login | **Alta** |
| Sem animação de entrada nas telas de auth | Login, Signup | Média |
| "Esqueci minha senha" não funciona | Login | Média |
| Agentes de IA usam ícones genéricos (não logos reais) | Welcome | **Alta** |
| Welcome sem rodapé de navegação por agentes | Welcome | **Alta** |
| Sem indicador de força de senha | Signup | Média |

### Componentes Duplicados
1. `_buildLabel()` → em login_screen.dart e signup_screen.dart
2. `_inputDecoration()` → em login_screen.dart e signup_screen.dart
3. `_logout dialog` → em welcome_screen.dart e home_screen.dart
4. Botão primário gradient → definido de 3 formas diferentes (CustomButton, inline splash, inline auth)

---

## 2. Design System

### Princípios Fundamentais

1. **Consistência primeiro** — nenhum valor visual fora dos tokens em `constants.dart`
2. **Hierarquia clara** — o usuário identifica o primário, secundário e terciário em menos de 1 segundo
3. **Respiro generoso** — espaçamento mínimo 16px, máximo 48px entre seções
4. **Feedback imediato** — toda interação tem resposta visual (cor, animação, haptic)
5. **Mobile-first** — touch targets mínimos de 44×44px, thumb-zone navigation

---

## 3. Tipografia

### Família Tipográfica
**Sistema:** Roboto (Android) / SF Pro Display (iOS) — nativas do sistema, excelente em telas mobile.
**Upgrade futuro:** adicionar `google_fonts: Inter` ao pubspec para consistência cross-platform.

### Escala
| Token | Tamanho | Peso | Letter-Spacing | Uso Principal |
|---|---|---|---|---|
| `displayLarge` | 32px | 700 | -0.5 | Títulos de onboarding |
| `displayMedium` | 28px | 700 | -0.5 | Hero titles principais |
| `displaySmall` | 24px | 700 | -0.3 | Section headers grandes |
| `headlineMedium` | 22px | 700 | -0.3 | Título do card de formulário |
| `headlineSmall` | 18px | 600 | 0 | Subtítulos de seção |
| `titleMedium` | 16px | 600 | 0 | Labels de cards, botões |
| `titleSmall` | 14px | 500 | 0.1 | Labels de input |
| `bodyMedium` | 14px | 400 | 0 | Texto corrido, descrições |
| `bodySmall` | 12px | 400 | 0 | Texto auxiliar, hints |
| `labelMedium` | 12px | 500 | 0.5 | Badges, chips, tags |

### Regras
- `letterSpacing: -0.3 a -0.5` em títulos grandes (≥22px) para aparência premium
- `height: 1.5` em corpo de texto para legibilidade
- Nunca fonte abaixo de 12px em UI visível
- Hierarquia de cor: `textDark → textPrimary → textLabel → textSecondary → textHint`

---

## 4. Paleta de Cores (ver COLOR_GUIDE.md para detalhes)

### Cores Brand (mantidas)
- `#1B4965` — Azul MiAjudAI (identidade, estrutura, confiança)
- `#FF8C00` — Laranja accent (CTAs, destaques, energia)

### Novos Tokens Adicionados
- `#0D2740` — `primaryDeep` (ponta escura do gradiente hero)
- `#1C1C2E` — `textDark` (títulos, texto de input digitado)
- `#6B7280` — `textLabel` (labels de campos, subtítulos)
- `#E5E7EB` — `inputBorder` (borda padrão de inputs)
- `#F9FAFB` — `inputFill` (fundo levemente cinza de inputs)

---

## 5. Espaçamentos

### Escala (múltiplos de 4px)
```
4px  → paddingXSmall  (micro: ícone + texto)
8px  → paddingSmall   (label → campo, gap interno)
12px → padding3       (entre cards menores)
16px → paddingDefault (padding lateral de telas)
20px → padding5       (entre campos de formulário)
24px → paddingMedium  (padding horizontal de cards grandes)
28px → padding7       (padding interno de hero card form)
32px → paddingLarge   (entre blocos de seção)
48px → paddingXLarge  (seções hero, espaço inicial)
```

### Aplicação Específica
- **Telas:** `horizontal: 24px`, `vertical-top: 24px`, `vertical-bottom: safe-area`
- **Cards feature:** `padding: all 20px`
- **Form card:** `padding: fromLTRB(28, 32, 28, 32)`
- **Entre campos:** `20px vertical`
- **Label → campo:** `8px vertical`
- **Entre seções:** `24–32px`

---

## 6. Border Radius

| Token | Valor | Uso |
|---|---|---|
| `radiusSmall` | 4px | Badges, chips mínimos |
| `radiusDefault` | 8px | Botões outline pequenos |
| `radiusMedium` | 12px | (mantido, cards internos) |
| `radiusInput` | 12px | **Todos os campos de texto** |
| `radiusButton` | 14px | **Botão primário CTA** |
| `radiusLarge` | 16px | Cards de feature |
| `radiusCard` | 20px | Cards premium / agentes |
| `radiusXLarge` | 24px | Modal bottom sheets |
| `radiusHeroCard` | 28px | Card que sobe sobre o hero |
| `radiusFull` | 999px | Avatares circulares |

---

## 7. Sombras

### Sistema de 3 Níveis
```
Nível 1 — Sutil (cards no fundo de páginas)
  color: rgba(0,0,0,0.04)  blurRadius: 8   offset: (0, 2)

Nível 2 — Interativo (feature cards, agent cards clicáveis)
  color: rgba(0,0,0,0.08)  blurRadius: 16  offset: (0, 4)

Nível 3 — Elevado (bottom sheets, modais)
  color: rgba(0,0,0,0.12)  blurRadius: 32  offset: (0, -4)
```

---

## 8. Componentização

### Componentes Criados/Atualizados nesta Fase

#### `AuthField` · `lib/widgets/auth/auth_field.dart` *(NOVO)*
Campo compartilhado para Login e Signup. Substitui `_buildLabel + _inputDecoration` duplicados.
```
Propriedades:
  label: String          ← texto acima do campo
  hint: String           ← placeholder
  prefixIcon: IconData   ← ícone à esquerda (muda cor ao focar)
  isPassword: bool       ← toggle de visibilidade
  validator: Function    ← validação inline com erro abaixo
  keyboardType           ← tipo de teclado
  onChanged: Function    ← callback de mudança
```

#### `CustomButton` · `lib/widgets/common/custom_button.dart` *(EVOLUÍDO)*
Botão primário do app com suporte a gradient, outlined e loading.
```
Variante primary:  gradiente #FF8C00 → #FFAA33, radius 14px
Variante outlined: borda #1B4965, fundo transparente
Estado isLoading:  substitui label por CircularProgressIndicator
```

### Componentes a Criar na Fase 2

#### `AgentBottomNav` · `lib/widgets/navigation/agent_bottom_nav.dart`
Rodapé de navegação com logos reais dos agentes (Luna, Otto, Tina).

#### `UnderConstructionDialog` · `lib/widgets/dialogs/`
Dialog padronizado de "em construção" substituindo implementações inline.

#### `LogoutDialog` · `lib/widgets/dialogs/`
Dialog de logout substituindo duplicação em WelcomeScreen e HomeScreen.

---

## 9. Padrões de Botões

### Hierarquia Visual
1. **Primary Gradient** — ação principal única por tela
   - Gradiente `#FF8C00 → #FFAA33`, height 52px, radius 14px, full-width
2. **Secondary Solid** — confirmações, ações importantes secundárias
   - Background `#1B4965`, texto branco, height 48px
3. **Outlined** — ações secundárias não-destrutivas
   - Borda `#1B4965`, texto `#1B4965`, height 48px
4. **Text/Link** — ações terciárias
   - Texto accent ou primary, sem borda, sem background
5. **Destructive** — logout, deletar
   - Texto `#EF4444`, sem background

### Estados dos Botões
```
Default → (tap down) scale 0.97 → (tap up) action + scale 1.0
Loading: label substituído por CircularProgressIndicator branco
Disabled: backgroundColor gray[300], opacity 0.6
```

---

## 10. Inputs

### Anatomia Completa
```
Label               ← 13px, w500, #6B7280 (textLabel)
[gap: 8px]
┌─────────────────────────────────────┐
│ 🔒  Sua senha              [👁]     │  ← altura: 52px
└─────────────────────────────────────┘
   ↑ prefixIcon (18px, muda para #FF8C00 ao focar)
   ↑ fill: #F9FAFB (inputFill)
   ↑ border: #E5E7EB (inputBorder), 1px
   ↑ focus border: #FF8C00, 2px
Erro: mensagem em 12px #EF4444       ← só aparece após tentativa de submit
```

### Estados
| Estado | Borda | Fill | Icon |
|---|---|---|---|
| Idle | #E5E7EB 1px | #F9FAFB | #6B7280 |
| Focused | #FF8C00 2px | #F9FAFB | #FF8C00 |
| Error | #EF4444 1px | #FFF5F5 | #EF4444 |
| Disabled | #E5E7EB 1px | #F3F4F6 | #D1D5DB |

---

## 11. Cards

### Feature Card (WelcomeScreen)
```
┌──────────────────────────────────────────┐
│  ┌────────┐                              │
│  │ ICON   │  Título do feature     →     │
│  │ (bg/10)│  Descrição breve            │
│  └────────┘                              │
└──────────────────────────────────────────┘
padding: 20px all · radius: 16px · shadow: nível 2
Ícone container: 56×56px, radius 12px, background color/10
```

### Agent Card (Hub de Agentes — Fase 2)
```
┌─────────────────────┐
│    ┌───────────┐    │
│    │  [Logo]   │    │
│    │  Agent    │    │   ← 56×56px logo PNG transparente
│    └───────────┘    │
│      "Luna"         │
│    Financeiro       │
└─────────────────────┘
radius: 20px · animação escala ao selecionar
badge "em construção" canto superior direito (Otto, Tina)
```

---

## 12. Navegação

### Estrutura Atual → Proposta
```
Atual:
/ → /login → /welcome → [lista scroll de features]

Proposta:
/ → /login → /welcome (com AgentHub rodapé)
          └─ /signup

Welcome Hub:
  Tab 0: [Home] → overview do usuário
  Tab 1: [Luna 🐱] → /chat (financeiro, ativo)
  Tab 2: [Otto 🐙] → dialog "em construção" (cozinha)
  Tab 3: [Tina 🐷] → dialog "em construção" (doméstico)
```

### Bottom Navigation — Agent Hub (Fase 2)
- Altura: 72px + safe area bottom
- 4 itens: ícone Home + 3 logos de agentes (PNG com fundo transparente)
- Item ativo: fundo azul claro `#E8F4F8`, logo ligeiramente maior (scale 1.1)
- Transição: animação 200ms `Curves.easeOutCubic`

---

## 13. Animações

### Diretrizes
- Duração: 200–500ms (nunca acima de 600ms no fluxo principal)
- Curva padrão: `Curves.easeOutCubic`
- Curva de entrada: `Curves.easeOut`
- Bounce: apenas em splash/onboarding

### Animações por Tela
| Tela | Animação | Duração | Curva |
|---|---|---|---|
| Login | Form card slide-up + fade | 500ms | easeOutCubic |
| Signup | Form card slide-up + fade | 500ms | easeOutCubic |
| WelcomeScreen | Stagger dos cards (100ms delay cada) | 400ms | easeOut |
| Agent tab | Scale + color transition | 200ms | easeOut |
| Botão primário | Scale 0.97 ao pressionar | 100ms | linear |
| Dialog | Scale 0.95→1.0 + fade | 250ms | easeOutCubic |

---

## 14. Responsividade

### Breakpoints
- **360px** — Android compacto (Galaxy A series) — mínimo suportado
- **375px** — iPhone SE — design base para cálculos
- **390px** — iPhone 14 — design principal
- **430px+** — iPhones grandes, tablets — layout expande

### Regras
- Usar `MediaQuery` apenas para casos críticos (hero height, bottom safe area)
- Preferir `Flexible` / `Expanded` sobre larguras fixas
- `SafeArea` obrigatório em todas as telas
- Touch targets: mínimo 44×44px (Apple HIG e Material Design)
- Inputs: altura 52px (confortável para dedos)

---

## 15. Estratégia Visual

### Linguagem Visual MiAjudAI
- **Clean e minimalista** — fundo `#F5F5F7`, espaço em branco é elemento de design
- **Hierarquia por peso tipográfico** — bold = primário, regular = suporte
- **Azul = confiança e inteligência** (estrutura, navegação, brand)
- **Laranja = ação e energia** (CTAs, highlights, feedback positivo)
- **Branco = clareza** (cards, formulários, superfícies elevadas)
- **Gradiente hero** — dá profundidade premium às telas de auth

### Personalidade dos Agentes
| Agente | Personalidade | Accent Color | Status |
|---|---|---|---|
| Luna 🐱 | Sofisticada, inteligente | Azul `#1B4965` | Ativo |
| Otto 🐙 | Criativo, divertido | Laranja `#FF8C00` | Em construção |
| Tina 🐷 | Prática, confiável | Verde `#2D9B5A` | Em construção |

---

## 16. Fluxo do Usuário

### Autenticação
```
SplashScreen
  ├── [Entrar] → LoginScreen
  │     └── [Criar conta] → SignupScreen → WelcomeHub
  └── [Cadastrar-se] → SignupScreen
        └── [Já tem conta] → LoginScreen → WelcomeHub
```

### Hub Principal (Welcome)
```
WelcomeHub
  ├── [Home tab] → Cards de acesso rápido + resumo
  ├── [Luna tab] → FinancialChatScreen (/chat) ← ativo
  ├── [Otto tab] → UnderConstructionDialog
  └── [Tina tab] → UnderConstructionDialog
```

### Fluxo Financeiro (via Luna ou cards)
```
/chat → "Ver minhas contas" → /accounts
            ├── /income (receitas)
            └── /expenses (despesas)
/chat → "Calendário financeiro" → /calendar
```

---

## 17. Organização de Pastas

```
lib/
  config/
    constants.dart          ← tokens completos (ATUALIZADO)
    routes.dart             ← mapa de rotas
    firebase_config.dart

  models/                   ← sem mudanças

  providers/                ← sem mudanças

  services/                 ← sem mudanças

  utils/
    validators.dart
    responsive.dart

  widgets/
    auth/
      auth_field.dart       ← NOVO: campo compartilhado de auth
    common/
      custom_button.dart    ← EVOLUÍDO: suporte a gradient
      custom_textfield.dart ← mantido para telas internas
    navigation/             ← FASE 2
      agent_bottom_nav.dart
    dialogs/                ← FASE 2
      under_construction_dialog.dart
      logout_dialog.dart

  screens/
    auth/
      login_screen.dart     ← EVOLUÍDO
      signup_screen.dart    ← EVOLUÍDO
      onboarding_screen.dart
    home/
      welcome_screen.dart   ← EVOLUIR NA FASE 2
      dashboard_screen.dart
      finance_screen.dart
      services_screen.dart
      community_screen.dart
    chat/
      financial_chat_screen.dart
    calendar_screen.dart
    accounts_screen.dart
    income_screen.dart
    expenses_screen.dart
    splash_screen.dart
    manage_account_screen.dart
```

---

## 18. Plano de Execução

### Fase 1 — Concluída (aguardando aprovação)
- [x] Análise e diagnóstico completo
- [x] UX_UI_PLAN.md criado
- [x] COLOR_GUIDE.md criado
- [x] `constants.dart` atualizado com tokens completos
- [x] `AuthField` widget criado
- [x] `CustomButton` evoluído (gradient support)
- [x] `LoginScreen` reimplementado
- [x] `SignupScreen` reimplementado

### Fase 2 — Após aprovação da Fase 1
- [ ] Copiar logos dos agentes para `assets/images/`
- [ ] Criar `AgentBottomNav` widget
- [ ] Criar `UnderConstructionDialog` e `LogoutDialog`
- [ ] Evoluir `WelcomeScreen` → hub com AgentBottomNav
- [ ] Evoluir `SplashScreen` (corrigir anti-pattern de altura)
- [ ] Evoluir telas financeiras (Accounts, Income, Expenses)
- [ ] Evoluir `CalendarScreen`
- [ ] Evoluir `FinancialChatScreen`
- [ ] Decidir destino de `HomeScreen` (remover ou repropor)

### Fase 3 — Polimento Final
- [ ] Adicionar `google_fonts: Inter` ao pubspec
- [ ] Haptic feedback nas interações principais
- [ ] Testes de responsividade (360px–430px)
- [ ] Dark mode tokens (preparar estrutura)
- [ ] Acessibilidade WCAG AA (contraste, semântica)
