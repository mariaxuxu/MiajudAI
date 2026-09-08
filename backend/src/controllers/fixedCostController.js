import fixedCostService from '../services/fixedCostService.js';
import { HTTP_STATUS, ERROR_MESSAGES } from '../utils/constants.js';

export const getFixedCosts = async (req, res) => {
  try {
    const userId = req.user.userId;
    const fixedCosts = await fixedCostService.getFixedCostsByUserId(userId);
    return res.status(HTTP_STATUS.OK).json({ success: true, fixedCosts });
  } catch (error) {
    console.error('Get fixed costs error:', error);
    return res.status(HTTP_STATUS.INTERNAL_SERVER_ERROR).json({
      error: { statusCode: HTTP_STATUS.INTERNAL_SERVER_ERROR, message: ERROR_MESSAGES.INTERNAL_ERROR },
    });
  }
};

export const getFixedCostById = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { id } = req.params;
    const fixedCost = await fixedCostService.getFixedCostById(id, userId);

    if (!fixedCost) {
      return res.status(HTTP_STATUS.NOT_FOUND).json({
        error: { statusCode: HTTP_STATUS.NOT_FOUND, message: ERROR_MESSAGES.NOT_FOUND },
      });
    }

    return res.status(HTTP_STATUS.OK).json({ success: true, fixedCost });
  } catch (error) {
    console.error('Get fixed cost error:', error);
    return res.status(HTTP_STATUS.INTERNAL_SERVER_ERROR).json({
      error: { statusCode: HTTP_STATUS.INTERNAL_SERVER_ERROR, message: ERROR_MESSAGES.INTERNAL_ERROR },
    });
  }
};

export const createFixedCost = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { name, amount, due_day_of_month, category, description } = req.body;

    if (!name || !amount || !due_day_of_month) {
      return res.status(HTTP_STATUS.BAD_REQUEST).json({
        error: { statusCode: HTTP_STATUS.BAD_REQUEST, message: 'Missing required fields: name, amount, due_day_of_month' },
      });
    }

    const fixedCost = await fixedCostService.createFixedCost(userId, {
      name,
      amount,
      due_day_of_month,
      category,
      description,
    });

    return res.status(HTTP_STATUS.CREATED).json({ success: true, fixedCost });
  } catch (error) {
    console.error('Create fixed cost error:', error);
    return res.status(HTTP_STATUS.INTERNAL_SERVER_ERROR).json({
      error: { statusCode: HTTP_STATUS.INTERNAL_SERVER_ERROR, message: ERROR_MESSAGES.INTERNAL_ERROR, details: error.message },
    });
  }
};

export const updateFixedCost = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { id } = req.params;
    const fixedCost = await fixedCostService.updateFixedCost(id, userId, req.body);

    return res.status(HTTP_STATUS.OK).json({ success: true, fixedCost });
  } catch (error) {
    console.error('Update fixed cost error:', error);
    const statusCode = error.message.includes('not found') ? HTTP_STATUS.NOT_FOUND : HTTP_STATUS.INTERNAL_SERVER_ERROR;
    return res.status(statusCode).json({
      error: { statusCode, message: error.message },
    });
  }
};

export const deleteFixedCost = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { id } = req.params;
    await fixedCostService.deleteFixedCost(id, userId);

    return res.status(HTTP_STATUS.OK).json({ success: true, message: 'Fixed cost deleted' });
  } catch (error) {
    console.error('Delete fixed cost error:', error);
    const statusCode = error.message.includes('not found') ? HTTP_STATUS.NOT_FOUND : HTTP_STATUS.INTERNAL_SERVER_ERROR;
    return res.status(statusCode).json({
      error: { statusCode, message: error.message },
    });
  }
};

export const getMonthlyTotal = async (req, res) => {
  try {
    const userId = req.user.userId;
    const total = await fixedCostService.getTotalForMonth(userId);
    return res.status(HTTP_STATUS.OK).json({ success: true, total });
  } catch (error) {
    console.error('Get monthly total error:', error);
    return res.status(HTTP_STATUS.INTERNAL_SERVER_ERROR).json({
      error: { statusCode: HTTP_STATUS.INTERNAL_SERVER_ERROR, message: ERROR_MESSAGES.INTERNAL_ERROR },
    });
  }
};
