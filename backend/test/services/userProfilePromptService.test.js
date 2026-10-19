import { jest, describe, it, expect, beforeEach } from '@jest/globals';

jest.unstable_mockModule('../../src/config/database.js', () => ({
  getDatabase: jest.fn(),
}));

jest.unstable_mockModule('../../src/services/pantryService.js', () => ({
  default: { getUserPantry: jest.fn() },
}));

const pantryService = (await import('../../src/services/pantryService.js')).default;
const { buildPantryContext } = await import(
  '../../src/services/userProfilePromptService.js'
);

const USER_ID = 9;

const row = (name, domain, quantity) => ({
  quantity,
  PantryItem: { name, domain },
});

const FOOD_ROWS = [
  row('Arroz', 'food', 2),
  row('Feijão', 'food', 1),
  row('Ovos', 'food', 6),
  row('Frango', 'food', 2),
];

const DOMESTIC_ROWS = [row('Detergente', 'domestic', 1), row('Rodo', 'domestic', 1)];

describe('buildPantryContext', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    pantryService.getUserPantry.mockResolvedValue([]);
  });

  it('formats a compact list carrying quantities, in the order read from the pantry', async () => {
    pantryService.getUserPantry.mockResolvedValue(FOOD_ROWS);

    const context = await buildPantryContext(USER_ID, 'otto');

    expect(context).toBe('Despensa (cozinha): Arroz (2), Feijão (1), Ovos (6), Frango (2).');
  });

  it('reads the pantry of the given user', async () => {
    await buildPantryContext(USER_ID, 'otto');

    expect(pantryService.getUserPantry).toHaveBeenCalledWith(USER_ID);
  });

  it('gives Otto only food items from a mixed pantry', async () => {
    pantryService.getUserPantry.mockResolvedValue([...FOOD_ROWS, ...DOMESTIC_ROWS]);

    const context = await buildPantryContext(USER_ID, 'otto');

    expect(context).toContain('Arroz');
    expect(context).not.toContain('Detergente');
    expect(context).not.toContain('Rodo');
  });

  it('gives Tina only domestic items, labelled doméstico', async () => {
    pantryService.getUserPantry.mockResolvedValue([...FOOD_ROWS, ...DOMESTIC_ROWS]);

    const context = await buildPantryContext(USER_ID, 'tina');

    expect(context).toBe('Despensa (doméstico): Detergente (1), Rodo (1).');
  });

  it('gives Luna no pantry block at all, without reading the pantry', async () => {
    pantryService.getUserPantry.mockResolvedValue([...FOOD_ROWS, ...DOMESTIC_ROWS]);

    const context = await buildPantryContext(USER_ID, 'luna');

    expect(context).toBe('');
    expect(pantryService.getUserPantry).not.toHaveBeenCalled();
  });

  it('produces no block for an empty pantry', async () => {
    pantryService.getUserPantry.mockResolvedValue([]);

    expect(await buildPantryContext(USER_ID, 'otto')).toBe('');
  });

  it('produces no block for Otto when the user owns only domestic items', async () => {
    pantryService.getUserPantry.mockResolvedValue(DOMESTIC_ROWS);

    expect(await buildPantryContext(USER_ID, 'otto')).toBe('');
  });

  it('produces no block for Tina when the user owns only food items', async () => {
    pantryService.getUserPantry.mockResolvedValue(FOOD_ROWS);

    expect(await buildPantryContext(USER_ID, 'tina')).toBe('');
  });

  it('produces no block for an unknown agent', async () => {
    pantryService.getUserPantry.mockResolvedValue(FOOD_ROWS);

    expect(await buildPantryContext(USER_ID, 'zeca')).toBe('');
  });

  it('accepts the agent key case-insensitively', async () => {
    pantryService.getUserPantry.mockResolvedValue(FOOD_ROWS);

    expect(await buildPantryContext(USER_ID, 'OTTO')).toContain('Arroz');
  });

  it('truncates to exactly the character limit, following the diary builder', async () => {
    pantryService.getUserPantry.mockResolvedValue(
      Array.from({ length: 40 }, (_, i) => row(`Item ${i}`, 'food', i + 1))
    );

    const context = await buildPantryContext(USER_ID, 'otto', 60);

    expect(context.length).toBe(60);
    expect(context.endsWith('...')).toBe(true);
  });

  it('does not truncate a block that fits under the limit', async () => {
    pantryService.getUserPantry.mockResolvedValue(FOOD_ROWS);

    const context = await buildPantryContext(USER_ID, 'otto', 1000);

    expect(context.endsWith('...')).toBe(false);
    expect(context).toBe('Despensa (cozinha): Arroz (2), Feijão (1), Ovos (6), Frango (2).');
  });

  it('omits the block instead of throwing when the pantry read fails', async () => {
    pantryService.getUserPantry.mockRejectedValue(new Error('db down'));

    expect(await buildPantryContext(USER_ID, 'otto')).toBe('');
  });
});
