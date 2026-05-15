import chatService from '../services/chatService.js';

const sendMessage = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { message, history = [] } = req.body;

    if (!message || typeof message !== 'string' || !message.trim()) {
      return res.status(400).json({ error: 'message is required' });
    }

    if (!Array.isArray(history)) {
      return res.status(400).json({ error: 'history must be an array' });
    }

    const reply = await chatService.sendMessage(userId, message.trim(), history);

    return res.status(200).json({
      success: true,
      reply,
      timestamp: new Date().toISOString(),
    });
  } catch (error) {
    console.error('Chat error:', error.message);
    return res.status(500).json({ error: 'Failed to get AI response' });
  }
};

export default { sendMessage };
