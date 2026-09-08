import { Router } from 'express';
import * as installmentController from '../controllers/installmentController.js';
import { verifyToken } from '../middleware/auth.js';

const router = Router();

router.get('/', verifyToken, installmentController.getInstallments);
router.get('/monthly-total', verifyToken, installmentController.getMonthlyTotal);
router.get('/:id', verifyToken, installmentController.getInstallmentById);
router.post('/', verifyToken, installmentController.createInstallment);
router.put('/:id', verifyToken, installmentController.updateInstallment);
router.delete('/:id', verifyToken, installmentController.deleteInstallment);

export default router;
