import { Router } from 'express';
import * as fixedCostController from '../controllers/fixedCostController.js';
import { verifyToken } from '../middleware/auth.js';

const router = Router();

router.get('/', verifyToken, fixedCostController.getFixedCosts);
router.get('/monthly-total', verifyToken, fixedCostController.getMonthlyTotal);
router.get('/:id', verifyToken, fixedCostController.getFixedCostById);
router.post('/', verifyToken, fixedCostController.createFixedCost);
router.put('/:id', verifyToken, fixedCostController.updateFixedCost);
router.delete('/:id', verifyToken, fixedCostController.deleteFixedCost);

export default router;
