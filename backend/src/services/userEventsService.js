import { getDatabase } from '../config/database.js';

class ValidationError extends Error {
  constructor(field, message) {
    super(message);
    this.name = 'ValidationError';
    this.field = field;
  }
}

const MAX_ACTION_LENGTH = 100;
const MAX_SCREEN_NAME_LENGTH = 100;

export const MAX_BATCH_SIZE = 100;

// Lenient validation: only the shape of the event, never the action vocabulary.
export const validateUserEvent = (event) => {
  if (typeof event !== 'object' || event === null || Array.isArray(event)) {
    throw new ValidationError('event', 'Event must be an object');
  }

  if (typeof event.action !== 'string' || event.action.trim() === '') {
    throw new ValidationError('action', 'Action is required and must be a non-empty string');
  }

  if (event.action.length > MAX_ACTION_LENGTH) {
    throw new ValidationError('action', `Action must be at most ${MAX_ACTION_LENGTH} characters`);
  }

  if (event.screen_name !== undefined && event.screen_name !== null) {
    if (typeof event.screen_name !== 'string') {
      throw new ValidationError('screen_name', 'Screen name must be a string');
    }
    if (event.screen_name.length > MAX_SCREEN_NAME_LENGTH) {
      throw new ValidationError('screen_name', `Screen name must be at most ${MAX_SCREEN_NAME_LENGTH} characters`);
    }
  }

  if (event.metadata !== undefined && event.metadata !== null) {
    if (typeof event.metadata !== 'object' || Array.isArray(event.metadata)) {
      throw new ValidationError('metadata', 'Metadata must be an object');
    }
  }
};

// Assumes `events` were already validated. user_id is passed by the caller
// (derived from the JWT) — never read from the event payload.
export const storeUserEvents = async (userId, events) => {
  const { UserEvent } = getDatabase();

  const records = events.map((event) => ({
    user_id: userId,
    action: event.action.trim(),
    screen_name: event.screen_name?.trim() || null,
    metadata: event.metadata || {},
  }));

  return UserEvent.bulkCreate(records);
};

export default {
  validateUserEvent,
  storeUserEvents,
};
