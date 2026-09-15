import express from 'express';
import jwt from 'jsonwebtoken';
import config from '../config/env.js';
import {
  verifyToken,
  getCurrentUser,
  updateProfile,
} from '../controllers/authController.js';
import { verifyToken as authMiddleware } from '../middleware/auth.js';

const router = express.Router();

router.post('/verify-token', verifyToken);
router.get('/me', authMiddleware, getCurrentUser);
router.put('/profile', authMiddleware, updateProfile);

export default router;
