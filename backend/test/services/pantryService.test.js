import { jest, describe, it, expect, beforeEach } from '@jest/globals';

jest.unstable_mockModule('../../src/config/database.js', () => ({
  getDatabase: jest.fn(),
}));

const { getDatabase } = await import('../../src/config/database.js');
const pantryService = await import('../../src/services/pantryService.js');

const USER_ID = 9;
const COMMIT_KEY = '11111111-1111-4111-8111-111111111111';

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

  describe('createCatalogItem', () => {
    it('creates a global row with the domain default emoji', async () => {
      const create = jest.fn().mockResolvedValue({ id: 41, name: 'Tofu', emoji: '🍽️', domain: 'food' });
      getDatabase.mockReturnValue({ PantryItem: { create } });

      await pantryService.createCatalogItem('Tofu', 'food');

      expect(create).toHaveBeenCalledTimes(1);
      const [values] = create.mock.calls[0];
      expect(values.name).toBe('Tofu');
      expect(values.domain).toBe('food');
      expect(values.emoji).toBe('🍽️');
      // The catalog is global — nothing about the creator is stored.
      expect(values.user_id).toBeUndefined();
    });

    it('uses the domestic default emoji for a domestic item', async () => {
      const create = jest.fn().mockResolvedValue({});
      getDatabase.mockReturnValue({ PantryItem: { create } });

      await pantryService.createCatalogItem('Rodo', 'domestic');

      expect(create.mock.calls[0][0].emoji).toBe('🧹');
    });

    it('trims the name before storing it', async () => {
      const create = jest.fn().mockResolvedValue({});
      getDatabase.mockReturnValue({ PantryItem: { create } });

      await pantryService.createCatalogItem('  Tofu  ', 'food');

      expect(create.mock.calls[0][0].name).toBe('Tofu');
    });

    it('rejects an invalid domain', async () => {
      const create = jest.fn();
      getDatabase.mockReturnValue({ PantryItem: { create } });

      await expect(
        pantryService.createCatalogItem('Tofu', 'cooking')
      ).rejects.toThrow('Domain must be one of');
      expect(create).not.toHaveBeenCalled();
    });

    it('rejects an empty name', async () => {
      const create = jest.fn();
      getDatabase.mockReturnValue({ PantryItem: { create } });

      await expect(pantryService.createCatalogItem('   ', 'food')).rejects.toThrow(
        'Name is required'
      );
      expect(create).not.toHaveBeenCalled();
    });

    it('rejects a non-string name', async () => {
      const create = jest.fn();
      getDatabase.mockReturnValue({ PantryItem: { create } });

      await expect(pantryService.createCatalogItem(42, 'food')).rejects.toThrow(
        'Name is required'
      );
      expect(create).not.toHaveBeenCalled();
    });
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

    it('loads the catalog item so the returned row carries name/emoji/domain', async () => {
      const row = {
        ...makeRow({ PantryItem: makeItem() }),
        save: jest.fn().mockResolvedValue(undefined),
      };
      const findOne = jest.fn().mockResolvedValue(row);
      getDatabase.mockReturnValue({ UserPantry: { findOne }, PantryItem: {} });

      const updated = await pantryService.updateQuantity(USER_ID, 12, 5);

      const [args] = findOne.mock.calls[0];
      expect(args.include[0].model).toBeDefined();
      expect(updated.PantryItem.name).toBe('Arroz');
    });

    it('stamps updated_at on save so ordering reflects the edit', async () => {
      const row = {
        ...makeRow({ quantity: 2, updated_at: new Date('2020-01-01') }),
        save: jest.fn().mockResolvedValue(undefined),
      };
      const findOne = jest.fn().mockResolvedValue(row);
      getDatabase.mockReturnValue({ UserPantry: { findOne } });

      const before = Date.now();
      await pantryService.updateQuantity(USER_ID, 12, 7);

      expect(row.updated_at.getTime()).toBeGreaterThanOrEqual(before);
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
      const [args] = findOne.mock.calls[0];
      expect(args.where).toEqual({ user_id: USER_ID, item_id: 999 });
    });
  });

  describe('commitPantry', () => {
    const mkTx = () => ({ transaction: jest.fn((cb) => cb('tx')) });

    it('increments in SQL so an owned row accumulates (3 + 2 = 5)', async () => {
      const query = jest.fn().mockResolvedValue([]);
      getDatabase.mockReturnValue({
        sequelize: { transaction: jest.fn((cb) => cb('tx')), query },
        PantryItem: { findAll: jest.fn().mockResolvedValue([{ id: 1 }]) },
        PantryCommit: { create: jest.fn().mockResolvedValue({}) },
      });

      const result = await pantryService.commitPantry(USER_ID, COMMIT_KEY, [
        { item_id: 1, quantity: 2 },
      ]);

      expect(query).toHaveBeenCalledTimes(1);
      const [sql, options] = query.mock.calls[0];
      // The accumulation must happen in the database, not in JS — that is what
      // keeps concurrent commits from overwriting each other.
      expect(sql).toContain('user_pantry.quantity + EXCLUDED.quantity');
      expect(sql).toContain('ON CONFLICT (user_id, item_id)');
      expect(options.replacements).toEqual({ userId: USER_ID, itemId: 1, quantity: 2 });
      expect(options.transaction).toBe('tx');
      expect(result.applied).toBe(true);
    });

    it('uses the same statement to create a row for an unowned item', async () => {
      // Create and increment are one path: the INSERT half of the upsert
      // handles an item the user does not own yet, so there is no separate
      // create branch to race with.
      const query = jest.fn().mockResolvedValue([]);
      getDatabase.mockReturnValue({
        sequelize: { transaction: jest.fn((cb) => cb('tx')), query },
        PantryItem: { findAll: jest.fn().mockResolvedValue([{ id: 2 }]) },
        PantryCommit: { create: jest.fn().mockResolvedValue({}) },
      });

      await pantryService.commitPantry(USER_ID, COMMIT_KEY, [{ item_id: 2, quantity: 4 }]);

      expect(query).toHaveBeenCalledTimes(1);
      const [sql, options] = query.mock.calls[0];
      expect(sql).toContain('INSERT INTO user_pantry');
      expect(options.replacements.itemId).toBe(2);
    });

    it('is a no-op when the commit_key was already applied', async () => {
      const increment = jest.fn();
      const create = jest.fn();
      const conflict = Object.assign(new Error('duplicate key'), {
        name: 'SequelizeUniqueConstraintError',
      });
      getDatabase.mockReturnValue({
        sequelize: mkTx(),
        PantryItem: { findAll: jest.fn().mockResolvedValue([{ id: 1 }]) },
        UserPantry: { findAll: jest.fn(), increment, create },
        PantryCommit: { create: jest.fn().mockRejectedValue(conflict) },
      });

      const result = await pantryService.commitPantry(USER_ID, COMMIT_KEY, [
        { item_id: 1, quantity: 2 },
      ]);

      expect(result.applied).toBe(false);
      expect(increment).not.toHaveBeenCalled();
      expect(create).not.toHaveBeenCalled();
    });

    it('scopes every write to the authenticated user', async () => {
      const query = jest.fn().mockResolvedValue([]);
      const commitCreate = jest.fn().mockResolvedValue({});
      getDatabase.mockReturnValue({
        sequelize: { transaction: jest.fn((cb) => cb('tx')), query },
        PantryItem: { findAll: jest.fn().mockResolvedValue([{ id: 1 }]) },
        PantryCommit: { create: commitCreate },
      });

      await pantryService.commitPantry(USER_ID, COMMIT_KEY, [{ item_id: 1, quantity: 1 }]);

      expect(commitCreate).toHaveBeenCalledWith(
        { user_id: USER_ID, commit_key: COMMIT_KEY },
        { transaction: 'tx' }
      );
      expect(query.mock.calls[0][1].replacements.userId).toBe(USER_ID);
    });

    it('rejects an item_id that is not in the catalog instead of skipping it', async () => {
      getDatabase.mockReturnValue({
        sequelize: mkTx(),
        PantryItem: { findAll: jest.fn().mockResolvedValue([{ id: 1 }]) },
        PantryCommit: { create: jest.fn().mockResolvedValue({}) },
      });

      await expect(
        pantryService.commitPantry(USER_ID, COMMIT_KEY, [{ item_id: 999, quantity: 1 }])
      ).rejects.toThrow('Unknown catalog item: 999');
    });

    it('aggregates duplicate item_ids into one write', async () => {
      const query = jest.fn().mockResolvedValue([]);
      getDatabase.mockReturnValue({
        sequelize: { transaction: jest.fn((cb) => cb('tx')), query },
        PantryItem: { findAll: jest.fn().mockResolvedValue([{ id: 1 }]) },
        PantryCommit: { create: jest.fn().mockResolvedValue({}) },
      });

      await pantryService.commitPantry(USER_ID, COMMIT_KEY, [
        { item_id: 1, quantity: 2 },
        { item_id: 1, quantity: 3 },
      ]);

      expect(query).toHaveBeenCalledTimes(1);
      expect(query.mock.calls[0][1].replacements.quantity).toBe(5);
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
