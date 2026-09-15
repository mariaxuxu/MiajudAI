import express from 'express';
import { postUserActivity, getDiaryEntries } from '../controllers/userActivityController.js';
import { verifyToken } from '../middleware/auth.js';

const router = express.Router();

router.post('/', verifyToken, postUserActivity);
router.get('/diary', verifyToken, getDiaryEntries);

export default router;
