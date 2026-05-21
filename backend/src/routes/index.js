import express from 'express';
import healthRoutes from './health.js';
import authRoutes from './auth.js';
import usersRoutes from './users.js';
import eventsRoutes from './events.js';
import accountsRoutes from './accounts.js';
import incomeRoutes from './income.js';
import expensesRoutes from './expenses.js';
import chatRoutes from './chat.js';

const router = express.Router();

// ====================================
// API Routes
// ====================================

router.use('/health', healthRoutes);
router.use('/auth', authRoutes);
router.use('/users', usersRoutes);
router.use('/events', eventsRoutes);
router.use('/accounts', accountsRoutes);
router.use('/income', incomeRoutes);
router.use('/expenses', expensesRoutes);
router.use('/chat', chatRoutes);

export default router;
