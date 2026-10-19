import { jest, describe, it, expect, beforeEach } from '@jest/globals';

jest.unstable_mockModule('../../src/config/database.js', () => ({
  getDatabase: jest.fn(),
}));

const { getDatabase } = await import('../../src/config/database.js');
const pantryService = await import('../../src/services/pantryService.js');

const USER_ID = 9;

const makeItem = (overrides = {}) => ({
  id: 12,
  name: 'Arroz',
  emoji: '🍚',
  domain: 'food',
  ...overrides,
});

const makeRow = (overrides = {}) => ({
  id: 1,
  user_id: USER_ID,
  item_id: 12,
  quantity: 2,
  ...overrides,
});

describe('pantryService', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe('getUserPantry', () => {
    it('reads only the authenticated user rows, with catalog details attached', async () => {
      const rows = [makeRow({ PantryItem: makeItem() })];
      const findAll = jest.fn().mockResolvedValue(rows);
      getDatabase.mockReturnValue({ UserPantry: { findAll } });

      const result = await pantryService.getUserPantry(USER_ID);

      expect(findAll).toHaveBeenCalledTimes(1);
      const [args] = findAll.mock.calls[0];
      expect(args.where).toEqual({ user_id: USER_ID });
      expect(result).toBe(rows);
    });

    it('scopes the read by user_id so another user rows never leak in', async () => {
      const findAll = jest.fn().mockResolvedValue([]);
      getDatabase.mockReturnValue({ UserPantry: { findAll } });

      await pantryService.getUserPantry(USER_ID);

      const [args] = findAll.mock.calls[0];
      expect(args.where.user_id).toBe(USER_ID);
    });
  });

  describe('updateQuantity', () => {
    it('updates the quantity of a row the user owns', async () => {
      const row = {
        ...makeRow({ quantity: 2 }),
        save: jest.fn().mockResolvedValue(undefined),
      };
      const findOne = jest.fn().mockResolvedValue(row);
      getDatabase.mockReturnValue({ UserPantry: { findOne } });

      await pantryService.updateQuantity(USER_ID, 12, 5);

      expect(row.quantity).toBe(5);
      expect(row.save).toHaveBeenCalledTimes(1);
    });

    it('scopes the lookup by user_id and item_id', async () => {
      const row = {
        ...makeRow(),
        save: jest.fn().mockResolvedValue(undefined),
      };
      const findOne = jest.fn().mockResolvedValue(row);
      getDatabase.mockReturnValue({ UserPantry: { findOne } });

      await pantryService.updateQuantity(USER_ID, 12, 4);

      const [args] = findOne.mock.calls[0];
      expect(args.where).toEqual({ user_id: USER_ID, item_id: 12 });
    });

    it('removes the row when the new quantity is 0', async () => {
      const row = {
        ...makeRow({ quantity: 3 }),
        save: jest.fn(),
        destroy: jest.fn().mockResolvedValue(undefined),
      };
      const findOne = jest.fn().mockResolvedValue(row);
      getDatabase.mockReturnValue({ UserPantry: { findOne } });

      const result = await pantryService.updateQuantity(USER_ID, 12, 0);

      expect(result).toBeNull();
      expect(row.destroy).toHaveBeenCalledTimes(1);
      expect(row.save).not.toHaveBeenCalled();
    });

    it('throws when the row does not belong to the user (foreign item id)', async () => {
      const destroy = jest.fn();
      const findOne = jest.fn().mockResolvedValue(null);
      getDatabase.mockReturnValue({ UserPantry: { findOne, destroy } });

      await expect(pantryService.updateQuantity(USER_ID, 999, 5)).rejects.toThrow(
        'Pantry item not found'
      );
      expect(destroy).not.toHaveBeenCalled();
      expect(findOne).toHaveBeenCalledWith({
        where: { user_id: USER_ID, item_id: 999 },
      });
    });
  });

  describe('removeItem', () => {
    it('removes a row the user owns and reports the removal', async () => {
      const row = {
        ...makeRow(),
        destroy: jest.fn().mockResolvedValue(undefined),
      };
      const findOne = jest.fn().mockResolvedValue(row);
      getDatabase.mockReturnValue({ UserPantry: { findOne } });

      const removed = await pantryService.removeItem(USER_ID, 12);

      expect(removed).toBe(true);
      expect(row.destroy).toHaveBeenCalledTimes(1);
    });

    it('throws and touches nothing for a foreign item id', async () => {
      const findOne = jest.fn().mockResolvedValue(null);
      getDatabase.mockReturnValue({ UserPantry: { findOne } });

      await expect(pantryService.removeItem(USER_ID, 999)).rejects.toThrow(
        'Pantry item not found'
      );
      const [args] = findOne.mock.calls[0];
      expect(args.where).toEqual({ user_id: USER_ID, item_id: 999 });
    });
  });
});
