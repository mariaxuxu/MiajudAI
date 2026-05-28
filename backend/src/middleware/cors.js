import cors from 'cors';
import config from '../config/env.js';

const corsOptions = {
  origin: config.cors.origin,
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS', 'PATCH'],
  allowedHeaders: ['Content-Type', 'Authorization'],
  maxAge: 86400, // 24 hours
};

if (process.env.NODE_ENV === 'development') {
  console.log(`[CORS] Configured origin: ${JSON.stringify(corsOptions.origin)}`);
}

const corsMiddleware = cors(corsOptions);

export default corsMiddleware;
