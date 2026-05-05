import express from 'express';
import healthRoutes from './health.js';
import authRoutes from './auth.js';
import usersRoutes from './users.js';
import eventsRoutes from './events.js';
import accountsRoutes from './accounts.js';
import incomeRoutes from './income.js';
import expensesRoutes from './expenses.js';

const router = express.Router();

// ====================================
// API Routes
// ====================================

// Health Check
router.use('/health', healthRoutes);

// Auth routes (Épico 2)
router.use('/auth', authRoutes);

// User routes (Épico 2)
router.use('/users', usersRoutes);

// Events routes (Épico 3)
router.use('/events', eventsRoutes);

// Finance routes (Épico 4)
router.use('/accounts', accountsRoutes);
router.use('/income', incomeRoutes);
router.use('/expenses', expensesRoutes);

// Transactions routes (will be added in Épico 4)
// router.use('/transactions', transactionsRoutes);

// Chat routes (will be added in Épico 5)
// router.use('/chats', chatsRoutes);

export default router;
