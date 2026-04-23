import authService from '../services/authService.js';
import { getDatabase } from '../config/database.js';
import { HTTP_STATUS, ERROR_MESSAGES } from '../utils/constants.js';

// POST /users/register
// Register a new user from signup form
export const registerUser = async (req, res) => {
  try {
    const { firebase_uid, email, full_name } = req.body;

    if (!firebase_uid || !email) {
      return res.status(HTTP_STATUS.BAD_REQUEST).json({
        error: {
          statusCode: HTTP_STATUS.BAD_REQUEST,
          message: 'Missing required fields: firebase_uid, email',
        },
      });
    }

    const user = await authService.registerUser(firebase_uid, email, full_name);

    return res.status(HTTP_STATUS.CREATED).json({
      success: true,
      user: {
        id: user.id,
        firebase_uid: user.firebase_uid,
        email: user.email,
        full_name: user.full_name,
      },
    });
  } catch (error) {
    console.error('User registration error:', error);
    return res.status(HTTP_STATUS.INTERNAL_SERVER_ERROR).json({
      error: {
        statusCode: HTTP_STATUS.INTERNAL_SERVER_ERROR,
        message: ERROR_MESSAGES.INTERNAL_ERROR,
        details: error.message,
      },
    });
  }
};

// GET /users/:id
// Get user by ID
export const getUserById = async (req, res) => {
  try {
    const { id } = req.params;

    const user = await authService.getUserById(id);

    if (!user) {
      return res.status(HTTP_STATUS.NOT_FOUND).json({
        error: {
          statusCode: HTTP_STATUS.NOT_FOUND,
          message: ERROR_MESSAGES.NOT_FOUND,
        },
      });
    }

    return res.status(HTTP_STATUS.OK).json({
      success: true,
      user: {
        id: user.id,
        firebase_uid: user.firebase_uid,
        email: user.email,
        full_name: user.full_name,
        phone: user.phone,
        avatar_url: user.avatar_url,
        created_at: user.created_at,
      },
    });
  } catch (error) {
    console.error('Get user error:', error);
    return res.status(HTTP_STATUS.INTERNAL_SERVER_ERROR).json({
      error: {
        statusCode: HTTP_STATUS.INTERNAL_SERVER_ERROR,
        message: ERROR_MESSAGES.INTERNAL_ERROR,
      },
    });
  }
};

// PUT /users/:id
// Update user profile
export const updateUser = async (req, res) => {
  try {
    const { id } = req.params;
    const { full_name, phone, avatar_url } = req.body;

    // Check if user is updating their own profile or is admin
    if (req.user.userId !== parseInt(id)) {
      return res.status(HTTP_STATUS.FORBIDDEN).json({
        error: {
          statusCode: HTTP_STATUS.FORBIDDEN,
          message: 'Forbidden: Cannot update other users',
        },
      });
    }

    const user = await authService.updateUserProfile(id, {
      full_name,
      phone,
      avatar_url,
    });

    return res.status(HTTP_STATUS.OK).json({
      success: true,
      user: {
        id: user.id,
        email: user.email,
        full_name: user.full_name,
        phone: user.phone,
        avatar_url: user.avatar_url,
      },
    });
  } catch (error) {
    console.error('Update user error:', error);
    return res.status(HTTP_STATUS.INTERNAL_SERVER_ERROR).json({
      error: {
        statusCode: HTTP_STATUS.INTERNAL_SERVER_ERROR,
        message: ERROR_MESSAGES.INTERNAL_ERROR,
      },
    });
  }
};

// POST /users/:id/emergency-contacts
// Add emergency contact
export const addEmergencyContact = async (req, res) => {
  try {
    const { id } = req.params;
    const { name, phone } = req.body;

    if (!name || !phone) {
      return res.status(HTTP_STATUS.BAD_REQUEST).json({
        error: {
          statusCode: HTTP_STATUS.BAD_REQUEST,
          message: 'Missing required fields: name, phone',
        },
      });
    }

    const { EmergencyContact } = getDatabase();

    const contact = await EmergencyContact.create({
      user_id: id,
      name,
      phone,
      is_verified: false,
    });

    return res.status(HTTP_STATUS.CREATED).json({
      success: true,
      contact: {
        id: contact.id,
        name: contact.name,
        phone: contact.phone,
        is_verified: contact.is_verified,
      },
    });
  } catch (error) {
    console.error('Add emergency contact error:', error);
    return res.status(HTTP_STATUS.INTERNAL_SERVER_ERROR).json({
      error: {
        statusCode: HTTP_STATUS.INTERNAL_SERVER_ERROR,
        message: ERROR_MESSAGES.INTERNAL_ERROR,
        details: error.message,
      },
    });
  }
};

// GET /users/:id/emergency-contacts
// Get user emergency contacts
export const getEmergencyContacts = async (req, res) => {
  try {
    const { id } = req.params;

    const { EmergencyContact } = getDatabase();

    const contacts = await EmergencyContact.findAll({
      where: { user_id: id },
    });

    return res.status(HTTP_STATUS.OK).json({
      success: true,
      contacts: contacts.map((c) => ({
        id: c.id,
        name: c.name,
        phone: c.phone,
        is_verified: c.is_verified,
      })),
    });
  } catch (error) {
    console.error('Get emergency contacts error:', error);
    return res.status(HTTP_STATUS.INTERNAL_SERVER_ERROR).json({
      error: {
        statusCode: HTTP_STATUS.INTERNAL_SERVER_ERROR,
        message: ERROR_MESSAGES.INTERNAL_ERROR,
      },
    });
  }
};
