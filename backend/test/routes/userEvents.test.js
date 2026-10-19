import { jest, describe, it, expect, beforeEach } from '@jest/globals';
import request from 'supertest';
import express from 'express';
import jwt from 'jsonwebtoken';

jest.unstable_mockModule('../../src/config/database.js', () => ({
  getDatabase: jest.fn(),
}));

const { getDatabase } = await import('../../src/config/database.js');
const { default: userEventsRoutes } = await import('../../src/routes/userEvents.js');

const app = express();
app.use(express.json());
app.use('/api/user-events', userEventsRoutes);

const signToken = (userId) =>
  jwt.sign({ userId, email: 'test@example.com' }, process.env.JWT_SECRET);

const CLIENT_EVENT_ID = '11111111-1111-4111-8111-111111111111';

describe('POST /api/user-events', () => {
  let bulkCreate;

  beforeEach(() => {
    bulkCreate = jest.fn();
    getDatabase.mockReturnValue({ UserEvent: { bulkCreate } });
  });

  it('stores a valid batch and returns events_stored', async () => {
    bulkCreate.mockResolvedValue([{ id: 'u1' }, { id: 'u2' }]);

    const res = await request(app)
      .post('/api/user-events')
      .set('Authorization', `Bearer ${signToken(42)}`)
      .send({
        events: [
          { action: 'screen_opened', client_event_id: CLIENT_EVENT_ID, screen_name: 'accounts', metadata: {} },
          { action: 'user_logged_in', client_event_id: '22222222-2222-4222-8222-222222222222' },
        ],
      });

    expect(res.status).toBe(200);
    expect(res.body).toEqual({ success: true, events_stored: 2 });
    expect(bulkCreate).toHaveBeenCalledWith(
      [
        { user_id: 42, client_event_id: CLIENT_EVENT_ID, action: 'screen_opened', screen_name: 'accounts', metadata: {} },
        { user_id: 42, client_event_id: '22222222-2222-4222-8222-222222222222', action: 'user_logged_in', screen_name: null, metadata: {} },
      ],
      { ignoreDuplicates: true }
    );
  });

  it('derives user_id from the JWT, ignoring any user_id in the body', async () => {
    bulkCreate.mockResolvedValue([{ id: 'u1' }]);

    const res = await request(app)
      .post('/api/user-events')
      .set('Authorization', `Bearer ${signToken(7)}`)
      .send({ events: [{ action: 'account_created', client_event_id: CLIENT_EVENT_ID, user_id: 999, metadata: {} }] });

    expect(res.status).toBe(200);
    expect(bulkCreate).toHaveBeenCalledWith(
      [
        { user_id: 7, client_event_id: CLIENT_EVENT_ID, action: 'account_created', screen_name: null, metadata: {} },
      ],
      { ignoreDuplicates: true }
    );
  });

  it('rejects a batch with more than 100 events', async () => {
    const events = Array.from({ length: 101 }, (_, i) => ({ action: `action_${i}` }));

    const res = await request(app)
      .post('/api/user-events')
      .set('Authorization', `Bearer ${signToken(1)}`)
      .send({ events });

    expect(res.status).toBe(400);
    expect(bulkCreate).not.toHaveBeenCalled();
  });

  it('rejects a non-array events body', async () => {
    const res = await request(app)
      .post('/api/user-events')
      .set('Authorization', `Bearer ${signToken(1)}`)
      .send({ events: 'not-an-array' });

    expect(res.status).toBe(400);
  });

  it('rejects an empty batch', async () => {
    const res = await request(app)
      .post('/api/user-events')
      .set('Authorization', `Bearer ${signToken(1)}`)
      .send({ events: [] });

    expect(res.status).toBe(400);
  });

  it('rejects an event with an empty action', async () => {
    const res = await request(app)
      .post('/api/user-events')
      .set('Authorization', `Bearer ${signToken(1)}`)
      .send({ events: [{ action: '' }] });

    expect(res.status).toBe(400);
    expect(res.body.error.details.field).toBe('action');
  });

  it('rejects an event missing client_event_id', async () => {
    const res = await request(app)
      .post('/api/user-events')
      .set('Authorization', `Bearer ${signToken(1)}`)
      .send({ events: [{ action: 'screen_opened' }] });

    expect(res.status).toBe(400);
    expect(res.body.error.details.field).toBe('client_event_id');
  });

  it('rejects a request without a JWT', async () => {
    const res = await request(app)
      .post('/api/user-events')
      .send({ events: [{ action: 'screen_opened' }] });

    expect(res.status).toBe(401);
  });
});
