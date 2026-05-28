import jwt from 'jsonwebtoken';
import config from '../config/env.js';
import { verifyIdToken } from '../config/firebase.js';
import { getDatabase } from '../config/database.js';

class AuthService {
  generateJWT(userId, email) {
    const payload = {
      userId,
      email,
      iat: Math.floor(Date.now() / 1000),
    };

    const token = jwt.sign(payload, config.jwt.secret, {
      expiresIn: config.jwt.expirationTime,
    });

    return token;
  }

  async verifyFirebaseToken(idToken) {
    try {
      const decodedToken = await verifyIdToken(idToken);
      return decodedToken;
    } catch (error) {
      throw new Error(`Firebase token verification failed: ${error.message}`);
    }
  }

  async registerUser(firebaseUid, email, fullName = null) {
    try {
      const { User, UserContext } = getDatabase();

      // Check if user already exists by email (email is stable across logins)
      let user = await User.findOne({ where: { email } });

      if (user) {
        // User already registered - update firebase_uid if changed
        if (user.firebase_uid !== firebaseUid) {
          await user.update({ firebase_uid: firebaseUid });
        }
        return user;
      }

      // Create new user
      user = await User.create({
        firebase_uid: firebaseUid,
        email,
        full_name: fullName,
      });

      // Create user context for each agent
      const agents = ['otto', 'luna', 'tina'];
      for (const agent of agents) {
        await UserContext.create({
          user_id: user.id,
          agent_type: agent,
          interests: {},
          routine_data: {},
          preferences: {},
        });
      }

      return user;
    } catch (error) {
      throw new Error(`User registration failed: ${error.message}`);
    }
  }

  async getUserById(userId) {
    try {
      const { User } = getDatabase();
      const user = await User.findByPk(userId);
      return user;
    } catch (error) {
      throw new Error(`Failed to get user: ${error.message}`);
    }
  }

  async getUserByEmail(email) {
    try {
      const { User } = getDatabase();
      const user = await User.findOne({ where: { email } });
      return user;
    } catch (error) {
      throw new Error(`Failed to get user: ${error.message}`);
    }
  }

  async updateUserProfile(userId, data) {
    try {
      const { User } = getDatabase();
      const user = await User.findByPk(userId);

      if (!user) {
        throw new Error('User not found');
      }

      await user.update({
        full_name: data.full_name !== undefined ? data.full_name : user.full_name,
        phone: data.phone !== undefined ? data.phone : user.phone,
        avatar_url: data.avatar_url !== undefined ? data.avatar_url : user.avatar_url,
        gender: data.gender !== undefined ? data.gender : user.gender,
        birth_date: data.birth_date !== undefined ? data.birth_date : user.birth_date,
        birth_country: data.birth_country !== undefined ? data.birth_country : user.birth_country,
        birth_state: data.birth_state !== undefined ? data.birth_state : user.birth_state,
        birth_city: data.birth_city !== undefined ? data.birth_city : user.birth_city,
        nationality: data.nationality !== undefined ? data.nationality : user.nationality,
        marital_status: data.marital_status !== undefined ? data.marital_status : user.marital_status,
        emergency_contact_1_name: data.emergency_contact_1_name !== undefined ? data.emergency_contact_1_name : user.emergency_contact_1_name,
        emergency_contact_1_phone: data.emergency_contact_1_phone !== undefined ? data.emergency_contact_1_phone : user.emergency_contact_1_phone,
        emergency_contact_2_name: data.emergency_contact_2_name !== undefined ? data.emergency_contact_2_name : user.emergency_contact_2_name,
        emergency_contact_2_phone: data.emergency_contact_2_phone !== undefined ? data.emergency_contact_2_phone : user.emergency_contact_2_phone,
        emergency_contact_3_name: data.emergency_contact_3_name !== undefined ? data.emergency_contact_3_name : user.emergency_contact_3_name,
        emergency_contact_3_phone: data.emergency_contact_3_phone !== undefined ? data.emergency_contact_3_phone : user.emergency_contact_3_phone,
      });

      return user;
    } catch (error) {
      throw new Error(`Profile update failed: ${error.message}`);
    }
  }
}

export default new AuthService();
