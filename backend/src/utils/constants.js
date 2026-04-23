// API Response Status Codes
export const HTTP_STATUS = {
  OK: 200,
  CREATED: 201,
  BAD_REQUEST: 400,
  UNAUTHORIZED: 401,
  FORBIDDEN: 403,
  NOT_FOUND: 404,
  CONFLICT: 409,
  INTERNAL_SERVER_ERROR: 500,
  SERVICE_UNAVAILABLE: 503,
};

// Error Messages
export const ERROR_MESSAGES = {
  VALIDATION_ERROR: 'Validation error',
  UNAUTHORIZED: 'Unauthorized access',
  FORBIDDEN: 'Forbidden access',
  NOT_FOUND: 'Resource not found',
  CONFLICT: 'Resource already exists',
  INTERNAL_ERROR: 'Internal server error',
  DATABASE_ERROR: 'Database error',
  FIREBASE_ERROR: 'Firebase error',
  LLM_ERROR: 'LLM service error',
};

// User Roles
export const USER_ROLES = {
  USER: 'user',
  ADMIN: 'admin',
};

// Agent Types
export const AGENT_TYPES = {
  OTTO: 'otto', // Kitchen specialist
  LUNA: 'luna', // Financial specialist
  TINA: 'tina', // Domestic specialist
};

// Transaction Types
export const TRANSACTION_TYPES = {
  EXPENSE: 'expense',
  INCOME: 'income',
};

// Event Categories
export const EVENT_CATEGORIES = {
  WORK: 'work',
  PERSONAL: 'personal',
  HEALTH: 'health',
  FINANCE: 'finance',
  SHOPPING: 'shopping',
  OTHER: 'other',
};

// Expense Categories
export const EXPENSE_CATEGORIES = {
  FOOD: 'food',
  TRANSPORT: 'transport',
  UTILITIES: 'utilities',
  ENTERTAINMENT: 'entertainment',
  HEALTH: 'health',
  EDUCATION: 'education',
  SHOPPING: 'shopping',
  OTHER: 'other',
};

// Security Event Types
export const SECURITY_EVENT_TYPES = {
  LOGIN: 'login',
  LOGOUT: 'logout',
  FAILED_LOGIN: 'failed_login',
  PASSWORD_CHANGE: 'password_change',
  PROFILE_UPDATE: 'profile_update',
  CONTACT_EMERGENCY_ADD: 'contact_emergency_add',
  CONTACT_EMERGENCY_VERIFY: 'contact_emergency_verify',
  SMS_VERIFICATION: 'sms_verification',
};

// Verification Status
export const VERIFICATION_STATUS = {
  PENDING: 'pending',
  VERIFIED: 'verified',
  FAILED: 'failed',
};

// Pagination
export const PAGINATION = {
  DEFAULT_PAGE: 1,
  DEFAULT_LIMIT: 20,
  MAX_LIMIT: 100,
};

// Token Expiration Times (in seconds)
export const TOKEN_EXPIRATION = {
  JWT: 86400, // 24 hours
  REFRESH: 604800, // 7 days
  SMS_CODE: 300, // 5 minutes
};

// Date Formats
export const DATE_FORMATS = {
  ISO: 'YYYY-MM-DDTHH:mm:ss.SSSZ',
  DISPLAY: 'DD/MM/YYYY',
  DISPLAY_TIME: 'DD/MM/YYYY HH:mm',
};
