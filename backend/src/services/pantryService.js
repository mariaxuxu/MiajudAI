import { getDatabase } from '../config/database.js';

const getCatalogItems = async () => {
  const { PantryItem } = getDatabase();
  const items = await PantryItem.findAll({
    order: [
      ['domain', 'ASC'],
      ['name', 'ASC'],
    ],
  });
  return items;
};

export default {
  getCatalogItems,
};
