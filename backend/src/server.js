// Development: Desabilitar verificação SSL para self-signed certs na rede local
if (process.env.NODE_ENV === 'development') {
  process.env.NODE_TLS_REJECT_UNAUTHORIZED = '0';
  console.warn('⚠️  NODE_TLS_REJECT_UNAUTHORIZED disabled for development');
}

import app from './app.js';
import config from './config/env.js';

const PORT = config.port;
const HOST = '0.0.0.0'; // Listen on all network interfaces

const server = app.listen(PORT, HOST, () => {
  console.log(`
╔════════════════════════════════════════╗
║                                        ║
║   🤖 MiAjudAI Backend API              ║
║   ✅ Server Running                    ║
║                                        ║
║   🌐 Listening on: 0.0.0.0:${PORT}            ║
║   🏥 Health check: /health             ║
║   📝 Environment: ${config.nodeEnv.toUpperCase()}                      ║
║                                        ║
║   💡 Frontend auto-detects and uses:   ║
║      • iOS (any): http://<local-ip>:${PORT}/api ║
║      • Android Emulator: http://10.0.2.2:${PORT}/api ║
║      • Android Device Real: http://<local-ip>:${PORT}/api ║
║      • Chrome: http://localhost:${PORT}/api ║
║                                        ║
╚════════════════════════════════════════╝
  `);
});

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('SIGTERM received. Shutting down gracefully...');
  server.close(() => {
    console.log('Server closed');
    process.exit(0);
  });
});

process.on('SIGINT', () => {
  console.log('SIGINT received. Shutting down gracefully...');
  server.close(() => {
    console.log('Server closed');
    process.exit(0);
  });
});

// Unhandled rejections
process.on('unhandledRejection', (reason, promise) => {
  console.error('Unhandled Rejection at:', promise, 'reason:', reason);
  process.exit(1);
});

export default server;
