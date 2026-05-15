import express from 'express';
import chatController from '../controllers/chatController.js';
import { verifyToken } from '../middleware/auth.js';

const router = express.Router();

router.post('/financial', verifyToken, chatController.sendMessage);

export default router;
