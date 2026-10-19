import express from 'express';
import { getCatalogItems } from '../controllers/pantryController.js';
import { verifyToken } from '../middleware/auth.js';

const router = express.Router();

router.get('/items', verifyToken, getCatalogItems);

export default router;
