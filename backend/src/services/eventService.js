import { getDatabase } from '../config/database.js';

const getEventsByUserId = async (userId) => {
  const { Event } = getDatabase();
  const events = await Event.findAll({
    where: { user_id: userId },
    order: [['event_date', 'ASC']],
  });
  return events;
};

const createEvent = async (userId, title, eventDate) => {
  const { Event } = getDatabase();
  const event = await Event.create({
    user_id: userId,
    title,
    event_date: eventDate,
  });
  return event;
};

const deleteEvent = async (eventId, userId) => {
  const { Event } = getDatabase();
  const event = await Event.findByPk(eventId);

  if (!event) {
    throw new Error('Event not found');
  }

  if (event.user_id !== userId) {
    throw new Error('Unauthorized');
  }

  await event.destroy();
  return true;
};

export default {
  getEventsByUserId,
  createEvent,
  deleteEvent,
};
