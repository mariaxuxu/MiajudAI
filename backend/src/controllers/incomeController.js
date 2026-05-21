import incomeService from '../services/incomeService.js';
import { HTTP_STATUS, ERROR_MESSAGES } from '../utils/constants.js';

export const getIncome = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { month, year } = req.query;

    let income;

    if (month && year) {
      income = await incomeService.getIncomeByMonth(userId, parseInt(year), parseInt(month));
    } else {
      income = await incomeService.getIncomeByUserId(userId);
    }

    return res.status(HTTP_STATUS.OK).json({
      success: true,
      income: income.map((i) => ({
        id: i.id,
        user_id: i.user_id,
        account_id: i.account_id,
        amount: i.amount,
        description: i.description,
        type: i.type,
        income_date: i.income_date,
        is_recurring: i.is_recurring,
        recurrence_type: i.recurrence_type,
        created_at: i.created_at,
      })),
    });
  } catch (error) {
    console.error('Get income error:', error);
    return res.status(HTTP_STATUS.INTERNAL_SERVER_ERROR).json({
      error: {
        statusCode: HTTP_STATUS.INTERNAL_SERVER_ERROR,
        message: ERROR_MESSAGES.INTERNAL_ERROR,
      },
    });
  }
};

export const getIncomeById = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { id } = req.params;

    const income = await incomeService.getIncomeById(parseInt(id, 10), userId);

    if (!income) {
      return res.status(HTTP_STATUS.NOT_FOUND).json({
        error: {
          statusCode: HTTP_STATUS.NOT_FOUND,
          message: ERROR_MESSAGES.NOT_FOUND,
        },
      });
    }

    return res.status(HTTP_STATUS.OK).json({
      success: true,
      income: {
        id: income.id,
        user_id: income.user_id,
        account_id: income.account_id,
        amount: income.amount,
        description: income.description,
        type: income.type,
        income_date: income.income_date,
        is_recurring: income.is_recurring,
        recurrence_type: income.recurrence_type,
        created_at: income.created_at,
      },
    });
  } catch (error) {
    console.error('Get income error:', error);
    return res.status(HTTP_STATUS.INTERNAL_SERVER_ERROR).json({
      error: {
        statusCode: HTTP_STATUS.INTERNAL_SERVER_ERROR,
        message: ERROR_MESSAGES.INTERNAL_ERROR,
      },
    });
  }
};

export const createIncome = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { amount, description, type, income_date, account_id, is_recurring, recurrence_type } =
      req.body;

    if (!amount || !description || !income_date) {
      return res.status(HTTP_STATUS.BAD_REQUEST).json({
        error: {
          statusCode: HTTP_STATUS.BAD_REQUEST,
          message: 'Missing required fields: amount, description, income_date',
        },
      });
    }

    const income = await incomeService.createIncome(
      userId,
      amount,
      description,
      type || 'salary',
      income_date,
      account_id,
      is_recurring,
      recurrence_type
    );

    return res.status(HTTP_STATUS.OK).json({
      success: true,
      income: {
        id: income.id,
        user_id: income.user_id,
        account_id: income.account_id,
        amount: income.amount,
        description: income.description,
        type: income.type,
        income_date: income.income_date,
        is_recurring: income.is_recurring,
        recurrence_type: income.recurrence_type,
        created_at: income.created_at,
      },
    });
  } catch (error) {
    console.error('Create income error:', error);
    return res.status(HTTP_STATUS.INTERNAL_SERVER_ERROR).json({
      error: {
        statusCode: HTTP_STATUS.INTERNAL_SERVER_ERROR,
        message: ERROR_MESSAGES.INTERNAL_ERROR,
        details: error.message,
      },
    });
  }
};

export const updateIncome = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { id } = req.params;
    const updateData = req.body;

    const income = await incomeService.updateIncome(parseInt(id, 10), userId, updateData);

    return res.status(HTTP_STATUS.OK).json({
      success: true,
      income: {
        id: income.id,
        user_id: income.user_id,
        account_id: income.account_id,
        amount: income.amount,
        description: income.description,
        type: income.type,
        income_date: income.income_date,
        is_recurring: income.is_recurring,
        recurrence_type: income.recurrence_type,
        created_at: income.created_at,
      },
    });
  } catch (error) {
    console.error('Update income error:', error);

    if (error.message === 'Income not found') {
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

export const deleteIncome = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { id } = req.params;

    await incomeService.deleteIncome(parseInt(id, 10), userId);

    return res.status(HTTP_STATUS.OK).json({
      success: true,
      message: 'Income deleted successfully',
    });
  } catch (error) {
    console.error('Delete income error:', error);

    if (error.message === 'Income not found') {
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

export const getMonthlyTotal = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { month, year } = req.query;

    if (!month || !year) {
      return res.status(HTTP_STATUS.BAD_REQUEST).json({
        error: {
          statusCode: HTTP_STATUS.BAD_REQUEST,
          message: 'Missing required query params: month, year',
        },
      });
    }

    const total = await incomeService.getTotalIncomeByMonth(
      userId,
      parseInt(year),
      parseInt(month)
    );

    return res.status(HTTP_STATUS.OK).json({
      success: true,
      total,
      month: parseInt(month),
      year: parseInt(year),
    });
  } catch (error) {
    console.error('Get monthly total error:', error);
    return res.status(HTTP_STATUS.INTERNAL_SERVER_ERROR).json({
      error: {
        statusCode: HTTP_STATUS.INTERNAL_SERVER_ERROR,
        message: ERROR_MESSAGES.INTERNAL_ERROR,
      },
    });
  }
};
