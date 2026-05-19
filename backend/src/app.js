import express from 'express';
import helmet from 'helmet';
import cors from 'cors';
import morgan from 'morgan';
import config from './config/env.js';
import { initializeFirebase } from './config/firebase.js';
import { initializeDatabase } from './config/database.js';
import errorHandler from './middleware/errorHandler.js';
import loggerMiddleware from './middleware/logger.js';
import corsMiddleware from './middleware/cors.js';
import routes from './routes/index.js';

const app = express();

// Initialize Firebase and Database
try {
  initializeFirebase();
  initializeDatabase().catch((err) => {
    console.error('Database initialization error:', err);
    process.exit(1);
  });
} catch (error) {
  console.error('Initialization error:', error);
}

// ====================================
// Security Middleware
// ====================================
app.use(helmet());

// ====================================
// Logging
// ====================================
app.use(morgan('combined'));
app.use(loggerMiddleware);

// ====================================
// CORS
// ====================================
app.use(corsMiddleware);

// ====================================
// Body Parser
// ====================================
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ limit: '10mb', extended: true }));

// ====================================
// Health Check (before all other routes)
// ====================================
app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'ok',
    message: 'MiAjudAI API is running',
    timestamp: new Date().toISOString(),
    environment: config.nodeEnv,
    version: '1.0.0',
  });
});

// ====================================
// API Routes
// ====================================
app.use('/api', routes);

// ====================================
// 404 Handler
// ====================================
app.use((req, res) => {
  res.status(404).json({
    error: 'Not Found',
    message: `Route ${req.method} ${req.path} not found`,
    path: req.path,
  });
});

// ====================================
// Error Handler (must be last)
// ====================================
app.use(errorHandler);

export default app;
