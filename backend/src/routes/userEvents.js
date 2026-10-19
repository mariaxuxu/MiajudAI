import { Router } from 'express';
import { postUserEvents } from '../controllers/userEventsController.js';
import { verifyToken } from '../middleware/auth.js';

const router = Router();

router.post('/', verifyToken, postUserEvents);

export default router;
