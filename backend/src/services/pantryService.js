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
  const { UserPantry } = getDatabase();
  const row = await UserPantry.findOne({
    where: { user_id: userId, item_id: itemId },
  });

  if (!row) {
    throw new Error('Pantry item not found');
  }

  if (quantity === 0) {
    await row.destroy();
    return null;
  }

  row.quantity = quantity;
  await row.save();
  return row;
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
  updateQuantity,
  removeItem,
};
