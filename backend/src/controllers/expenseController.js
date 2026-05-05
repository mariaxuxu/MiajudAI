import expenseService from '../services/expenseService.js';
import { HTTP_STATUS, ERROR_MESSAGES } from '../utils/constants.js';

export const getExpenses = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { month, year, categoryId } = req.query;

    let expenses;

    if (categoryId && month && year) {
      expenses = await expenseService.getExpensesByCategory(
        userId,
        parseInt(categoryId),
        parseInt(year),
        parseInt(month)
      );
    } else if (month && year) {
      expenses = await expenseService.getExpensesByMonth(userId, parseInt(year), parseInt(month));
    } else {
      expenses = await expenseService.getExpensesByUserId(userId);
    }

    return res.status(HTTP_STATUS.OK).json({
      success: true,
      expenses: expenses.map((e) => ({
        id: e.id,
        user_id: e.user_id,
        account_id: e.account_id,
        category_id: e.category_id,
        amount: e.amount,
        description: e.description,
        expense_date: e.expense_date,
        is_recurring: e.is_recurring,
        recurrence_type: e.recurrence_type,
        payment_method: e.payment_method,
        status: e.status,
        tags: e.tags,
        created_at: e.created_at,
      })),
    });
  } catch (error) {
    console.error('Get expenses error:', error);
    return res.status(HTTP_STATUS.INTERNAL_SERVER_ERROR).json({
      error: {
        statusCode: HTTP_STATUS.INTERNAL_SERVER_ERROR,
        message: ERROR_MESSAGES.INTERNAL_ERROR,
      },
    });
  }
};

export const getExpenseById = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { id } = req.params;

    const expense = await expenseService.getExpenseById(parseInt(id, 10), userId);

    if (!expense) {
      return res.status(HTTP_STATUS.NOT_FOUND).json({
        error: {
          statusCode: HTTP_STATUS.NOT_FOUND,
          message: ERROR_MESSAGES.NOT_FOUND,
        },
      });
    }

    return res.status(HTTP_STATUS.OK).json({
      success: true,
      expense: {
        id: expense.id,
        user_id: expense.user_id,
        account_id: expense.account_id,
        category_id: expense.category_id,
        amount: expense.amount,
        description: expense.description,
        expense_date: expense.expense_date,
        is_recurring: expense.is_recurring,
        recurrence_type: expense.recurrence_type,
        payment_method: expense.payment_method,
        status: expense.status,
        tags: expense.tags,
        created_at: expense.created_at,
      },
    });
  } catch (error) {
    console.error('Get expense error:', error);
    return res.status(HTTP_STATUS.INTERNAL_SERVER_ERROR).json({
      error: {
        statusCode: HTTP_STATUS.INTERNAL_SERVER_ERROR,
        message: ERROR_MESSAGES.INTERNAL_ERROR,
      },
    });
  }
};

export const createExpense = async (req, res) => {
  try {
    const userId = req.user.userId;
    const {
      category_id,
      amount,
      description,
      expense_date,
      account_id,
      is_recurring,
      recurrence_type,
      payment_method,
      status,
      tags,
    } = req.body;

    if (!category_id || !amount || !description || !expense_date) {
      return res.status(HTTP_STATUS.BAD_REQUEST).json({
        error: {
          statusCode: HTTP_STATUS.BAD_REQUEST,
          message: 'Missing required fields: category_id, amount, description, expense_date',
        },
      });
    }

    const expense = await expenseService.createExpense(
      userId,
      parseInt(category_id),
      amount,
      description,
      expense_date,
      account_id,
      is_recurring,
      recurrence_type,
      payment_method,
      status,
      tags
    );

    return res.status(HTTP_STATUS.OK).json({
      success: true,
      expense: {
        id: expense.id,
        user_id: expense.user_id,
        account_id: expense.account_id,
        category_id: expense.category_id,
        amount: expense.amount,
        description: expense.description,
        expense_date: expense.expense_date,
        is_recurring: expense.is_recurring,
        recurrence_type: expense.recurrence_type,
        payment_method: expense.payment_method,
        status: expense.status,
        tags: expense.tags,
        created_at: expense.created_at,
      },
    });
  } catch (error) {
    console.error('Create expense error:', error);
    return res.status(HTTP_STATUS.INTERNAL_SERVER_ERROR).json({
      error: {
        statusCode: HTTP_STATUS.INTERNAL_SERVER_ERROR,
        message: ERROR_MESSAGES.INTERNAL_ERROR,
        details: error.message,
      },
    });
  }
};

export const updateExpense = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { id } = req.params;
    const updateData = req.body;

    const expense = await expenseService.updateExpense(parseInt(id, 10), userId, updateData);

    return res.status(HTTP_STATUS.OK).json({
      success: true,
      expense: {
        id: expense.id,
        user_id: expense.user_id,
        account_id: expense.account_id,
        category_id: expense.category_id,
        amount: expense.amount,
        description: expense.description,
        expense_date: expense.expense_date,
        is_recurring: expense.is_recurring,
        recurrence_type: expense.recurrence_type,
        payment_method: expense.payment_method,
        status: expense.status,
        tags: expense.tags,
        created_at: expense.created_at,
      },
    });
  } catch (error) {
    console.error('Update expense error:', error);

    if (error.message === 'Expense not found') {
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

export const deleteExpense = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { id } = req.params;

    await expenseService.deleteExpense(parseInt(id, 10), userId);

    return res.status(HTTP_STATUS.OK).json({
      success: true,
      message: 'Expense deleted successfully',
    });
  } catch (error) {
    console.error('Delete expense error:', error);

    if (error.message === 'Expense not found') {
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
    const { month, year, categoryId } = req.query;

    if (!month || !year) {
      return res.status(HTTP_STATUS.BAD_REQUEST).json({
        error: {
          statusCode: HTTP_STATUS.BAD_REQUEST,
          message: 'Missing required query params: month, year',
        },
      });
    }

    let total;
    if (categoryId) {
      total = await expenseService.getTotalExpenseByCategoryMonth(
        userId,
        parseInt(categoryId),
        parseInt(year),
        parseInt(month)
      );
    } else {
      total = await expenseService.getTotalExpenseByMonth(
        userId,
        parseInt(year),
        parseInt(month)
      );
    }

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
