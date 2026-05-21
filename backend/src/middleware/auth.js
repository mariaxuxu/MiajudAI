import jwt from 'jsonwebtoken';
import config from '../config/env.js';

export const verifyToken = (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;
    console.log(`[AUTH] Checking authorization for ${req.method} ${req.path}`);

    if (!authHeader) {
      console.warn('[AUTH] Missing authorization header');
      return res.status(401).json({
        error: {
          statusCode: 401,
          message: 'Missing authorization header',
        },
      });
    }

    const token = authHeader.startsWith('Bearer ')
      ? authHeader.slice(7)
      : authHeader;

    console.log(`[AUTH] Token length: ${token.length}, starts with: ${token.substring(0, 10)}...`);
    const decoded = jwt.verify(token, config.jwt.secret);
    console.log(`[AUTH] Token verified for userId=${decoded.userId}`);
    req.user = decoded;
    next();
  } catch (error) {
    console.error('[AUTH] Token verification error:', error.message);
    return res.status(401).json({
      error: {
        statusCode: 401,
        message: 'Invalid or expired token',
        error: error.message,
      },
    });
  }
};

export const isAuthenticated = (req, res, next) => {
  if (!req.user) {
    return res.status(401).json({
      error: {
        statusCode: 401,
        message: 'Unauthorized',
      },
    });
  }
  next();
};

export default { verifyToken, isAuthenticated };
