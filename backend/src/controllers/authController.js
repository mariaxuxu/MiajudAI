import authService from '../services/authService.js';
import { HTTP_STATUS, ERROR_MESSAGES } from '../utils/constants.js';

// POST /auth/verify-token
// Verify Firebase token and return JWT
export const verifyToken = async (req, res) => {
  try {
    const { idToken, fullName } = req.body;

    if (!idToken) {
      return res.status(HTTP_STATUS.BAD_REQUEST).json({
        error: {
          statusCode: HTTP_STATUS.BAD_REQUEST,
          message: 'Missing idToken',
        },
      });
    }

    // Verify Firebase token
    const decodedToken = await authService.verifyFirebaseToken(idToken);

    // Register or get user (lookup by email since firebase uid can change between sessions)
    let user = await authService.getUserByEmail(decodedToken.email);

    if (!user) {
      user = await authService.registerUser(
        decodedToken.uid,
        decodedToken.email,
        fullName
      );
    }

    // Generate JWT
    const jwtToken = authService.generateJWT(user.id, user.email);

    // Update last activity
    await user.update({ last_activity: new Date() });

    return res.status(HTTP_STATUS.OK).json({
      success: true,
      token: jwtToken,
      user: {
        id: user.id,
        firebase_uid: user.firebase_uid,
        email: user.email,
        full_name: user.full_name,
        phone: user.phone,
        avatar_url: user.avatar_url,
        gender: user.gender,
        birth_date: user.birth_date,
        birth_country: user.birth_country,
        birth_state: user.birth_state,
        birth_city: user.birth_city,
        nationality: user.nationality,
        marital_status: user.marital_status,
        emergency_contact_1_name: user.emergency_contact_1_name,
        emergency_contact_1_phone: user.emergency_contact_1_phone,
        emergency_contact_2_name: user.emergency_contact_2_name,
        emergency_contact_2_phone: user.emergency_contact_2_phone,
        emergency_contact_3_name: user.emergency_contact_3_name,
        emergency_contact_3_phone: user.emergency_contact_3_phone,
      },
    });
  } catch (error) {
    console.error('Token verification error:', error);
    return res.status(HTTP_STATUS.UNAUTHORIZED).json({
      error: {
        statusCode: HTTP_STATUS.UNAUTHORIZED,
        message: ERROR_MESSAGES.UNAUTHORIZED,
        details: error.message,
      },
    });
  }
};

// GET /auth/me
// Get current authenticated user
export const getCurrentUser = async (req, res) => {
  try {
    const userId = req.user.userId;

    const user = await authService.getUserById(userId);

    if (!user) {
      return res.status(HTTP_STATUS.NOT_FOUND).json({
        error: {
          statusCode: HTTP_STATUS.NOT_FOUND,
          message: ERROR_MESSAGES.NOT_FOUND,
        },
      });
    }

    // Update last activity
    await user.update({ last_activity: new Date() });

    return res.status(HTTP_STATUS.OK).json({
      success: true,
      user: {
        id: user.id,
        firebase_uid: user.firebase_uid,
        email: user.email,
        full_name: user.full_name,
        phone: user.phone,
        avatar_url: user.avatar_url,
        gender: user.gender,
        birth_date: user.birth_date,
        birth_country: user.birth_country,
        birth_state: user.birth_state,
        birth_city: user.birth_city,
        nationality: user.nationality,
        marital_status: user.marital_status,
        emergency_contact_1_name: user.emergency_contact_1_name,
        emergency_contact_1_phone: user.emergency_contact_1_phone,
        emergency_contact_2_name: user.emergency_contact_2_name,
        emergency_contact_2_phone: user.emergency_contact_2_phone,
        emergency_contact_3_name: user.emergency_contact_3_name,
        emergency_contact_3_phone: user.emergency_contact_3_phone,
        created_at: user.created_at,
      },
    });
  } catch (error) {
    console.error('Get current user error:', error);
    return res.status(HTTP_STATUS.INTERNAL_SERVER_ERROR).json({
      error: {
        statusCode: HTTP_STATUS.INTERNAL_SERVER_ERROR,
        message: ERROR_MESSAGES.INTERNAL_ERROR,
      },
    });
  }
};

// PUT /auth/profile
// Update user profile
export const updateProfile = async (req, res) => {
  try {
    const userId = req.user.userId;
    const {
      full_name,
      phone,
      avatar_url,
      gender,
      birth_date,
      birth_country,
      birth_state,
      birth_city,
      nationality,
      marital_status,
      emergency_contact_1_name,
      emergency_contact_1_phone,
      emergency_contact_2_name,
      emergency_contact_2_phone,
      emergency_contact_3_name,
      emergency_contact_3_phone,
    } = req.body;

    const user = await authService.updateUserProfile(userId, {
      full_name,
      phone,
      avatar_url,
      gender,
      birth_date,
      birth_country,
      birth_state,
      birth_city,
      nationality,
      marital_status,
      emergency_contact_1_name,
      emergency_contact_1_phone,
      emergency_contact_2_name,
      emergency_contact_2_phone,
      emergency_contact_3_name,
      emergency_contact_3_phone,
    });

    return res.status(HTTP_STATUS.OK).json({
      success: true,
      user: {
        id: user.id,
        email: user.email,
        full_name: user.full_name,
        phone: user.phone,
        avatar_url: user.avatar_url,
        gender: user.gender,
        birth_date: user.birth_date,
        birth_country: user.birth_country,
        birth_state: user.birth_state,
        birth_city: user.birth_city,
        nationality: user.nationality,
        marital_status: user.marital_status,
        emergency_contact_1_name: user.emergency_contact_1_name,
        emergency_contact_1_phone: user.emergency_contact_1_phone,
        emergency_contact_2_name: user.emergency_contact_2_name,
        emergency_contact_2_phone: user.emergency_contact_2_phone,
        emergency_contact_3_name: user.emergency_contact_3_name,
        emergency_contact_3_phone: user.emergency_contact_3_phone,
      },
    });
  } catch (error) {
    console.error('Profile update error:', error);
    return res.status(HTTP_STATUS.INTERNAL_SERVER_ERROR).json({
      error: {
        statusCode: HTTP_STATUS.INTERNAL_SERVER_ERROR,
        message: ERROR_MESSAGES.INTERNAL_ERROR,
        details: error.message,
      },
    });
  }
};
