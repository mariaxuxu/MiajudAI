import twilio from 'twilio';

// Inicialização lazy para garantir que o dotenv já carregou as variáveis
let _client = null;
const getClient = () => {
  if (!_client) {
    _client = twilio(process.env.TWILIO_ACCOUNT_SID, process.env.TWILIO_AUTH_TOKEN);
  }
  return _client;
};

// Converte dígitos brasileiros (11 dígitos) para formato E.164 (+55...)
const toE164 = (digits) => {
  const clean = digits.replace(/\D/g, '');
  if (clean.startsWith('55')) return `+${clean}`;
  return `+55${clean}`;
};

export const sendEmergencyAlert = async (contactPhone, userName) => {
  const to = toE164(contactPhone);
  const body =
    `Olá! Estamos entrando em contato porque ${userName || 'um usuário'} ` +
    `do MiAjudAI não acessa o aplicativo há alguns dias. ` +
    `Se possível, entre em contato com essa pessoa para verificar se está tudo bem.`;

  if (process.env.SMS_DRY_RUN === 'true') {
    console.log(`[SMS][DRY RUN] Para: ${to} | Mensagem: ${body}`);
    return 'dry-run';
  }

  const from = process.env.TWILIO_PHONE_NUMBER;
  // Trial do Twilio exige template predefinido no Body
  const messageBody = process.env.SMS_TRIAL_MODE === 'true' ? 'sms_appointment_reminders' : body;
  const message = await getClient().messages.create({ from, to, body: messageBody });
  console.log(`[SMS] Enviado para ${to} — SID: ${message.sid}`);
  return message.sid;
};
