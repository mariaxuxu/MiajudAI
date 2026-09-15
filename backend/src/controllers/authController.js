import authService from '../services/authService.js';
import { HTTP_STATUS, ERROR_MESSAGES } from '../utils/constants.js';

const devUsers = {};

export const verifyToken = async (req, res) => {
  console.log(`\n[AUTH] POST /auth/verify-token - ${new Date().toISOString()}`);
  try {
    const { idToken, fullName } = req.body;
    console.log(`[AUTH] Received: fullName="${fullName}", idToken.length=${idToken?.length || 0}`);

    if (!idToken) {
      console.log(`[ERROR] Missing idToken`);
      return res.status(HTTP_STATUS.BAD_REQUEST).json({
        error: {
          statusCode: HTTP_STATUS.BAD_REQUEST,
          message: 'Missing idToken',
        },
      });
    }

    // Verify Firebase token
    console.log(`[AUTH] ⏳ Verifying Firebase token...`);
    const decodedToken = await authService.verifyFirebaseToken(idToken);
    console.log(`[AUTH] ✅ Firebase token verified`);

    if (process.env.NODE_ENV === 'development') {
      const email = decodedToken.email || idToken;
      const userId = `user_${Date.now()}`;

      if (!devUsers[email]) {
        devUsers[email] = {
          id: userId,
          firebase_uid: decodedToken.uid,
          email,
          full_name: decodedToken.name || fullName || 'Usuário',
          phone: null,
          avatar_url: null,
          gender: null,
          birth_date: null,
          birth_country: null,
          birth_state: null,
          birth_city: null,
          nationality: null,
          marital_status: null,
          emergency_contact_1_name: null,
          emergency_contact_1_phone: null,
          emergency_contact_2_name: null,
          emergency_contact_2_phone: null,
          emergency_contact_3_name: null,
          emergency_contact_3_phone: null,
          created_at: new Date(),
          updated_at: new Date(),
          last_activity: new Date(),
        };
      }

      const user = devUsers[email];
      const jwtToken = authService.generateJWT(user.id, user.email);

      return res.status(HTTP_STATUS.OK).json({
        success: true,
        token: jwtToken,
        user,
      });
    }

    // Register or get user (lookup by email since firebase uid can change between sessions)
    console.log(`[AUTH] ⏳ Looking up user by email: ${decodedToken.email}`);
    let user = await authService.getUserByEmail(decodedToken.email);
    console.log(`[AUTH] ✅ User lookup done: ${user ? 'found' : 'not found'}`);

    if (!user) {
      console.log(`[AUTH] ⏳ Registering new user...`);
      user = await authService.registerUser(
        decodedToken.uid,
        decodedToken.email,
        fullName
      );
      console.log(`[AUTH] ✅ User registered: id=${user.id}`);
    }

    // Generate JWT
    console.log(`[AUTH] ⏳ Generating JWT...`);
    const jwtToken = authService.generateJWT(user.id, user.email);
    console.log(`[AUTH] ✅ JWT generated`);

    // Update last activity
    console.log(`[AUTH] ⏳ Updating last activity...`);
    await user.update({ last_activity: new Date() });
    console.log(`[AUTH] ✅ Last activity updated`);

    console.log(`[AUTH] ✅ SUCCESS - Token verified and user authenticated`);
    console.log(`[AUTH] Returning JWT to client\n`);

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
    console.error(`[ERROR] ❌ Token verification failed: ${error.message}`);
    console.error(`[STACKTRACE] ${error.stack}\n`);
    return res.status(HTTP_STATUS.UNAUTHORIZED).json({
      error: {
        statusCode: HTTP_STATUS.UNAUTHORIZED,
        message: ERROR_MESSAGES.UNAUTHORIZED,
        details: error.message,
      },
    });
  }
};

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
