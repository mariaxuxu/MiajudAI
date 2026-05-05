import admin from 'firebase-admin';
import config from './env.js';

let firebaseApp = null;

export const initializeFirebase = () => {
  try {
    if (firebaseApp) {
      return firebaseApp;
    }

    // Use environment variables for Firebase credentials
    const serviceAccount = {
      type: 'service_account',
      project_id: config.firebase.projectId,
      private_key_id: 'key-id',
      private_key: config.firebase.privateKey,
      client_email: config.firebase.clientEmail,
      client_id: 'client-id',
      auth_uri: 'https://accounts.google.com/o/oauth2/auth',
      token_uri: 'https://oauth2.googleapis.com/token',
      auth_provider_x509_cert_url: 'https://www.googleapis.com/oauth2/v1/certs',
      client_x509_cert_url: `https://www.googleapis.com/robot/v1/metadata/x509/${config.firebase.clientEmail}`,
    };

    firebaseApp = admin.initializeApp({
      credential: admin.credential.cert(serviceAccount),
    });

    console.log('✅ Firebase Admin SDK initialized');
    return firebaseApp;
  } catch (error) {
    console.error('❌ Firebase initialization error:', error);
    throw error;
  }
};

export const getFirebaseApp = () => {
  if (!firebaseApp) {
    return initializeFirebase();
  }
  return firebaseApp;
};

export const verifyIdToken = async (idToken) => {
  try {
    const app = getFirebaseApp();
    console.log('🔍 Verifying token with Firebase Admin SDK');
    console.log('Token length:', idToken.length);
    console.log('Token starts with:', idToken.substring(0, 50) + '...');

    const decodedToken = await admin.auth(app).verifyIdToken(idToken);
    console.log('✅ Token verified successfully');
    return decodedToken;
  } catch (error) {
    console.error('❌ Token verification error:', error.message);
    console.error('Full error:', error);
    throw error;
  }
};

export default {
  initializeFirebase,
  getFirebaseApp,
  verifyIdToken,
};
