import express from 'express';
import {
  verifyToken,
  getCurrentUser,
  updateProfile,
} from '../controllers/authController.js';
import { verifyToken as authMiddleware } from '../middleware/auth.js';

const router = express.Router();

// Public routes
router.post('/verify-token', verifyToken);

// Protected routes
router.get('/me', authMiddleware, getCurrentUser);
router.put('/profile', authMiddleware, updateProfile);

export default router;
