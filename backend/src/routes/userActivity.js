import express from 'express';
import { postUserActivity } from '../controllers/userActivityController.js';

const router = express.Router();

router.post('/', postUserActivity);

export default router;
