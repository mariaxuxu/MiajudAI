import express from 'express';
import { postUserActivity } from '../controllers/userActivityController.js';
import { verifyToken } from '../middleware/auth.js';

const router = express.Router();

router.post('/', verifyToken, postUserActivity);

export default router;
