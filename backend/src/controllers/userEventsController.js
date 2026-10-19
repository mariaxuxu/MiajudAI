import userEventsService, { MAX_BATCH_SIZE } from '../services/userEventsService.js';
import { HTTP_STATUS, ERROR_MESSAGES } from '../utils/constants.js';

export const postUserEvents = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { events } = req.body;

    if (!events || !Array.isArray(events)) {
      return res.status(HTTP_STATUS.BAD_REQUEST).json({
        error: {
          statusCode: HTTP_STATUS.BAD_REQUEST,
          message: 'Events must be an array',
        },
      });
    }

    if (events.length > MAX_BATCH_SIZE) {
      return res.status(HTTP_STATUS.BAD_REQUEST).json({
        error: {
          statusCode: HTTP_STATUS.BAD_REQUEST,
          message: `Maximum ${MAX_BATCH_SIZE} events per batch`,
        },
      });
    }

    if (events.length === 0) {
      return res.status(HTTP_STATUS.BAD_REQUEST).json({
        error: {
          statusCode: HTTP_STATUS.BAD_REQUEST,
          message: 'At least one event is required',
        },
      });
    }

    for (const event of events) {
      try {
        userEventsService.validateUserEvent(event);
      } catch (validationError) {
        return res.status(HTTP_STATUS.BAD_REQUEST).json({
          error: {
            statusCode: HTTP_STATUS.BAD_REQUEST,
            message: validationError.message,
            details: { field: validationError.field, message: validationError.message },
          },
        });
      }
    }

    const created = await userEventsService.storeUserEvents(userId, events);

    return res.status(HTTP_STATUS.OK).json({
      success: true,
      events_stored: created.length,
    });
  } catch (error) {
    console.error('Store user events error:', error);
    return res.status(HTTP_STATUS.INTERNAL_SERVER_ERROR).json({
      error: {
        statusCode: HTTP_STATUS.INTERNAL_SERVER_ERROR,
        message: ERROR_MESSAGES.INTERNAL_ERROR,
      },
    });
  }
};

export default { postUserEvents };
