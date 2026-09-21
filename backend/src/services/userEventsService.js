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
const UUID_REGEX =
  /^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$/;

export const MAX_BATCH_SIZE = 100;

// Lenient validation: only the shape of the event, never the action vocabulary.
export const validateUserEvent = (event) => {
  if (typeof event !== 'object' || event === null || Array.isArray(event)) {
    throw new ValidationError('event', 'Event must be an object');
  }

  if (typeof event.action !== 'string' || event.action.trim() === '') {
    throw new ValidationError('action', 'Action is required and must be a non-empty string');
  }

  if (
    typeof event.client_event_id !== 'string' ||
    !UUID_REGEX.test(event.client_event_id)
  ) {
    throw new ValidationError(
      'client_event_id',
      'Client event ID is required and must be a valid UUID'
    );
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
    client_event_id: event.client_event_id,
    action: event.action.trim(),
    screen_name: event.screen_name?.trim() || null,
    metadata: event.metadata || {},
  }));

  // ignoreDuplicates turns a retried batch into a no-op: any event whose
  // client_event_id already exists is skipped instead of inserted again.
  return UserEvent.bulkCreate(records, { ignoreDuplicates: true });
};

export default {
  validateUserEvent,
  storeUserEvents,
};
