import axios from 'axios';
import config from '../config/env.js';
import { getDatabase } from '../config/database.js';

const GEMINI_BASE_URL = 'https://generativelanguage.googleapis.com/v1beta/models';

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

const sendMessage = async (userId, message, history = []) => {
  if (!config.gemini.apiKey) {
    throw new Error('GEMINI_API_KEY not configured');
  }

  const systemPrompt = await buildFinancialContext(userId);

  const contents = [
    ...history.map((h) => ({
      role: h.isUser ? 'user' : 'model',
      parts: [{ text: h.text }],
    })),
    { role: 'user', parts: [{ text: message }] },
  ];

  const payload = {
    system_instruction: { parts: [{ text: systemPrompt }] },
    contents,
    generationConfig: {
      temperature: 0.7,
      maxOutputTokens: 1024,
    },
  };

  const url = `${GEMINI_BASE_URL}/${config.gemini.model}:generateContent?key=${config.gemini.apiKey}`;
  const response = await axios.post(url, payload, {
    headers: { 'Content-Type': 'application/json' },
    timeout: 30000,
  });

  const reply = response.data?.candidates?.[0]?.content?.parts?.[0]?.text;
  if (!reply) throw new Error('Empty response from Gemini');

  return reply;
};

export default { sendMessage };
