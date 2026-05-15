import os from 'os';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));

const getLocalIP = () => {
  const interfaces = os.networkInterfaces();
  const candidates = [];

  for (const ifaces of Object.values(interfaces)) {
    for (const iface of ifaces) {
      if (iface.family !== 'IPv4' || iface.internal) continue;
      const ip = iface.address;
      // Prioriza redes locais reais
      if (ip.startsWith('192.168.') || ip.startsWith('10.')) {
        candidates.unshift(ip); // maior prioridade
      } else if (!ip.startsWith('169.') && !ip.startsWith('172.')) {
        candidates.push(ip); // menor prioridade (ex: VPN)
      }
    }
  }

  return candidates[0] ?? 'localhost';
};

const ip = getLocalIP();
const envPath = path.resolve(__dirname, '../../frontend/assets/.env');
const content = `API_BASE_URL=http://${ip}:5000/api\n`;

fs.writeFileSync(envPath, content, 'utf8');
console.log(`✅ Frontend URL: http://${ip}:5000/api`);
