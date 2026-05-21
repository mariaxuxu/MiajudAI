import eventService from '../services/eventService.js';
import { HTTP_STATUS, ERROR_MESSAGES } from '../utils/constants.js';

export const getEvents = async (req, res) => {
  try {
    const userId = req.user.userId;

    const events = await eventService.getEventsByUserId(userId);

    return res.status(HTTP_STATUS.OK).json({
      success: true,
      events: events.map((e) => ({
        id: e.id,
        user_id: e.user_id,
        title: e.title,
        event_date: e.event_date,
        created_at: e.created_at,
      })),
    });
  } catch (error) {
    console.error('Get events error:', error);
    return res.status(HTTP_STATUS.INTERNAL_SERVER_ERROR).json({
      error: {
        statusCode: HTTP_STATUS.INTERNAL_SERVER_ERROR,
        message: ERROR_MESSAGES.INTERNAL_ERROR,
      },
    });
  }
};

export const createEvent = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { title, event_date } = req.body;

    if (!title || !event_date) {
      return res.status(HTTP_STATUS.BAD_REQUEST).json({
        error: {
          statusCode: HTTP_STATUS.BAD_REQUEST,
          message: 'Missing title or event_date',
        },
      });
    }

    const event = await eventService.createEvent(userId, title, event_date);

    return res.status(HTTP_STATUS.OK).json({
      success: true,
      event: {
        id: event.id,
        user_id: event.user_id,
        title: event.title,
        event_datetime: event.event_datetime,
        created_at: event.created_at,
      },
    });
  } catch (error) {
    console.error('Create event error:', error);
    return res.status(HTTP_STATUS.INTERNAL_SERVER_ERROR).json({
      error: {
        statusCode: HTTP_STATUS.INTERNAL_SERVER_ERROR,
        message: ERROR_MESSAGES.INTERNAL_ERROR,
        details: error.message,
      },
    });
  }
};

export const deleteEvent = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { id } = req.params;

    await eventService.deleteEvent(parseInt(id, 10), userId);

    return res.status(HTTP_STATUS.OK).json({
      success: true,
      message: 'Event deleted',
    });
  } catch (error) {
    console.error('Delete event error:', error);

    if (error.message === 'Unauthorized') {
      return res.status(HTTP_STATUS.UNAUTHORIZED).json({
        error: {
          statusCode: HTTP_STATUS.UNAUTHORIZED,
          message: ERROR_MESSAGES.UNAUTHORIZED,
        },
      });
    }

    if (error.message === 'Event not found') {
      return res.status(HTTP_STATUS.NOT_FOUND).json({
        error: {
          statusCode: HTTP_STATUS.NOT_FOUND,
          message: ERROR_MESSAGES.NOT_FOUND,
        },
      });
    }

    return res.status(HTTP_STATUS.INTERNAL_SERVER_ERROR).json({
      error: {
        statusCode: HTTP_STATUS.INTERNAL_SERVER_ERROR,
        message: ERROR_MESSAGES.INTERNAL_ERROR,
        details: error.message,
      },
    });
  }
};
