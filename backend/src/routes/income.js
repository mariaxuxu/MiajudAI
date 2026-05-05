import express from 'express';
import {
  getIncome,
  getIncomeById,
  createIncome,
  updateIncome,
  deleteIncome,
  getMonthlyTotal,
} from '../controllers/incomeController.js';
import { verifyToken } from '../middleware/auth.js';

const router = express.Router();

router.get('/', verifyToken, getIncome);
router.get('/monthly-total', verifyToken, getMonthlyTotal);
router.get('/:id', verifyToken, getIncomeById);
router.post('/', verifyToken, createIncome);
router.put('/:id', verifyToken, updateIncome);
router.delete('/:id', verifyToken, deleteIncome);

export default router;
