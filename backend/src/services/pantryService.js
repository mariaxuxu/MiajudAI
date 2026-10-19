import { getDatabase } from '../config/database.js';

export const getCatalogItems = async () => {
  const { PantryItem } = getDatabase();
  const items = await PantryItem.findAll({
    order: [
      ['domain', 'ASC'],
      ['name', 'ASC'],
    ],
  });
  return items;
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
// it is. Idempotent on commit_key: inserting the key first means a replay
// collides on UNIQUE (user_id, commit_key) and becomes a no-op, which also
// makes two concurrent identical commits safe (the loser rolls back).
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

    const owned = await UserPantry.findAll({
      where: { user_id: userId, item_id: [...quantitiesByItem.keys()] },
      transaction,
    });
    const ownedIds = new Set(owned.map((row) => row.item_id));

    for (const [itemId, quantity] of quantitiesByItem) {
      if (ownedIds.has(itemId)) {
        // increment issues a single `SET quantity = quantity + N`, which keeps
        // concurrent commits from clobbering each other — but it also skips
        // updated_at (the model is timestamps:false), so the stamp is applied
        // separately to keep the pantry ordering honest.
        await UserPantry.increment(
          { quantity },
          { where: { user_id: userId, item_id: itemId }, transaction }
        );
        await UserPantry.update(
          { updated_at: new Date() },
          { where: { user_id: userId, item_id: itemId }, transaction }
        );
      } else {
        await UserPantry.create(
          { user_id: userId, item_id: itemId, quantity },
          { transaction }
        );
      }
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
  getUserPantry,
  commitPantry,
  updateQuantity,
  removeItem,
};
