import userActivityService from '../services/userActivityService.js';
import { HTTP_STATUS, ERROR_MESSAGES } from '../utils/constants.js';

export const postUserActivity = async (req, res) => {
  const timestamp = new Date().toISOString();
  try {
    const userId = req.user.userId;
    const { events } = req.body;

    // AUDIT LOG: Request received
    console.log(`\n${'='.repeat(60)}`);
    console.log(`[AUDIT] ${timestamp} - POST /api/user-activity`);
    console.log(`[AUDIT] User ID: ${userId}`);
    console.log(`[AUDIT] Events received: ${events?.length || 0}`);
    if (events && events.length > 0) {
      events.forEach((evt, idx) => {
        console.log(`[AUDIT]   Event ${idx}: type=${evt.type}`);
      });
    }

    // Validate request body
    if (!events || !Array.isArray(events)) {
      console.log(`[ERROR] Invalid request: events is not an array`);
      return res.status(HTTP_STATUS.BAD_REQUEST).json({
        error: {
          statusCode: HTTP_STATUS.BAD_REQUEST,
          message: 'Events must be an array',
          details: { field: 'events', message: 'Expected array of event objects' },
        },
      });
    }

    // Batch size limit
    if (events.length > 100) {
      console.log(`[ERROR] Batch size exceeded: ${events.length} > 100`);
      return res.status(HTTP_STATUS.BAD_REQUEST).json({
        error: {
          statusCode: HTTP_STATUS.BAD_REQUEST,
          message: 'Batch size exceeded',
          details: { field: 'events', message: 'Maximum 100 events per batch' },
        },
      });
    }

    // Empty batch check
    if (events.length === 0) {
      console.log(`[ERROR] Empty batch received`);
      return res.status(HTTP_STATUS.BAD_REQUEST).json({
        error: {
          statusCode: HTTP_STATUS.BAD_REQUEST,
          message: 'At least one event is required',
        },
      });
    }

    console.log(`[PROCESSING] 📤 Processing batch: ${events.length} events for user ${userId}`);

    // Process all events
    const results = await userActivityService.processEventBatch(userId, events);

    const totalStored =
      results.diary.length + results.screen.length + results.interaction.length;

    // Log any validation errors
    if (results.errors.length > 0) {
      console.log(`[WARNING] ⚠️  ${results.errors.length} events failed validation:`);
      results.errors.forEach((err) => {
        console.log(`[ERROR]   Event index ${err.index}: ${err.field} - ${err.message}`);
      });
    }

    console.log(
      `[SUCCESS] ✅ Batch processed: ${totalStored} stored, ${results.errors.length} errors`
    );
    console.log(`[SUMMARY] Diary: ${results.diary.length} | Screen: ${results.screen.length} | Interaction: ${results.interaction.length}`);
    console.log(`${'='.repeat(60)}\n`);

    return res.status(HTTP_STATUS.OK).json({
      success: true,
      events_stored: totalStored,
      timestamp: timestamp,
      summary: {
        diary: results.diary.length,
        screen: results.screen.length,
        interaction: results.interaction.length,
        errors: results.errors.length,
      },
    });
  } catch (error) {
    console.error(`[FATAL] ❌ User activity error: ${error.message}`);
    console.error(`[STACKTRACE] ${error.stack}`);
    console.log(`${'='.repeat(60)}\n`);
    return res.status(HTTP_STATUS.INTERNAL_SERVER_ERROR).json({
      error: {
        statusCode: HTTP_STATUS.INTERNAL_SERVER_ERROR,
        message: ERROR_MESSAGES.INTERNAL_ERROR,
      },
    });
  }
};

export const getDiaryEntries = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { month } = req.query;

    if (!month || !/^\d{4}-\d{2}$/.test(month)) {
      return res.status(HTTP_STATUS.BAD_REQUEST).json({
        error: { message: 'month parameter required in YYYY-MM format' },
      });
    }

    const [year, m] = month.split('-').map(Number);
    const entries = await userActivityService.getDiaryEntriesForMonth(userId, year, m);

    return res.status(HTTP_STATUS.OK).json({
      entries: entries.map((e) => ({
        id: e.id,
        user_id: e.user_id,
        text: e.text,
        mood: e.mood,
        tags: e.tags,
        emotion_score: e.emotion_score,
        created_at: e.created_at,
        updated_at: e.updated_at,
      })),
      month,
    });
  } catch (error) {
    console.error('❌ Error fetching diary entries:', error.message);
    return res.status(HTTP_STATUS.INTERNAL_SERVER_ERROR).json({
      error: { message: ERROR_MESSAGES.INTERNAL_ERROR },
    });
  }
};

export default {
  postUserActivity,
  getDiaryEntries,
};
