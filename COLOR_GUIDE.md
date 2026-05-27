# COLOR_GUIDE — MiAjudAI
> Guia completo de cores · versão 2.0 · 26/05/2026

Todas as cores do aplicativo são definidas em `lib/config/constants.dart` na classe `AppColors`.
**Nunca use valores hexadecimais hardcoded nas telas.** Sempre use os tokens desta lista.

---

## Cores Primárias (Brand)

| Token | Hex | Preview | Onde usar |
|---|---|---|---|
| `AppColors.primary` | `#1B4965` | 🟦 | Azul brand. AppBar, hero background, títulos brand, ícones de navegação, borda de botão outlined. |
| `AppColors.primaryDark` | `#0F2A3D` | 🟦 | Azul mais escuro. Estados hover/pressed do primary, overlay de headers. |
| `AppColors.primaryDeep` | `#0D2740` | 🟦 | Ponta inicial do gradiente hero nas telas de auth. Dá profundidade ao fundo. |

---

## Cores de Destaque (Accent)

| Token | Hex | Preview | Onde usar |
|---|---|---|---|
| `AppColors.accent` | `#FF8C00` | 🟧 | Laranja principal. Botão CTA primário, foco de inputs, links de ação, ícones de destaque. |
| `AppColors.accentDark` | `#E67E00` | 🟧 | Ponta final do gradiente do botão primary. Estados pressed do accent. |

---

## Texto

| Token | Hex | Preview | Onde usar |
|---|---|---|---|
| `AppColors.textDark` | `#1C1C2E` | ⬛ | Títulos de formulários, texto digitado em inputs, conteúdo principal em fundo branco. Contraste máximo. |
| `AppColors.textPrimary` | `#1B4965` | 🟦 | Texto com identidade de brand. Títulos em fundo claro que devem ter "personalidade" (ex: saudações, subtítulos de seção). |
| `AppColors.textLabel` | `#6B7280` | 🩶 | Labels acima de inputs, subtítulos de cards, texto de suporte. |
| `AppColors.textSecondary` | `#9CA3AF` | 🩶 | Texto auxiliar, descrições menores, timestamps. |
| `AppColors.textHint` | `#C4C9D4` | ⬜ | Placeholder de inputs, dicas visuais de preenchimento. |

---

## Background & Superfícies

| Token | Hex | Preview | Onde usar |
|---|---|---|---|
| `AppColors.background` | `#F5F5F7` | ⬜ | Fundo geral de todas as telas internas (pós-login). |
| `AppColors.surface` | `#FFFFFF` | ⬜ | Cards, formulários, modal sheets, qualquer superfície elevada. |
| `AppColors.inputFill` | `#F9FAFB` | ⬜ | Fundo dos campos de texto. Levemente cinza para indicar área interativa. |
| `AppColors.primarySurface` | `#E8F4F8` | 🔵 | Fundo de itens selecionados/ativos no hub de agentes. |

---

## Bordas & Divisores

| Token | Hex | Preview | Onde usar |
|---|---|---|---|
| `AppColors.inputBorder` | `#E5E7EB` | ⬜ | Borda padrão (idle) de todos os campos de texto. |
| `AppColors.divider` | `#E8E8E8` | ⬜ | Linhas separadoras entre itens de lista, seções. |

---

## Feedback / Estados

| Token | Hex | Preview | Onde usar |
|---|---|---|---|
| `AppColors.success` | `#22C55E` | 🟢 | Confirmações, validações positivas, indicadores de receita. |
| `AppColors.warning` | `#F59E0B` | 🟡 | Alertas não-críticos, avisos de limite de orçamento. |
| `AppColors.error` | `#EF4444` | 🔴 | Erros de validação, saldo negativo, ações destrutivas. |
| `AppColors.info` | `#3B82F6` | 🔵 | Mensagens informativas, tooltips. |

---

## Agentes de IA

| Agente | Token accent | Hex | Background claro |
|---|---|---|---|
| Luna (financeiro) | `AppColors.primary` | `#1B4965` | `#E8F4F8` |
| Otto (cozinha) | `AppColors.accent` | `#FF8C00` | `#FFF8F0` |
| Tina (doméstico) | `AppColors.tina` | `#2D9B5A` | `#EAF7EF` |

---

## Gradientes

### Gradiente Hero (telas de auth)
```dart
LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomCenter,
  colors: [AppColors.primaryDeep, AppColors.primary],
  // #0D2740 → #1B4965
)
```
**Uso:** Área hero das telas Login e Signup. Dá profundidade e premium feel.

### Gradiente Botão Primary
```dart
LinearGradient(
  colors: [AppColors.accent, AppColors.accentDark],
  // #FF8C00 → #E67E00
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
)
```
**Uso:** Botão CTA principal em todas as telas (entrar, criar conta, salvar).

### Gradiente Splash (feature highlights)
```dart
LinearGradient(
  colors: [
    Color(0xFF1B4965).withValues(alpha: 0.05),
    Color(0xFFFF8C00).withValues(alpha: 0.05),
  ],
)
```
**Uso:** Fundo decorativo da splash screen.

---

## Regras de Contraste (WCAG AA)

| Par de cores | Contraste | Status |
|---|---|---|
| `textDark` (#1C1C2E) sobre `surface` (#FFFFFF) | 18.1:1 | ✅ AAA |
| `textPrimary` (#1B4965) sobre `surface` (#FFFFFF) | 8.7:1 | ✅ AA |
| `textLabel` (#6B7280) sobre `surface` (#FFFFFF) | 4.6:1 | ✅ AA |
| Texto branco sobre `primary` (#1B4965) | 8.7:1 | ✅ AA |
| Texto branco sobre `accent` (#FF8C00) | 3.0:1 | ⚠️ AA (apenas ≥18px bold) |
| `textSecondary` (#9CA3AF) sobre `surface` | 2.9:1 | ⚠️ Apenas texto auxiliar ≥12px |

> **Regra:** Nunca use `textHint` (#C4C9D4) para texto informativo — apenas placeholders.

---

## Como Adicionar uma Nova Cor

1. Defina o token em `AppColors` dentro de `lib/config/constants.dart`
2. Adicione à tabela neste documento com hex, uso e contexto
3. Se for uma cor de agente ou categoria, adicione também na seção "Agentes de IA"
4. Nunca remova uma cor sem verificar todos os usos com `grep -r "AppColors.nomeDaCor"`
