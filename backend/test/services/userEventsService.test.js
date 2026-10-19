import { jest, describe, it, expect } from '@jest/globals';

jest.unstable_mockModule('../../src/config/database.js', () => ({
  getDatabase: jest.fn(),
}));

const { getDatabase } = await import('../../src/config/database.js');
const { validateUserEvent, storeUserEvents, MAX_BATCH_SIZE } = await import(
  '../../src/services/userEventsService.js'
);

const CLIENT_EVENT_ID = '11111111-1111-4111-8111-111111111111';

describe('userEventsService', () => {
  describe('validateUserEvent', () => {
    it('accepts a minimal event (action + client_event_id)', () => {
      expect(() =>
        validateUserEvent({ action: 'screen_opened', client_event_id: CLIENT_EVENT_ID })
      ).not.toThrow();
    });

    it('accepts a full event with screen_name and metadata', () => {
      expect(() =>
        validateUserEvent({
          action: 'expense_added',
          client_event_id: CLIENT_EVENT_ID,
          screen_name: 'expenses',
          metadata: { expense_id: 1 },
        })
      ).not.toThrow();
    });

    it('rejects a non-object event', () => {
      expect(() => validateUserEvent(null)).toThrow('Event must be an object');
      expect(() => validateUserEvent('not-an-object')).toThrow('Event must be an object');
    });

    it('rejects a missing action', () => {
      expect(() => validateUserEvent({ screen_name: 'accounts' })).toThrow('Action is required');
    });

    it('rejects an empty action', () => {
      expect(() => validateUserEvent({ action: '', client_event_id: CLIENT_EVENT_ID })).toThrow('Action is required');
      expect(() => validateUserEvent({ action: '   ', client_event_id: CLIENT_EVENT_ID })).toThrow('Action is required');
    });

    it('rejects a non-string action', () => {
      expect(() => validateUserEvent({ action: 42, client_event_id: CLIENT_EVENT_ID })).toThrow('Action is required');
    });

    it('rejects an action longer than 100 chars', () => {
      expect(() => validateUserEvent({ action: 'a'.repeat(101), client_event_id: CLIENT_EVENT_ID })).toThrow('at most 100');
    });

    it('accepts an action exactly 100 chars', () => {
      expect(() => validateUserEvent({ action: 'a'.repeat(100), client_event_id: CLIENT_EVENT_ID })).not.toThrow();
    });

    it('rejects a screen_name longer than 100 chars', () => {
      expect(() =>
        validateUserEvent({ action: 'x', client_event_id: CLIENT_EVENT_ID, screen_name: 's'.repeat(101) })
      ).toThrow('Screen name must be at most 100');
    });

    it('rejects a non-string screen_name', () => {
      expect(() =>
        validateUserEvent({ action: 'x', client_event_id: CLIENT_EVENT_ID, screen_name: 42 })
      ).toThrow('Screen name must be a string');
    });

    it('rejects non-object metadata', () => {
      expect(() =>
        validateUserEvent({ action: 'x', client_event_id: CLIENT_EVENT_ID, metadata: [1, 2] })
      ).toThrow('Metadata must be an object');
      expect(() =>
        validateUserEvent({ action: 'x', client_event_id: CLIENT_EVENT_ID, metadata: 'text' })
      ).toThrow('Metadata must be an object');
    });

    it('allows null metadata and screen_name', () => {
      expect(() =>
        validateUserEvent({ action: 'x', client_event_id: CLIENT_EVENT_ID, screen_name: null, metadata: null })
      ).not.toThrow();
    });

    it('rejects a missing client_event_id', () => {
      expect(() => validateUserEvent({ action: 'x' })).toThrow('Client event ID is required');
    });

    it('rejects a malformed client_event_id', () => {
      expect(() =>
        validateUserEvent({ action: 'x', client_event_id: 'not-a-uuid' })
      ).toThrow('Client event ID is required');
    });
  });

  describe('storeUserEvents', () => {
    it('bulk-creates mapped records with user_id and default metadata', async () => {
      const bulkCreate = jest.fn().mockResolvedValue([{ id: 'u1' }, { id: 'u2' }]);
      getDatabase.mockReturnValue({ UserEvent: { bulkCreate } });

      const created = await storeUserEvents(42, [
        { action: ' screen_opened ', client_event_id: CLIENT_EVENT_ID, screen_name: ' accounts ', metadata: {} },
        { action: 'user_logged_in', client_event_id: '22222222-2222-4222-8222-222222222222' },
      ]);

      expect(bulkCreate).toHaveBeenCalledWith(
        [
          { user_id: 42, client_event_id: CLIENT_EVENT_ID, action: 'screen_opened', screen_name: 'accounts', metadata: {} },
          { user_id: 42, client_event_id: '22222222-2222-4222-8222-222222222222', action: 'user_logged_in', screen_name: null, metadata: {} },
        ],
        { ignoreDuplicates: true }
      );
      expect(created).toHaveLength(2);
    });
  });

  describe('MAX_BATCH_SIZE', () => {
    it('is 100', () => {
      expect(MAX_BATCH_SIZE).toBe(100);
    });
  });
});
