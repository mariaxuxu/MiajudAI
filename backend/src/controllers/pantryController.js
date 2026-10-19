import pantryService from '../services/pantryService.js';
import { HTTP_STATUS, ERROR_MESSAGES } from '../utils/constants.js';

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
