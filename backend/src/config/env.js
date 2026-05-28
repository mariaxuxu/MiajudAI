import dotenv from 'dotenv';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const envPath = path.join(__dirname, '../../.env');

// Load .env file
dotenv.config({ path: envPath });

// Configuration object
const config = {
  // Server
  // 🔒 SINCRONIZADO COM: frontend/lib/config/constants.dart
  // Se alterar aqui, DEVE alterar lá também!
  nodeEnv: process.env.NODE_ENV || 'development',
  port: 3001,
  logLevel: process.env.LOG_LEVEL || 'info',

  // Database
  database: {
    host: process.env.POSTGRES_HOST || 'localhost',
    port: process.env.POSTGRES_PORT || 5432,
    name: process.env.POSTGRES_DB || 'miajudai_dev',
    username: process.env.POSTGRES_USER || 'postgres',
    password: process.env.POSTGRES_PASSWORD || 'postgres',
    dialect: 'postgres',
    pool: {
      min: parseInt(process.env.DB_POOL_MIN, 10) || 2,
      max: parseInt(process.env.DB_POOL_MAX, 10) || 10,
    },
    logging: process.env.NODE_ENV === 'development' ? console.log : false,
  },

  // Firebase
  firebase: {
    projectId: process.env.FIREBASE_PROJECT_ID,
    privateKey: process.env.FIREBASE_PRIVATE_KEY?.replace(/\\n/g, '\n'),
    clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
    databaseUrl: process.env.FIREBASE_DATABASE_URL,
  },

  // JWT
  jwt: {
    secret: process.env.JWT_SECRET,
    expirationTime: process.env.JWT_EXPIRATION || '24h',
    refreshExpirationTime: process.env.JWT_REFRESH_EXPIRATION || '7d',
  },

  // Security
  //bcryptRounds: parseInt(process.env.BCRYPT_ROUNDS, 10) || 10,

  // LLM
  /*llm: {
    provider: process.env.LLM_PROVIDER || 'openai',
    openai: {
      apiKey: process.env.OPENAI_API_KEY,
      model: process.env.OPENAI_MODEL || 'gpt-4-turbo',
      maxTokens: parseInt(process.env.OPENAI_MAX_TOKENS, 10) || 1000,
    },
    anthropic: {
      apiKey: process.env.ANTHROPIC_API_KEY,
      model: process.env.ANTHROPIC_MODEL || 'claude-3-sonnet-20240229',
    },
  },

  // Twilio
  twilio: {
    accountSid: process.env.TWILIO_ACCOUNT_SID,
    authToken: process.env.TWILIO_AUTH_TOKEN,
    phoneNumber: process.env.TWILIO_PHONE_NUMBER,
  },*/

  // Gemini
  gemini: {
    apiKey: process.env.GEMINI_API_KEY,
    model: process.env.GEMINI_MODEL || 'gemini-2.0-flash',
  },

  // CORS
  cors: {
    // Em desenvolvimento, permitir todos os origins
    // Em produção, configurar via CORS_ORIGIN no .env
    origin: process.env.NODE_ENV === 'development'
      ? '*'
      : (process.env.CORS_ORIGIN || 'http://localhost:3000').split(','),
  },

  // API
  // 🔒 SINCRONIZADO: Deve corresponder à porta acima (3001)
  api: {
    baseUrl: process.env.API_BASE_URL || 'http://localhost:3001',
  },

  // Rate limiting
  rateLimit: {
    windowMs: parseInt(process.env.RATE_LIMIT_WINDOW_MS, 10) || 900000,
    maxRequests: parseInt(process.env.RATE_LIMIT_MAX_REQUESTS, 10) || 100,
  },

  // Features
  features: {
    smsVerification: process.env.FEATURE_SMS_VERIFICATION === 'true',
    emailNotifications: process.env.FEATURE_EMAIL_NOTIFICATIONS === 'true',
    llmContextLearning: process.env.FEATURE_LLM_CONTEXT_LEARNING === 'true',
  },
};

export default config;
