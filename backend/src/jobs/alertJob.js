import cron from 'node-cron';
import { getDatabase } from '../config/database.js';
import { sendEmergencyAlert } from '../services/smsService.js';

// Threshold em minutos. Para teste use 5; para produção use 4320 (3 dias).
const THRESHOLD_MINUTES = parseInt(process.env.SMS_INACTIVITY_MINUTES ?? '5', 10);

// Roda a cada minuto. Em produção pode aumentar para '0 * * * *' (a cada hora).
const CRON_SCHEDULE = process.env.SMS_CRON_SCHEDULE ?? '* * * * *';

const checkInactiveUsers = async () => {
  const { sequelize, User } = getDatabase();
  const cutoff = new Date(Date.now() - THRESHOLD_MINUTES * 60 * 1000);

  // SQL direto para comparar last_sms_alert_at < last_activity com segurança
  const [rows] = await sequelize.query(
    `SELECT id FROM users
     WHERE logout_at IS NOT NULL
       AND logout_at < :cutoff
       AND (
         last_sms_alert_at IS NULL
         OR last_sms_alert_at < logout_at
       )
       AND (
         emergency_contact_1_phone IS NOT NULL
         OR emergency_contact_2_phone IS NOT NULL
         OR emergency_contact_3_phone IS NOT NULL
       )`,
    { replacements: { cutoff } }
  );

  if (rows.length === 0) return;

  const ids = rows.map((r) => r.id);
  const users = await User.findAll({ where: { id: ids } });

  if (users.length === 0) return;

  console.log(`[alertJob] ${users.length} usuário(s) inativo(s) encontrado(s)`);

  for (const user of users) {
    const contacts = [
      user.emergency_contact_1_phone,
      user.emergency_contact_2_phone,
      user.emergency_contact_3_phone,
    ].filter(Boolean);

    for (const phone of contacts) {
      try {
        await sendEmergencyAlert(phone, user.full_name);
      } catch (err) {
        console.error(`[alertJob] Falha ao enviar SMS para ${phone}:`, err.message);
      }
    }

    await user.update({ last_sms_alert_at: new Date() });
  }
};

export const startAlertJob = () => {
  cron.schedule(CRON_SCHEDULE, async () => {
    try {
      await checkInactiveUsers();
    } catch (err) {
      console.error('[alertJob] Erro inesperado:', err.message);
    }
  });

  console.log(
    `[alertJob] ✅ Iniciado — threshold: ${THRESHOLD_MINUTES}min, schedule: "${CRON_SCHEDULE}"`
  );
};
