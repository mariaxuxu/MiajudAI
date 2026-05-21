import os from 'os';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));

const getLocalIP = () => {
  const interfaces = os.networkInterfaces();
  let wifi192 = null; // Wi-Fi normal (192.168.x.x)
  let docker172 = null; // Docker/Emulator bridge (172.x.x.x)
  let tethering10 = null; // Tethering (10.x.x.x)
  let other = null; // Outros

  for (const ifaces of Object.values(interfaces)) {
    for (const iface of ifaces) {
      if (iface.family !== 'IPv4' || iface.internal) continue;
      const ip = iface.address;

      if (ip.startsWith('192.168.')) {
        wifi192 = ip; // Prioridade 1: Wi-Fi normal
      } else if (ip.startsWith('172.') && !docker172) {
        docker172 = ip; // Prioridade 2: Docker/Emulator (172.x.x.x)
      } else if (ip.startsWith('10.') && !tethering10) {
        tethering10 = ip; // Prioridade 3: Tethering
      } else if (!ip.startsWith('169.') && !other) {
        other = ip; // Prioridade 4: Outros
      }
    }
  }

  // Retornar em ordem de prioridade: Wi-Fi > Docker > Tethering > Outros > localhost
  return wifi192 || docker172 || tethering10 || other || 'localhost';
};

const ip = getLocalIP();
// Usar IP real da rede local (compatível com device físico, emulador, e produção)
// Em desenvolvimento local, localhost + flutter run port forwarding também funciona
const apiUrl = ip && ip !== 'localhost' ? `http://${ip}:3001/api` : 'http://localhost:3001/api';
const envPath = path.resolve(__dirname, '../../frontend/assets/.env');
const content = `API_BASE_URL=${apiUrl}\n`;

fs.writeFileSync(envPath, content, 'utf8');
console.log(`✅ Frontend URL: ${apiUrl}`);
