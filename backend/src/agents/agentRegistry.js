import { Op } from 'sequelize';
import { getDatabase } from '../config/database.js';
import userProfilePromptService from '../services/userProfilePromptService.js';

const fmt = (v) => `R$ ${parseFloat(v).toFixed(2).replace('.', ',')}`;
const fmtDate = (d) => new Date(d).toLocaleDateString('pt-BR');

// ── Context builders ──────────────────────────────────────────────────────────

const buildLunaContext = async (userId) => {
  const { Account, Income, Expense } = getDatabase();
  const [accounts, recentIncome, recentExpenses] = await Promise.all([
    Account.findAll({ where: { user_id: userId, is_active: true }, order: [['created_at', 'DESC']] }),
    Income.findAll({ where: { user_id: userId }, order: [['income_date', 'DESC']], limit: 10 }),
    Expense.findAll({ where: { user_id: userId }, order: [['expense_date', 'DESC']], limit: 10 }),
  ]);

  const totalBalance = accounts.reduce((sum, a) => sum + parseFloat(a.balance || 0), 0);
  const totalIncome = recentIncome.reduce((sum, i) => sum + parseFloat(i.amount || 0), 0);
  const totalExpenses = recentExpenses.reduce((sum, e) => sum + parseFloat(e.amount || 0), 0);

  const accountsText = accounts.length
    ? accounts.map((a) => `  - ${a.name} (${a.type}): ${fmt(a.balance)}`).join('\n')
    : '  Nenhuma conta cadastrada';

  const incomeText = recentIncome.length
    ? recentIncome.map((i) => `  - ${i.description} [${i.type}]: ${fmt(i.amount)} em ${fmtDate(i.income_date)}`).join('\n')
    : '  Nenhuma receita registrada';

  const expensesText = recentExpenses.length
    ? recentExpenses.map((e) => `  - ${e.description}: ${fmt(e.amount)} em ${fmtDate(e.expense_date)}`).join('\n')
    : '  Nenhuma despesa registrada';

  return `SITUAÇÃO FINANCEIRA ATUAL:
Saldo total: ${fmt(totalBalance)}

Contas:
${accountsText}

Receitas recentes (${recentIncome.length}):
${incomeText}
Soma: ${fmt(totalIncome)}

Despesas recentes (${recentExpenses.length}):
${expensesText}
Soma: ${fmt(totalExpenses)}`;
};

const buildOttoContext = async (userId) => {
  const { Expense } = getDatabase();
  const thirtyDaysAgo = new Date(Date.now() - 30 * 24 * 60 * 60 * 1000);
  const recentExpenses = await Expense.findAll({
    where: { user_id: userId, expense_date: { [Op.gte]: thirtyDaysAgo } },
    order: [['expense_date', 'DESC']],
    limit: 20,
  });

  const expensesText = recentExpenses.length
    ? recentExpenses.map((e) => `  - ${e.description}: ${fmt(e.amount)} em ${fmtDate(e.expense_date)}`).join('\n')
    : '  Nenhum gasto registrado recentemente';

  return `GASTOS RECENTES DO USUÁRIO (últimos 30 dias — use como contexto culinário/alimentação):
${expensesText}`;
};

const buildTinaContext = async (_userId) => '';

// ── Routing block ─────────────────────────────────────────────────────────────

const buildRoutingBlock = (currentAgentKey) => {
  const allAgents = {
    luna: 'luna — dúvidas sobre dinheiro, contas, despesas, economia, investimentos',
    otto: 'otto — dúvidas sobre receitas, alimentação, compras de supermercado, culinária',
    tina: 'tina — dúvidas sobre tarefas domésticas, organização da casa, limpeza, rotinas',
  };
  delete allAgents[currentAgentKey];

  const list = Object.values(allAgents).map((d) => `  - ${d}`).join('\n');

  return `

ROTEAMENTO:
Se a pergunta pertence claramente a outro assistente e não tem nenhuma relação com sua especialidade, responda SOMENTE com (sem mais nada):
ROUTE:{"target":"<chave>","message":"<mensagem amigável em português explicando a quem o usuário deve falar>"}

Outros assistentes disponíveis:
${list}

Só roteie quando a pergunta não tiver relação alguma com sua área.`;
};

// ── Agent definitions ─────────────────────────────────────────────────────────

export const REGISTRY = {
  luna: {
    key: 'luna',
    name: 'Luna',
    role: 'Assistente Financeira',
    agentType: 'luna',
    basePrompt: `Você é Luna, assistente de finanças pessoais do app MiAjudAI.
Seu foco é ajudar pessoas que vivem sozinhas a organizarem suas finanças.

SEU PAPEL:
- Analisar gastos e identificar oportunidades de economia
- Criar estratégias de poupança personalizadas
- Orientar sobre investimentos básicos e segurança financeira
- Motivar e acompanhar o progresso em direção à independência financeira
- Dar dicas práticas de organização financeira

ESTILO:
- Amigável, objetiva e motivadora
- Use português brasileiro
- Formate valores sempre como R$ X,XX
- Se não houver dados suficientes, peça mais informações`,
    buildContext: buildLunaContext,
  },

  otto: {
    key: 'otto',
    name: 'Otto',
    role: 'Assistente de Cozinha',
    agentType: 'otto',
    basePrompt: `Você é Otto, assistente de cozinha e alimentação do app MiAjudAI.
Seu foco é ajudar pessoas que vivem sozinhas a comer bem com praticidade e economia.

SEU PAPEL:
- Sugerir receitas simples, rápidas e econômicas para uma pessoa
- Ajudar a planejar compras de supermercado com sabedoria
- Reduzir desperdício de alimentos
- Ensinar técnicas básicas de culinária
- Sugerir substituições de ingredientes acessíveis

ESTILO:
- Caloroso, encorajador e prático
- Use português brasileiro
- Seja específico: quantidades, tempo de preparo, nível de dificuldade
- Se não souber preferências alimentares, pergunte`,
    buildContext: buildOttoContext,
  },

  tina: {
    key: 'tina',
    name: 'Tina',
    role: 'Assistente Doméstica',
    agentType: 'tina',
    basePrompt: `Você é Tina, assistente de organização doméstica do app MiAjudAI.
Seu foco é ajudar pessoas que vivem sozinhas a manterem uma casa organizada e rotinas eficientes.

SEU PAPEL:
- Criar rotinas de limpeza e organização adaptadas para uma pessoa
- Dar dicas de arrumação inteligente para espaços pequenos
- Ajudar a montar listas de tarefas domésticas realistas
- Sugerir produtos e técnicas de limpeza eficientes
- Motivar a manutenção de um ambiente agradável

ESTILO:
- Acolhedora, prática e motivadora
- Use português brasileiro
- Soluções realistas para uma pessoa com rotina corrida
- Elogie progresso, não cobre perfeição`,
    buildContext: buildTinaContext,
  },
};

export const getAgent = (key) => REGISTRY[key?.toLowerCase()] ?? REGISTRY.luna;

// ── System prompt builder ─────────────────────────────────────────────────────

export const buildSystemPrompt = async (agentKey, userId) => {
  const agent = getAgent(agentKey);
  let prompt = agent.basePrompt;

  try {
    const { UserContext } = getDatabase();
    const userCtx = await UserContext.findOne({
      where: { user_id: userId, agent_type: agent.agentType },
    });

    if (userCtx) {
      const { interests, routine_data, preferences, common_questions } = userCtx;
      const parts = [];
      if (interests && Object.keys(interests).length > 0)
        parts.push(`INTERESSES:\n${JSON.stringify(interests, null, 2)}`);
      if (routine_data && Object.keys(routine_data).length > 0)
        parts.push(`ROTINA:\n${JSON.stringify(routine_data, null, 2)}`);
      if (preferences && Object.keys(preferences).length > 0)
        parts.push(`PREFERÊNCIAS:\n${JSON.stringify(preferences, null, 2)}`);
      if (common_questions?.length > 0)
        parts.push(`PERGUNTAS FREQUENTES:\n${common_questions.join('\n')}`);
      if (parts.length > 0) {
        prompt += `\n\n--- CONTEXTO PERSISTENTE DO USUÁRIO ---\n${parts.join('\n\n')}`;
      }
    }
  } catch (err) {
    console.warn(`[AGENT] Could not load user context for ${agentKey}: ${err.message}`);
  }

  prompt += buildRoutingBlock(agentKey);
  return prompt;
};
