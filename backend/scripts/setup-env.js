import os from 'os';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));

// 🔒 SINCRONIZADO COM:
//    - backend/src/config/env.js (port: 3001)
//    - frontend/lib/config/constants.dart (BACKEND_PORT = 3001)
// Se alterar aqui, DEVE alterar nos outros dois lugares também!
const BACKEND_PORT = 3001;

const getLocalIP = () => {
  const interfaces = os.networkInterfaces();
  let wifi192 = null;
  let tethering10 = null;

  for (const ifaces of Object.values(interfaces)) {
    for (const iface of ifaces) {
      if (iface.family !== 'IPv4' || iface.internal) continue;
      const ip = iface.address;

      // Prioridade 1: Wi-Fi normal (192.168.x.x)
      if (ip.startsWith('192.168.')) {
        wifi192 = ip;
      }
      // Prioridade 2: Tethering local (10.0.x.x ou 10.1.x.x) — evitar VPNs (10.254.x.x)
      else if (ip.startsWith('10.0.') || ip.startsWith('10.1.')) {
        if (!tethering10) tethering10 = ip;
      }
    }
  }

  return wifi192 || tethering10 || 'localhost';
};

const ip = getLocalIP();
const envPath = path.resolve(__dirname, '../../frontend/assets/.env');

// 🔒 PORTA HARDCODED: Sincronizada com backend/src/config/env.js
// Tanto backend quanto frontend SEMPRE usam 3001
const content = `# API Configuration
# 🔒 HARDCODED: Backend SEMPRE roda em 3001
# Frontend SEMPRE acessa http://${ip}:${BACKEND_PORT}/api
#
# Detalhes:
# - iOS Simulator: Usa ${ip}:${BACKEND_PORT}
# - iOS Device Real: Usa ${ip}:${BACKEND_PORT}
# - Android Emulator: Traduz para 10.0.2.2:${BACKEND_PORT}
# - Android Device Real: Usa ${ip}:${BACKEND_PORT}
# - Chrome: Usa localhost:${BACKEND_PORT}
API_BASE_URL=http://${ip}:${BACKEND_PORT}/api
`;

fs.writeFileSync(envPath, content, 'utf8');
console.log(`✅ Frontend .env configured: API_BASE_URL=http://${ip}:${BACKEND_PORT}/api`);
