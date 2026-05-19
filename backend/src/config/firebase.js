import admin from 'firebase-admin';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
let firebaseApp = null;

export const initializeFirebase = () => {
  try {
    if (firebaseApp) {
      return firebaseApp;
    }

    // Ler credenciais direto do arquivo JSON
    const credentialsPath = path.join(__dirname, '../../config/firebase-adminsdk.json');
    const serviceAccount = JSON.parse(fs.readFileSync(credentialsPath, 'utf8'));

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
