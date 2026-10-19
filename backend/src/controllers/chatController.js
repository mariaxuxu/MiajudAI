import chatService from '../services/chatService.js';

const sendMessage = async (req, res) => {
  try {
    console.log('[CONTROLLER] POST /api/chat recebido');
    const userId = req.user.userId;
    const { message, history = [], agent = 'luna' } = req.body;

    if (!message || typeof message !== 'string' || !message.trim()) {
      console.warn('[CONTROLLER] Mensagem inválida');
      return res.status(400).json({ error: 'message is required' });
    }

    if (!Array.isArray(history)) {
      console.warn('[CONTROLLER] History inválido');
      return res.status(400).json({ error: 'history must be an array' });
    }

    console.log(`[CONTROLLER] userId=${userId}, agent=${agent}, message.length=${message.length}`);
    const result = await chatService.sendMessage(userId, agent, message.trim(), history);

    return res.status(200).json({
      success: true,
      ...result,
      timestamp: new Date().toISOString(),
    });
  } catch (error) {
    console.error('[CONTROLLER] Chat error:', error.message);
    console.error('[CONTROLLER] Stack:', error.stack);
    return res.status(500).json({ error: 'Failed to get AI response', details: error.message });
  }
};

export default { sendMessage };
