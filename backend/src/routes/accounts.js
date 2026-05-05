import express from 'express';
import {
  getAccounts,
  getAccountById,
  createAccount,
  updateAccount,
  deleteAccount,
} from '../controllers/accountController.js';
import { verifyToken } from '../middleware/auth.js';

const router = express.Router();

router.get('/', verifyToken, getAccounts);
router.get('/:id', verifyToken, getAccountById);
router.post('/', verifyToken, createAccount);
router.put('/:id', verifyToken, updateAccount);
router.delete('/:id', verifyToken, deleteAccount);

export default router;
