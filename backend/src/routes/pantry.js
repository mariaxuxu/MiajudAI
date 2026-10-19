import express from 'express';
import {
  getCatalogItems,
  getPantry,
  updatePantryQuantity,
  deletePantryItem,
} from '../controllers/pantryController.js';
import { verifyToken } from '../middleware/auth.js';

const router = express.Router();

router.get('/items', verifyToken, getCatalogItems);
router.get('/', verifyToken, getPantry);
router.patch('/', verifyToken, updatePantryQuantity);
router.delete('/:itemId', verifyToken, deletePantryItem);

export default router;
