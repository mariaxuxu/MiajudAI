import chatService from '../services/chatService.js';

const sendMessage = async (req, res) => {
  try {
    console.log('[CONTROLLER] POST /api/chat/financial received');
    const userId = req.user.userId;
    const { message, history = [] } = req.body;

    console.log(`[CONTROLLER] userId=${userId}, message length=${message?.length}, history length=${history?.length}`);

    if (!message || typeof message !== 'string' || !message.trim()) {
      console.warn('[CONTROLLER] Invalid message');
      return res.status(400).json({ error: 'message is required' });
    }

    if (!Array.isArray(history)) {
      console.warn('[CONTROLLER] Invalid history');
      return res.status(400).json({ error: 'history must be an array' });
    }

    console.log('[CONTROLLER] Calling chatService.sendMessage...');
    const reply = await chatService.sendMessage(userId, message.trim(), history);
    console.log('[CONTROLLER] Got response from chatService');

    return res.status(200).json({
      success: true,
      reply,
      timestamp: new Date().toISOString(),
    });
  } catch (error) {
    console.error('[CONTROLLER] Chat error:', error.message);
    console.error('[CONTROLLER] Error stack:', error.stack);
    return res.status(500).json({ error: 'Failed to get AI response', details: error.message });
  }
};

export default { sendMessage };
