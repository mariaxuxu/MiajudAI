import axios from 'axios';
import config from '../config/env.js';
import { getDatabase } from '../config/database.js';

const GEMINI_BASE_URL = 'https://api.groq.com/openai/v1';

const buildFinancialContext = async (userId) => {
  const { Account, Income, Expense } = getDatabase();

  const [accounts, recentIncome, recentExpenses] = await Promise.all([
    Account.findAll({
      where: { user_id: userId, is_active: true },
      order: [['created_at', 'DESC']],
    }),
    Income.findAll({
      where: { user_id: userId },
      order: [['income_date', 'DESC']],
      limit: 10,
    }),
    Expense.findAll({
      where: { user_id: userId },
      order: [['expense_date', 'DESC']],
      limit: 10,
    }),
  ]);

  const totalBalance = accounts.reduce((sum, a) => sum + parseFloat(a.balance || 0), 0);
  const totalIncome = recentIncome.reduce((sum, i) => sum + parseFloat(i.amount || 0), 0);
  const totalExpenses = recentExpenses.reduce((sum, e) => sum + parseFloat(e.amount || 0), 0);

  const fmt = (v) => `R$ ${parseFloat(v).toFixed(2).replace('.', ',')}`;
  const fmtDate = (d) => new Date(d).toLocaleDateString('pt-BR');

  const accountsText = accounts.length
    ? accounts.map((a) => `  - ${a.name} (${a.type}): ${fmt(a.balance)}`).join('\n')
    : '  Nenhuma conta cadastrada';

  const incomeText = recentIncome.length
    ? recentIncome.map((i) => `  - ${i.description} [${i.type}]: ${fmt(i.amount)} em ${fmtDate(i.income_date)}`).join('\n')
    : '  Nenhuma receita registrada';

  const expensesText = recentExpenses.length
    ? recentExpenses.map((e) => `  - ${e.description}: ${fmt(e.amount)} em ${fmtDate(e.expense_date)}`).join('\n')
    : '  Nenhuma despesa registrada';

  return `Você é um assistente financeiro pessoal do app MiAjudAI, para pessoas que moram sozinhas no Brasil.
Seja amigável, objetivo e use português brasileiro. Formate valores sempre como R$ X,XX.
Quando não tiver dados suficientes, seja honesto e oriente o usuário a adicionar mais informações no app.

SITUAÇÃO FINANCEIRA ATUAL DO USUÁRIO:

Saldo total em contas: ${fmt(totalBalance)}

Contas cadastradas:
${accountsText}

Receitas recentes (últimas ${recentIncome.length}):
${incomeText}
Soma das receitas listadas: ${fmt(totalIncome)}

Despesas recentes (últimas ${recentExpenses.length}):
${expensesText}
Soma das despesas listadas: ${fmt(totalExpenses)}

Responda com base nesses dados reais. Seja direto e prático.`;
};

const buildSystemPrompt = async (userId) => {
  const { UserContext } = getDatabase();

  // System prompt base
  let systemPrompt = `Você é Luna, uma assistente especializada em finanças pessoais do app MiAjudAI.
Seu foco é ajudar pessoas que vivem sozinhas a organizarem suas finanças e atingirem a independência financeira.

SEU PAPEL:
- Analisar gastos e identificar oportunidades de economia
- Criar estratégias de poupança personalizadas
- Orientar sobre investimentos básicos e segurança financeira
- Motivar e acompanhar progresso em direção à independência financeira
- Dar dicas práticas de organização financeira (gestão de contas, categorização, etc)
- Sugerir ferramentas e métodos para melhorar controle financeiro
- Ser honesta e realista sobre a situação financeira do usuário

ESTILO:
- Amigável, objetiva e motivadora
- Use português brasileiro
- Formate valores sempre como R$ X,XX
- Se não houver dados suficientes, seja honesta e peça mais informações
- Crie planos e dicas práticas e alcançáveis

OBJETIVO DO USUÁRIO:
- Organização financeira pessoal
- Alcançar independência financeira`;

  // Busca contexto do usuário (persona)
  try {
    const userContext = await UserContext.findOne({ where: { user_id: userId, agent_type: 'luna' } });

    if (userContext) {
      const { interests, routine_data, preferences, common_questions } = userContext;

      const contextParts = [];

      if (interests && Object.keys(interests).length > 0) {
        contextParts.push(`\n\nINTERESES DO USUÁRIO:\n${JSON.stringify(interests, null, 2)}`);
      }

      if (routine_data && Object.keys(routine_data).length > 0) {
        contextParts.push(`\n\nROTINA FINANCEIRA:\n${JSON.stringify(routine_data, null, 2)}`);
      }

      if (preferences && Object.keys(preferences).length > 0) {
        contextParts.push(`\n\nPREFERÊNCIAS:\n${JSON.stringify(preferences, null, 2)}`);
      }

      if (common_questions && common_questions.length > 0) {
        contextParts.push(`\n\nPERGUNTAS FREQUENTES:\n${common_questions.join('\n')}`);
      }

      if (contextParts.length > 0) {
        systemPrompt += `\n\n--- CONTEXTO PERSISTENTE DO USUÁRIO (USE PARA PERSONALIZAR RESPOSTAS) ---${contextParts.join('')}`;
        console.log(`[CHAT] User context loaded (${contextParts.length} sections)`);
      }
    }
  } catch (error) {
    console.warn(`[CHAT] Could not load user context: ${error.message}`);
  }

  return systemPrompt;
};

const sendMessage = async (userId, message, history = []) => {
  console.log(`\n[CHAT] ═══════════════════════════════════════════`);
  console.log(`[CHAT] Starting sendMessage for userId=${userId}`);

  if (!config.gemini.apiKey) {
    throw new Error('GEMINI_API_KEY not configured');
  }

  console.log(`[CHAT] ✓ Building system prompt (Luna + user_context)...`);
  const systemPrompt = await buildSystemPrompt(userId);
  console.log(`[CHAT] ✓ System prompt ready (${systemPrompt.length} chars)`);

  console.log(`[CHAT] ✓ Building financial context...`);
  const startContextTime = Date.now();
  const financialContext = await buildFinancialContext(userId);
  console.log(`[CHAT] ✓ Financial context built in ${Date.now() - startContextTime}ms (${financialContext.length} chars)`);

  console.log(`[CHAT] ✓ Preparing message structure (${history.length} history items)`);

  const messages = [
    { role: 'system', content: systemPrompt },
  ];

  // Se é primeira mensagem do dia (history vazio), passar contexto financeiro escondido
  if (history.length === 0) {
    console.log(`[CHAT] ⚡ FIRST MESSAGE OF SESSION - Including financial context (hidden from user)`);
    messages.push({
      role: 'user',
      content: `[CONTEXTO FINANCEIRO - NÃO MOSTRAR AO USUÁRIO]\n${financialContext}`,
    });

    // Resposta escondida confirmando que memorizou
    messages.push({
      role: 'assistant',
      content: '[CONTEXTO MEMORIZADO]',
    });
    console.log(`[CHAT] ⚡ Context sent to Grok for memorization`);
  } else {
    // Não é primeira mensagem - apenas adiciona histórico visível
    console.log(`[CHAT] ℹ️  NOT first message - using history from previous messages`);
    messages.push(
      ...history.map((h) => ({
        role: h.isUser ? 'user' : 'assistant',
        content: h.text,
      }))
    );
  }

  // Adiciona mensagem atual do usuário
  messages.push({ role: 'user', content: message });

  const payload = {
    model: config.gemini.model,
    messages,
    temperature: 0.7,
    max_tokens: 1024,
  };

  const url = `${GEMINI_BASE_URL}/chat/completions`;
  console.log(`[CHAT] 📤 Sending to Grok: ${messages.length} messages total`);

  const startGeminiTime = Date.now();
  const response = await axios.post(url, payload, {
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${config.gemini.apiKey}`,
    },
    timeout: 30000,
  });
  const responseTime = Date.now() - startGeminiTime;
  console.log(`[CHAT] ✓ Grok responded in ${responseTime}ms`);

  const reply = response.data?.choices?.[0]?.message?.content;
  if (!reply) throw new Error('Empty response from Grok');

  console.log(`[CHAT] 💬 Response: ${reply.substring(0, 80)}...`);
  console.log(`[CHAT] ═══════════════════════════════════════════\n`);
  return reply;
};

export default { sendMessage };
