import axios from 'axios';
import config from '../config/env.js';
import { getAgent, buildSystemPrompt } from '../agents/agentRegistry.js';
import userProfilePromptService from './userProfilePromptService.js';

const GROQ_BASE_URL = 'https://api.groq.com/openai/v1';

const parseRoute = (text) => {
  if (!text?.startsWith('ROUTE:')) return null;
  try {
    return JSON.parse(text.slice(6).trim());
  } catch {
    return null;
  }
};

const sendMessage = async (userId, agentKey = 'luna', message, history = []) => {
  console.log(`\n[CHAT] ═══════════════════════════════════════════`);
  console.log(`[CHAT] agent=${agentKey}, userId=${userId}`);

  if (!config.gemini.apiKey) throw new Error('GEMINI_API_KEY not configured');

  const agent = getAgent(agentKey);

  const [systemPrompt, agentContext, diaryContext] = await Promise.all([
    buildSystemPrompt(agentKey, userId),
    agent.buildContext(userId),
    userProfilePromptService.buildDiaryContext(userId, agentKey, 800),
  ]);

  console.log(
    `[CHAT] ✓ Prompts prontos — system=${systemPrompt.length}c, context=${agentContext.length}c, diary=${diaryContext.length}c`
  );

  const messages = [{ role: 'system', content: systemPrompt }];

  if (history.length === 0) {
    const contextParts = [agentContext, diaryContext].filter(Boolean).join('\n\n');
    if (contextParts) {
      messages.push({
        role: 'user',
        content: `[CONTEXTO - NÃO MOSTRAR AO USUÁRIO]\n\n${contextParts}`,
      });
      messages.push({ role: 'assistant', content: '[CONTEXTO MEMORIZADO]' });
    }
  } else {
    messages.push(
      ...history.map((h) => ({ role: h.isUser ? 'user' : 'assistant', content: h.text }))
    );
  }

  messages.push({ role: 'user', content: message });

  const payload = {
    model: config.gemini.model,
    messages,
    temperature: 0.7,
    max_tokens: 1024,
  };

  console.log(`[CHAT] 📤 Enviando ao Groq: ${messages.length} mensagens`);
  const startTime = Date.now();

  const response = await axios.post(`${GROQ_BASE_URL}/chat/completions`, payload, {
    headers: {
      'Content-Type': 'application/json',
      Authorization: `Bearer ${config.gemini.apiKey}`,
    },
    timeout: 30000,
  });

  console.log(`[CHAT] ✓ Groq respondeu em ${Date.now() - startTime}ms`);

  const reply = response.data?.choices?.[0]?.message?.content;
  if (!reply) throw new Error('Empty response from Groq');

  const route = parseRoute(reply);
  if (route) {
    console.log(`[CHAT] → Roteando para ${route.target}`);
    console.log(`[CHAT] ═══════════════════════════════════════════\n`);
    return { routed: true, target: route.target, message: route.message };
  }

  console.log(`[CHAT] 💬 Resposta: ${reply.substring(0, 80)}...`);
  console.log(`[CHAT] ═══════════════════════════════════════════\n`);
  return { routed: false, reply };
};

export default { sendMessage };
