import pantryService from '../services/pantryService.js';
import { HTTP_STATUS, ERROR_MESSAGES } from '../utils/constants.js';

const serializePantryRow = (row) => ({
  id: row.id,
  user_id: row.user_id,
  item_id: row.item_id,
  quantity: row.quantity,
  item: row.PantryItem
    ? {
        id: row.PantryItem.id,
        name: row.PantryItem.name,
        emoji: row.PantryItem.emoji,
        domain: row.PantryItem.domain,
      }
    : null,
  created_at: row.created_at,
  updated_at: row.updated_at,
});

const isPositiveInteger = (value) => Number.isInteger(value) && value > 0;
const isNonNegativeInteger = (value) => Number.isInteger(value) && value >= 0;

export const getCatalogItems = async (req, res) => {
  try {
    const items = await pantryService.getCatalogItems();

    return res.status(HTTP_STATUS.OK).json({
      success: true,
      items: items.map((item) => ({
        id: item.id,
        name: item.name,
        emoji: item.emoji,
        domain: item.domain,
        created_at: item.created_at,
      })),
    });
  } catch (error) {
    console.error('Get pantry catalog error:', error);
    return res.status(HTTP_STATUS.INTERNAL_SERVER_ERROR).json({
      error: {
        statusCode: HTTP_STATUS.INTERNAL_SERVER_ERROR,
        message: ERROR_MESSAGES.INTERNAL_ERROR,
      },
    });
  }
};

export const getPantry = async (req, res) => {
  try {
    const userId = req.user.userId;
    const rows = await pantryService.getUserPantry(userId);

    return res.status(HTTP_STATUS.OK).json({
      success: true,
      pantry: rows.map(serializePantryRow),
    });
  } catch (error) {
    console.error('Get pantry error:', error);
    return res.status(HTTP_STATUS.INTERNAL_SERVER_ERROR).json({
      error: {
        statusCode: HTTP_STATUS.INTERNAL_SERVER_ERROR,
        message: ERROR_MESSAGES.INTERNAL_ERROR,
      },
    });
  }
};

export const updatePantryQuantity = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { item_id, quantity } = req.body;

    if (!isPositiveInteger(item_id)) {
      return res.status(HTTP_STATUS.BAD_REQUEST).json({
        error: {
          statusCode: HTTP_STATUS.BAD_REQUEST,
          message: 'Missing or invalid field: item_id must be a positive integer',
        },
      });
    }

    if (!isNonNegativeInteger(quantity)) {
      return res.status(HTTP_STATUS.BAD_REQUEST).json({
        error: {
          statusCode: HTTP_STATUS.BAD_REQUEST,
          message: 'Missing or invalid field: quantity must be a non-negative integer',
        },
      });
    }

    const row = await pantryService.updateQuantity(userId, item_id, quantity);

    // quantity 0 is represented by the absence of a row: report the removal.
    if (!row) {
      return res.status(HTTP_STATUS.OK).json({
        success: true,
        removed: true,
        item_id,
      });
    }

    return res.status(HTTP_STATUS.OK).json({
      success: true,
      pantry_item: serializePantryRow(row),
    });
  } catch (error) {
    console.error('Update pantry quantity error:', error);

    if (error.message === 'Pantry item not found') {
      return res.status(HTTP_STATUS.NOT_FOUND).json({
        error: {
          statusCode: HTTP_STATUS.NOT_FOUND,
          message: ERROR_MESSAGES.NOT_FOUND,
        },
      });
    }

    return res.status(HTTP_STATUS.INTERNAL_SERVER_ERROR).json({
      error: {
        statusCode: HTTP_STATUS.INTERNAL_SERVER_ERROR,
        message: ERROR_MESSAGES.INTERNAL_ERROR,
        details: error.message,
      },
    });
  }
};

export const deletePantryItem = async (req, res) => {
  try {
    const userId = req.user.userId;
    const itemId = parseInt(req.params.itemId, 10);

    if (!isPositiveInteger(itemId)) {
      return res.status(HTTP_STATUS.BAD_REQUEST).json({
        error: {
          statusCode: HTTP_STATUS.BAD_REQUEST,
          message: 'Invalid item id',
        },
      });
    }

    await pantryService.removeItem(userId, itemId);

    return res.status(HTTP_STATUS.OK).json({
      success: true,
      message: 'Pantry item removed successfully',
    });
  } catch (error) {
    console.error('Delete pantry item error:', error);

    if (error.message === 'Pantry item not found') {
      return res.status(HTTP_STATUS.NOT_FOUND).json({
        error: {
          statusCode: HTTP_STATUS.NOT_FOUND,
          message: ERROR_MESSAGES.NOT_FOUND,
        },
      });
    }

    return res.status(HTTP_STATUS.INTERNAL_SERVER_ERROR).json({
      error: {
        statusCode: HTTP_STATUS.INTERNAL_SERVER_ERROR,
        message: ERROR_MESSAGES.INTERNAL_ERROR,
        details: error.message,
      },
    });
  }
};
