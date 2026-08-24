import userActivityService from '../services/userActivityService.js';
import { HTTP_STATUS, ERROR_MESSAGES } from '../utils/constants.js';

export const postUserActivity = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { events } = req.body;

    // Validate request body
    if (!events || !Array.isArray(events)) {
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
      return res.status(HTTP_STATUS.BAD_REQUEST).json({
        error: {
          statusCode: HTTP_STATUS.BAD_REQUEST,
          message: 'At least one event is required',
        },
      });
    }

    console.log(`📤 Processing batch: ${events.length} events for user ${userId}`);

    // Process all events
    const results = await userActivityService.processEventBatch(userId, events);

    const totalStored =
      results.diary.length + results.screen.length + results.interaction.length;

    // Log any validation errors
    if (results.errors.length > 0) {
      console.log(`⚠️  ${results.errors.length} events failed validation:`);
      results.errors.forEach((err) => {
        console.log(`   Event index ${err.index}: ${err.field} - ${err.message}`);
      });
    }

    console.log(
      `✅ Batch processed: ${totalStored} stored, ${results.errors.length} errors`
    );

    return res.status(HTTP_STATUS.OK).json({
      success: true,
      events_stored: totalStored,
      timestamp: new Date().toISOString(),
      summary: {
        diary: results.diary.length,
        screen: results.screen.length,
        interaction: results.interaction.length,
        errors: results.errors.length,
      },
    });
  } catch (error) {
    console.error('❌ User activity error:', error.message);
    return res.status(HTTP_STATUS.INTERNAL_SERVER_ERROR).json({
      error: {
        statusCode: HTTP_STATUS.INTERNAL_SERVER_ERROR,
        message: ERROR_MESSAGES.INTERNAL_ERROR,
      },
    });
  }
};

export default {
  postUserActivity,
};
