import { getDatabase } from '../config/database.js';
import { Op } from 'sequelize';

// Validation error factory
class ValidationError extends Error {
  constructor(field, message) {
    super(message);
    this.name = 'ValidationError';
    this.field = field;
  }
}

// Constants
const ALLOWED_MOODS = ['happy', 'sad', 'neutral'];
const ALLOWED_TAGS = ['finance', 'food', 'domestic', 'calendar'];
const EMOTION_SCORES = { happy: 80, sad: 20, neutral: 50 };

// Validation functions
export const validateDiaryEvent = (event) => {
  if (!event.text || event.text.trim() === '') {
    throw new ValidationError('text', 'Diary text is required and cannot be empty');
  }

  if (!event.mood || !ALLOWED_MOODS.includes(event.mood)) {
    throw new ValidationError('mood', `Mood must be one of: ${ALLOWED_MOODS.join(', ')}`);
  }

  if (event.tags) {
    if (!Array.isArray(event.tags)) {
      throw new ValidationError('tags', 'Tags must be an array');
    }
    const invalidTags = event.tags.filter((tag) => !ALLOWED_TAGS.includes(tag));
    if (invalidTags.length > 0) {
      throw new ValidationError('tags', `Invalid tags: ${invalidTags.join(', ')}. Allowed: ${ALLOWED_TAGS.join(', ')}`);
    }
  }
};

export const validateScreenEvent = (event) => {
  if (!event.screen_name || event.screen_name.trim() === '') {
    throw new ValidationError('screen_name', 'Screen name is required');
  }

  if (event.dwell_time_seconds !== undefined && event.dwell_time_seconds !== null) {
    if (!Number.isInteger(event.dwell_time_seconds) || event.dwell_time_seconds < 0) {
      throw new ValidationError('dwell_time_seconds', 'Dwell time must be a non-negative integer');
    }
  }
};

export const validateInteractionEvent = (event) => {
  if (!event.interaction_type || event.interaction_type.trim() === '') {
    throw new ValidationError('interaction_type', 'Interaction type is required');
  }
};

// Storage functions
export const storeDiaryEntry = async (userId, eventData) => {
  const { DiaryEntry } = getDatabase();

  try {
    // Validate
    validateDiaryEvent(eventData);
    console.log(`[VALIDATE] ✓ Diary event validation passed`);

    const emotionScore = EMOTION_SCORES[eventData.mood];

    // Store
    const entryDate = eventData.date ? new Date(eventData.date) : new Date();
    const entry = await DiaryEntry.create({
      user_id: userId,
      text: eventData.text.trim(),
      mood: eventData.mood,
      tags: eventData.tags || [],
      emotion_score: emotionScore,
      created_at: entryDate,
      updated_at: entryDate,
    });

    console.log(`[DB] ✅ Diary entry CREATED`);
    console.log(`[DB]   ID: ${entry.id}`);
    console.log(`[DB]   User: ${userId}`);
    console.log(`[DB]   Mood: ${eventData.mood} (score: ${emotionScore})`);
    console.log(`[DB]   Text: "${eventData.text.substring(0, 50)}${eventData.text.length > 50 ? '...' : ''}"`);
    console.log(`[DB]   Tags: [${(eventData.tags || []).join(', ')}]`);

    return entry;
  } catch (error) {
    if (error.name === 'ValidationError') {
      console.log(`[VALIDATE] ✗ Validation failed: ${error.field} - ${error.message}`);
    } else {
      console.error(`[DB_ERROR] ❌ Error storing diary entry:`, error.message);
    }
    throw error;
  }
};

export const storeScreenEvent = async (userId, eventData) => {
  const { ScreenEvent } = getDatabase();

  validateScreenEvent(eventData);

  try {
    const event = await ScreenEvent.create({
      user_id: userId,
      screen_name: eventData.screen_name.trim(),
      dwell_time_seconds: eventData.dwell_time_seconds || null,
      source_screen: eventData.source_screen || null,
      created_at: new Date(),
    });

    console.log(`✅ Screen event recorded: screen=${eventData.screen_name}, dwell=${eventData.dwell_time_seconds}s`);
    return event;
  } catch (error) {
    console.error('❌ Error storing screen event:', error.message);
    throw error;
  }
};

export const storeInteractionEvent = async (userId, eventData) => {
  const { InteractionEvent } = getDatabase();

  validateInteractionEvent(eventData);

  try {
    const event = await InteractionEvent.create({
      user_id: userId,
      interaction_type: eventData.interaction_type.trim(),
      screen_name: eventData.screen_name || null,
      created_at: new Date(),
    });

    console.log(`✅ Interaction event recorded: type=${eventData.interaction_type}, screen=${eventData.screen_name}`);
    return event;
  } catch (error) {
    console.error('❌ Error storing interaction event:', error.message);
    throw error;
  }
};

// Batch processing
export const processEventBatch = async (userId, events) => {
  const results = {
    diary: [],
    screen: [],
    interaction: [],
    errors: [],
  };

  for (let i = 0; i < events.length; i++) {
    const event = events[i];
    try {
      switch (event.type) {
        case 'diary':
          results.diary.push(await storeDiaryEntry(userId, event));
          break;
        case 'screen':
          results.screen.push(await storeScreenEvent(userId, event));
          break;
        case 'interaction':
          results.interaction.push(await storeInteractionEvent(userId, event));
          break;
        default:
          results.errors.push({
            index: i,
            message: `Unknown event type: ${event.type}`,
          });
      }
    } catch (error) {
      results.errors.push({
        index: i,
        field: error.field || 'unknown',
        message: error.message,
      });
    }
  }

  return results;
};

// Query helpers for agent context
export const getDiaryEntriesByTag = async (userId, tag, limit = 10, daysBack = 7) => {
  const { DiaryEntry } = getDatabase();
  const startDate = new Date();
  startDate.setDate(startDate.getDate() - daysBack);

  try {
    const entries = await DiaryEntry.findAll({
      where: {
        user_id: userId,
        tags: {
          [Op.contains]: [tag],
        },
        created_at: {
          [Op.gte]: startDate,
        },
      },
      order: [['created_at', 'DESC']],
      limit,
    });

    return entries;
  } catch (error) {
    console.error(`❌ Error querying diary entries with tag ${tag}:`, error.message);
    return [];
  }
};

export const getDiaryEntriesForPeriod = async (userId, startDate, endDate, limit = 10) => {
  const { DiaryEntry } = getDatabase();

  try {
    const entries = await DiaryEntry.findAll({
      where: {
        user_id: userId,
        created_at: {
          [Op.between]: [startDate, endDate],
        },
      },
      order: [['created_at', 'DESC']],
      limit,
    });

    return entries;
  } catch (error) {
    console.error('❌ Error querying diary entries for period:', error.message);
    return [];
  }
};

export const getDiaryEntriesForMonth = async (userId, year, month) => {
  const { DiaryEntry } = getDatabase();

  const startDate = new Date(Date.UTC(year, month - 1, 1));
  const endDate = new Date(Date.UTC(year, month, 0, 23, 59, 59, 999));

  try {
    const entries = await DiaryEntry.findAll({
      where: {
        user_id: userId,
        created_at: { [Op.between]: [startDate, endDate] },
      },
      order: [['created_at', 'DESC']],
    });
    return entries;
  } catch (error) {
    console.error('❌ Error querying diary entries for month:', error.message);
    throw error;
  }
};

export default {
  validateDiaryEvent,
  validateScreenEvent,
  validateInteractionEvent,
  storeDiaryEntry,
  storeScreenEvent,
  storeInteractionEvent,
  processEventBatch,
  getDiaryEntriesByTag,
  getDiaryEntriesForPeriod,
  getDiaryEntriesForMonth,
};
