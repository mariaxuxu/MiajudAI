import config from '../config/env.js';

export const getHealth = async (req, res) => {
  try {
    const healthData = {
      status: 'ok',
      message: 'MiAjudAI API is operational',
      timestamp: new Date().toISOString(),
      environment: config.nodeEnv,
      version: '1.0.0',
      uptime: process.uptime(),
      memory: {
        used: `${Math.round(process.memoryUsage().heapUsed / 1024 / 1024)}MB`,
        total: `${Math.round(process.memoryUsage().heapTotal / 1024 / 1024)}MB`,
      },
      checks: {
        api: 'healthy',
        // Database connection check will be added in Épico 1.2
        // database: await checkDatabase(),
        // Firebase connection check will be added in Épico 2
        // firebase: await checkFirebase(),
      },
    };

    res.status(200).json(healthData);
  } catch (error) {
    console.error('Health check error:', error);
    res.status(500).json({
      status: 'error',
      message: 'Health check failed',
      error: error.message,
    });
  }
};
