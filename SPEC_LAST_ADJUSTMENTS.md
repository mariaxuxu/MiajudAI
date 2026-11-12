# Spec: Ajustes finais de apresentação (TCC)

**Date:** 2026-11-12
**Status:** ✅ Ready for implementation (4 ajustes)
**Branch:** `feat/last-adjustments-app`

---

## Problem Statement

Quatro problemas pontuais, cada um atrapalhando a demonstração para a banca:

1. **Os agentes não se apresentam.** Quando o usuário cumprimenta Otto, Luna ou Tina, o agente responde sobre o assunto, mas não deixa claro **quais informações pessoais ele tem acesso**. O avaliador não consegue perceber, na hora, que aquele agente é a "persona ideal" para aquele domínio — porque nada no prompt instrui o agente a revelar isso.
2. **A área de finanças está fragmentada.** O `WelcomeScreen` tem dois cards separados para finanças — **"Finanças"** (contas) e **"Dashboard / Fatura"** (parcelas e gastos fixos) — apesar de serem dois lados da mesma área. A demonstração fica confusa.
3. **O login estoura no celular.** Ao abrir o teclado para digitar email/senha, em aparelho físico, a tela de login apresenta overflow (faixa de erro), porque o campo focado não tem folga configurada acima do teclado (`scrollPadding`).
4. **Card morto.** O card **"Serviços Externos"** só abre um diálogo "em construção" e não será implementado; ele polui a Home sem propósito.

## Solution

Quatro ajustes pequenos e independentes:

1. **Transparência na saudação.** Adicionar ao `basePrompt` de cada agente uma instrução para que, **na primeira mensagem (saudação)**, o agente se apresente e **liste, de forma amigável, as informações pessoais a que tem acesso** — para o usuário saber que ele é a persona ideal para auxiliá-lo. A mudança é só de texto no `basePrompt`; nada muda em `buildContext`, no `chatService` nem no bundle de contexto oculto.

2. **Card único de finanças.** Substituir os dois cards por um único card **"Finanças e Faturas"**, que abre uma tela com três abas — **Contas | Parcelas | Dashboard** — reunindo as duas telas atuais sem remover nenhuma funcionalidade. Receitas e Despesas continuam como atalhos dentro da aba Contas.

3. **`scrollPadding` no login.** Expor o `scrollPadding` no `AuthField` e configurá-lo nos campos de email e senha da tela de login, para que o campo focado suba com folga confortável acima do teclado.

4. **Remover "Serviços Externos".** Retirar o card do `WelcomeScreen`. Com a união dos cards de finanças e essa remoção, a grade final fica com **4 cards** (Calendário, Meu Diário, Finanças e Faturas, Despensa) — 2×2, sem célula vazia.

## User Stories

**Ajuste 1 — Transparência dos agentes na saudação**

1. Como usuário, ao cumprimentar a Luna, quero que ela se apresente e me diga que tem acesso às minhas contas e saldos, receitas e despesas, para eu saber que ela é a pessoa certa para me ajudar com finanças.
2. Como usuário, ao cumprimentar o Otto, quero que ele se apresente e me diga que tem acesso aos itens da minha despensa de cozinha e aos meus gastos recentes com alimentação, para eu saber que ele é o assistente certo para a cozinha.
3. Como usuário, ao cumprimentar a Tina, quero que ela se apresente e me diga que tem acesso aos itens da minha despensa de produtos domésticos e às minhas anotações de diário sobre a casa, para eu saber que ela é a pessoa certa para organização doméstica.
4. Como usuário, quero que essa apresentação aconteça **apenas na primeira mensagem** (saudação), para que o agente não repita a lista a cada resposta.
5. Como usuário, quero que o agente **só liste o que ele realmente acessa**, para que a demonstração não exponha uma promessa falsa à banca.
6. Como desenvolvedor, quero que a instrução fique no `basePrompt` de cada agente (e não no contexto dinâmico), para que a regra valha para qualquer conversa sem alterar o mecanismo de injeção de contexto.
7. Como desenvolvedor, quero que a instrução esteja no **system prompt** de cada agente (Luna, Otto e Tina), mantendo o texto em português brasileiro e o tom de cada persona.
8. Como desenvolvedor, quero que a mudança não exija alterar `buildContext`, `chatService` nem o bundle de contexto oculto, para manter o ajuste mínimo e isolado.

**Ajuste 2 — Card único de finanças**

9. Como usuário, quero ver **um** card de finanças na Home (chamado "Finanças e Faturas") em vez de dois, para encontrar tudo de finanças em um lugar só.
10. Como usuário, quero que o card "Finanças e Faturas" abra uma tela com abas **Contas | Parcelas | Dashboard**, para acessar contas, parcelamentos e gastos fixos sem sair da área.
11. Como usuário, quero continuar vendo minhas contas (saldo, "Nova Conta") na aba **Contas**, para não perder nenhuma funcionalidade que eu já tinha.
12. Como usuário, quero continuar acessando **Receitas** e **Despesas** a partir da aba Contas, para não perder os atalhos existentes.
13. Como usuário, quero continuar gerenciando minhas **Parcelas** na aba Parcelas, para não perder a funcionalidade atual.
14. Como usuário, quero continuar acompanhando meus **gastos fixos** na aba Dashboard, para não perder a funcionalidade atual.
15. Como usuário, quero que a tela use o design system existente (tokens semânticos, tipografia, tabs), para que pareça parte do app.
16. Como desenvolvedor, quero que a nova tela reutilize o conteúdo das telas atuais como corpo das abas, para não reimplementar CRUD já existente.
17. Como desenvolvedor, quero substituir os dois `_CardData` (Finanças e Dashboard/Fatura) por um único no `WelcomeScreen`, para que a lista de cards reflita a união.
18. Como desenvolvedor, quero que a animação de fade dos cards seja **derivada de `cards.length`** (e não de um número fixo 6), para não estourar o índice quando a quantidade de cards mudar.

**Ajuste 3 — Login no teclado**

19. Como usuário, quero que, ao abrir o teclado no celular, o campo de email/senha suba com **folga confortável** acima do teclado, para digitar sem a faixa de overflow.
20. Como desenvolvedor, quero expor o parâmetro `scrollPadding` no `AuthField` e repassá-lo ao `TextFormField`, para controlar a folga do campo focado sem quebrar os demais usos do widget.
21. Como desenvolvedor, quero configurar um `scrollPadding` adequado nos campos de email e senha da tela de login, para que o comportamento do teclado seja consistente.

**Ajuste 4 — Remover "Serviços Externos"**

22. Como usuário, quero não ver mais o card "Serviços Externos" na Home, para a tela refletir só o que está disponível.
23. Como usuário, quero que a Home continue com os demais cards (Calendário, Meu Diário, Finanças e Faturas, Despensa), para não perder acesso a nada que existe.

## Implementation Decisions

### Transparência dos agentes

- A instrução entra no **`basePrompt`** de cada agente, como um parágrafo adicional na seção de papel/estilo — não no `buildContext` nem no `chatService`. O `basePrompt` é o texto enviado como `system` em toda mensagem; a instrução é **redigida para disparar só na saudação** ("Na sua primeira mensagem…"), então não repete a lista a cada turno.
- O texto de cada agente lista **exatamente** os dados que o `buildContext` daquele agente já injeta hoje (ver mapeamento abaixo). Nada é inventado — a transparência acompanha a realidade do que o agente acessa.

| Agente | Dados que o agente realmente acessa (via `buildContext` + despensa/diário) |
|---|---|
| Luna | Contas e saldos; receitas recentes; despesas recentes |
| Otto | Itens da Despensa de cozinha (`food`); gastos recentes com alimentação |
| Tina | Itens da Despensa de produtos domésticos (`domestic`); anotações de diário sobre a casa |

- Frases propostas (entram no `basePrompt`, em português, no tom da persona):

  - **Luna:** "Na sua primeira mensagem, apresente-se e deixe claro que você tem acesso às contas e saldos, às receitas e às despesas recentes do usuário, para que ele saiba que você é a assistente ideal para organizar as finanças dele."
  - **Otto:** "Na sua primeira mensagem, apresente-se e deixe claro que você tem acesso aos itens da despensa de cozinha e aos gastos recentes com alimentação, para que ele saiba que você é o assistente ideal para a cozinha."
  - **Tina:** "Na sua primeira mensagem, apresente-se e deixe claro que você tem acesso aos itens da despensa de produtos domésticos e às anotações de diário sobre a casa, para que ele saiba que você é a assistente ideal para a organização doméstica."

- A instrução não conflita com o rótulo "[CONTEXTO - NÃO MOSTRAR AO USUÁRIO]" do bundle oculto: aquele rótulo pede para não **despejar o bloco cru**; a instrução nova pede para **resumir de forma amigável** o que está acessível. A lista na saudação é produzida a partir dos dados presentes no contexto oculto da primeira mensagem (que é quando os dados dinâmicos são injetados).

### Card único de finanças

- Criar uma **tela combinada** de finanças com três abas: **Contas**, **Parcelas** e **Dashboard** (mantendo o nome "Dashboard" para a aba de gastos fixos, como hoje).
- O corpo de cada aba **reutiliza o conteúdo das telas atuais**: a aba Contas corresponde à tela de contas (com "Nova Conta" e atalhos Receitas/Despesas); as abas Parcelas e Dashboard correspondem às duas abas da tela de fatura atual. Não há reimplementação de CRUD.
- No `WelcomeScreen`, os dois `_CardData` (Finanças → contas; Dashboard/Fatura → fatura) são substituídos por **um** `_CardData` "Finanças e Faturas" que navega para a tela combinada.
- A contagem de fades dos cards passa a ser **dinâmica (`cards.length`)**, removendo o número mágico `6` que hoje assume a quantidade antiga de cards.

### Login (`scrollPadding`)

- O `AuthField` ganha um parâmetro `scrollPadding` (com default igual ao do Flutter, `EdgeInsets.all(20)`), repassado ao `TextFormField` interno. Nenhum outro uso do widget é afetado.
- Os campos de email e senha da tela de login passam um `scrollPadding` maior (ex.: folga inferior de ~24–32px), para o campo focado subir com espaço acima do teclado.
- **Escopo limitado:** só `scrollPadding`, conforme decisão do usuário. Se, ao testar no aparelho, ainda aparecer a faixa de overflow, a mitigação seguinte (fora deste escopo) é ocultar/encolher o rodapé decorativo quando o teclado abre.

### Remoção do card

- Remover o `_CardData` "Serviços Externos" do `WelcomeScreen`. O diálogo "em construção" associado não é removido (pode ser usado por outros pontos); só o card sai.
- Grade resultante: **4 cards** (Calendário, Meu Diário, Finanças e Faturas, Despensa), 2×2, sem célula vazia — portanto **não há necessidade de centralizar** a última linha.

## Testing Decisions

- **O que é um bom teste:** verificar **comportamento observável** — o texto do prompt contém a instrução e a lista correta; o card certo aparece/não aparece; a navegação e as abas funcionam; o campo leva o `scrollPadding` configurado — sem acoplar a detalhes internos (SQL, queries, renderização de pixels específicos).
- **Seam backend (mais alto, puro):** o `REGISTRY` exportado do registro de agentes. Os testes leem `REGISTRY.luna.basePrompt`, `REGISTRY.otto.basePrompt` e `REGISTRY.tina.basePrompt` diretamente (sem banco) e verificam: (a) a presença da instrução de transparência; (b) a lista de dados específica de cada agente (Luna menciona contas/saldo/receitas/despesas; Otto menciona despensa de cozinha e gastos com alimentação; Tina menciona despensa de produtos domésticos e diário); (c) a ausência de dados que o agente **não** acessa. É o ponto mais alto que não exige harness de banco, que o projeto não possui.
- **Seam frontend:** testes de widget.
  - `WelcomeScreen`: o card "Finanças e Faturas" está presente e navega para a tela combinada; os cards "Finanças" e "Dashboard / Fatura" separados **não** aparecem mais; "Serviços Externos" **não** aparece; os 4 cards restantes estão presentes.
  - Tela combinada de finanças: as três abas (Contas | Parcelas | Dashboard) alternam o conteúdo e mantêm os atalhos Receitas/Despesas na aba Contas.
  - Login: os campos de email/senha renderizam com o `scrollPadding` configurado.
- **Prior art:**
  - Backend: `backend/test/services/userProfilePromptService.test.js` (testa builders de texto puros) e `backend/test/services/pantryService.test.js` (service com models mockados).
  - Frontend: `frontend/test/welcome_screen_test.dart`, `frontend/test/auth_screens_test.dart`, `frontend/test/accounts_screen_test.dart`, `frontend/test/invoice_dashboard_screen_test.dart`, com os fakes em `frontend/test/support/` e o helper `pump_screen.dart`.
- **Verificação manual:** o comportamento real da saudação dos agentes (a resposta de fato lista os dados) é confirmado manualmente em conversa nova com cada agente, já que o LLM é externo e não é testado em unidade. A folga do teclado no aparelho físico é confirmada manualmente.

## Out of Scope

- **Reinjetar contexto a cada mensagem.** A transparência vale só na saudação; não há reenvio do contexto dinâmico em mensagens seguintes para "responder o que você sabe a qualquer momento".
- **"Lista de compras".** Não existe no app; o Otto divulga a **Despensa** (o que o usuário tem em casa), não uma lista de compras futura.
- **Ocultar/encolher o rodapé decorativo do login.** Fica como mitigação de fallback caso o `scrollPadding` não elimine a faixa de overflow no aparelho.
- **Unificar os modelos de dados** de contas e faturas no backend; a união é **só de navegação/UI**.
- **Redesenhar a tela combinada** além de abas reutilizando o conteúdo existente; nenhuma funcionalidade nova de finanças.
- **Remover o diálogo "em construção"** ou qualquer rota/tela de serviços legada (como a aba "Serviços" da Home legada, que não é o mesmo card).

## Further Notes

- **Por que a instrução vai no `basePrompt` e não no contexto oculto:** o `basePrompt` (system) é enviado em toda mensagem e estabelece comportamento; o contexto oculto (dados) é injetado uma vez por sessão. A instrução de "liste o que você acessa" é comportamento, então pertence ao `basePrompt` — mas é redigida para disparar só na primeira mensagem, casando com o momento em que os dados estão de fato no contexto.
- **Risco de o agente repetir a lista:** mitigado pela redação ("na sua primeira mensagem"). Se o modelo ainda repetir, o ajuste seria mover a instrução para o primeiro turno do contexto (fora deste escopo).
- **Consistência com o vocabulário:** "Agente" (não "bot/IA"), "System Prompt", "Despensa"/"Pantry Item", "WelcomeScreen", "Provider" seguem o `CONTEXT.md`.
- **Card único vs. telas:** as duas telas atuais continuam existindo no código; a tela combinada as **embute como abas**, em vez de apagá-las, para não quebrar rotas/atalhos já usados em outros pontos.
