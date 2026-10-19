import { getDatabase } from '../config/database.js';
import {
  PANTRY_DOMAIN_VALUES,
  PANTRY_DOMAIN_DEFAULT_EMOJI,
  PANTRY_ITEM_NAME_MAX_LENGTH,
} from '../utils/constants.js';

// Alphabetical by name. The client filters by domain locally, so a subset
// (Cozinha / Doméstico) stays alphabetical too — ordering by domain first
// would instead split "Todos" into two blocks instead of one A→Z list.
export const getCatalogItems = async () => {
  const { PantryItem } = getDatabase();
  const items = await PantryItem.findAll({
    order: [['name', 'ASC']],
  });
  return items;
};

// Writes a row into the global catalog. The emoji is derived from the domain
// rather than supplied, so creating an item stays a two-field operation.
//
// Deliberately no user_id on the row: the catalog is shared by every user and
// carries no creator attribution. There is also deliberately no uniqueness
// check on the name — duplicate prevention is a client-side suggestion gate,
// because legitimate spelling variations must not be blocked.
export const createCatalogItem = async (name, domain) => {
  const { PantryItem } = getDatabase();

  const trimmedName = typeof name === 'string' ? name.trim() : '';
  if (!trimmedName) {
    throw new Error('Name is required');
  }
  if (trimmedName.length > PANTRY_ITEM_NAME_MAX_LENGTH) {
    throw new Error(`Name must be at most ${PANTRY_ITEM_NAME_MAX_LENGTH} characters`);
  }
  if (!PANTRY_DOMAIN_VALUES.includes(domain)) {
    throw new Error(`Domain must be one of: ${PANTRY_DOMAIN_VALUES.join(', ')}`);
  }

  const item = await PantryItem.create({
    name: trimmedName,
    emoji: PANTRY_DOMAIN_DEFAULT_EMOJI[domain],
    domain,
  });
  return item;
};

export const getUserPantry = async (userId) => {
  const { UserPantry, PantryItem } = getDatabase();
  const rows = await UserPantry.findAll({
    where: { user_id: userId },
    include: [
      {
        model: PantryItem,
        attributes: ['id', 'name', 'emoji', 'domain'],
      },
    ],
    order: [['updated_at', 'DESC']],
  });
  return rows;
};

// Quantity is a pack count; 0 is represented by the absence of the row, so
// hitting 0 removes it rather than storing a zero (which the DB forbids).
export const updateQuantity = async (userId, itemId, quantity) => {
  const { UserPantry, PantryItem } = getDatabase();
  const row = await UserPantry.findOne({
    where: { user_id: userId, item_id: itemId },
    include: [
      {
        model: PantryItem,
        attributes: ['id', 'name', 'emoji', 'domain'],
      },
    ],
  });

  if (!row) {
    throw new Error('Pantry item not found');
  }

  if (quantity === 0) {
    await row.destroy();
    return null;
  }

  row.quantity = quantity;
  // The model is timestamps:false, so updated_at is a plain column Sequelize
  // does not maintain — set it explicitly to keep the pantry ordering honest.
  row.updated_at = new Date();
  await row.save();
  return row;
};

// Records a whole market trip at once. Increment semantics: committing 2 onto
// an owned 3 leaves 5. All-or-nothing — the whole trip is written or none of
// it is.
//
// Idempotent on commit_key: the key is inserted first, so a replay collides on
// UNIQUE (user_id, commit_key). Postgres aborts the transaction on that error,
// so the subsequent COMMIT degrades to a ROLLBACK — which is exactly the no-op
// wanted, and why returning early here is safe.
//
// The key insert is deliberately the first statement, and a concurrent
// duplicate blocks on the unique index until the winner commits, so it can
// never reach the pantry writes and double-increment.
export const commitPantry = async (userId, commitKey, items) => {
  const { sequelize, UserPantry, PantryItem, PantryCommit } = getDatabase();

  // Collapse repeated item_ids so a cart listing the same item twice becomes
  // one write instead of two.
  const quantitiesByItem = new Map();
  for (const { item_id: itemId, quantity } of items) {
    quantitiesByItem.set(itemId, (quantitiesByItem.get(itemId) || 0) + quantity);
  }

  const catalogItems = await PantryItem.findAll({
    where: { id: [...quantitiesByItem.keys()] },
    attributes: ['id'],
  });
  const knownIds = new Set(catalogItems.map((item) => item.id));
  for (const itemId of quantitiesByItem.keys()) {
    if (!knownIds.has(itemId)) {
      throw new Error(`Unknown catalog item: ${itemId}`);
    }
  }

  return sequelize.transaction(async (transaction) => {
    let replayed = false;
    try {
      await PantryCommit.create(
        { user_id: userId, commit_key: commitKey },
        { transaction }
      );
    } catch (error) {
      if (error.name !== 'SequelizeUniqueConstraintError') {
        throw error;
      }
      replayed = true;
    }

    if (replayed) {
      return { applied: false };
    }

    // One statement per item: create the row, or add to the quantity that is
    // already there. Incrementing in SQL (rather than reading and writing
    // back) is what makes concurrent commits sum instead of clobbering each
    // other, and ON CONFLICT resolves the case where two trips with different
    // commit_keys create the same new item on top of each other — the loser
    // waits on the unique index and then takes the DO UPDATE branch.
    //
    // Deliberately not a try/catch around a plain INSERT: a constraint error
    // aborts the enclosing Postgres transaction, so any recovery write after
    // catching it would silently never run.
    for (const [itemId, quantity] of quantitiesByItem) {
      await sequelize.query(
        `INSERT INTO user_pantry (user_id, item_id, quantity, created_at, updated_at)
         VALUES (:userId, :itemId, :quantity, NOW(), NOW())
         ON CONFLICT (user_id, item_id)
         DO UPDATE SET quantity = user_pantry.quantity + EXCLUDED.quantity,
                       updated_at = NOW()`,
        {
          replacements: { userId, itemId, quantity },
          transaction,
        }
      );
    }

    return { applied: true };
  });
};

export const removeItem = async (userId, itemId) => {
  const { UserPantry } = getDatabase();
  const row = await UserPantry.findOne({
    where: { user_id: userId, item_id: itemId },
  });

  if (!row) {
    throw new Error('Pantry item not found');
  }

  await row.destroy();
  return true;
};

export default {
  getCatalogItems,
  createCatalogItem,
  getUserPantry,
  commitPantry,
  updateQuantity,
  removeItem,
};
