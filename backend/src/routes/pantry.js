import express from 'express';
import {
  getCatalogItems,
  createCatalogItem,
  getPantry,
  commitPantry,
  updatePantryQuantity,
  deletePantryItem,
} from '../controllers/pantryController.js';
import { verifyToken } from '../middleware/auth.js';

const router = express.Router();

router.get('/items', verifyToken, getCatalogItems);
router.post('/items', verifyToken, createCatalogItem);
router.get('/', verifyToken, getPantry);
router.post('/commit', verifyToken, commitPantry);
router.patch('/', verifyToken, updatePantryQuantity);
router.delete('/:itemId', verifyToken, deletePantryItem);

export default router;
