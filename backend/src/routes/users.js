import express from 'express';
import {
  registerUser,
  getUserById,
  updateUser,
  addEmergencyContact,
  getEmergencyContacts,
} from '../controllers/usersController.js';
import { verifyToken } from '../middleware/auth.js';

const router = express.Router();

// Public routes
router.post('/register', registerUser);

// Protected routes
router.get('/:id', verifyToken, getUserById);
router.put('/:id', verifyToken, updateUser);

// Emergency contacts
router.post('/:id/emergency-contacts', verifyToken, addEmergencyContact);
router.get('/:id/emergency-contacts', verifyToken, getEmergencyContacts);

export default router;
