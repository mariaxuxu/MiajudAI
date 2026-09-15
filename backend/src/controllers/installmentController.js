import installmentService from '../services/installmentService.js';
import { HTTP_STATUS, ERROR_MESSAGES } from '../utils/constants.js';

export const getInstallments = async (req, res) => {
  try {
    const userId = req.user.userId;
    const installments = await installmentService.getInstallmentsByUserId(userId);
    return res.status(HTTP_STATUS.OK).json({ success: true, installments });
  } catch (error) {
    console.error('Get installments error:', error);
    return res.status(HTTP_STATUS.INTERNAL_SERVER_ERROR).json({
      error: { statusCode: HTTP_STATUS.INTERNAL_SERVER_ERROR, message: ERROR_MESSAGES.INTERNAL_ERROR },
    });
  }
};

export const getInstallmentById = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { id } = req.params;
    const installment = await installmentService.getInstallmentById(id, userId);

    if (!installment) {
      return res.status(HTTP_STATUS.NOT_FOUND).json({
        error: { statusCode: HTTP_STATUS.NOT_FOUND, message: ERROR_MESSAGES.NOT_FOUND },
      });
    }

    return res.status(HTTP_STATUS.OK).json({ success: true, installment });
  } catch (error) {
    console.error('Get installment error:', error);
    return res.status(HTTP_STATUS.INTERNAL_SERVER_ERROR).json({
      error: { statusCode: HTTP_STATUS.INTERNAL_SERVER_ERROR, message: ERROR_MESSAGES.INTERNAL_ERROR },
    });
  }
};

export const createInstallment = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { name, total_amount, total_installments, due_day_of_month, start_date, description } = req.body;

    if (!name || !total_amount || !total_installments || !due_day_of_month || !start_date) {
      return res.status(HTTP_STATUS.BAD_REQUEST).json({
        error: { statusCode: HTTP_STATUS.BAD_REQUEST, message: 'Missing required fields: name, total_amount, total_installments, due_day_of_month, start_date' },
      });
    }

    const installment = await installmentService.createInstallment(userId, {
      name,
      total_amount,
      total_installments,
      due_day_of_month,
      start_date,
      description,
    });

    return res.status(HTTP_STATUS.CREATED).json({ success: true, installment });
  } catch (error) {
    console.error('Create installment error:', error);
    return res.status(HTTP_STATUS.INTERNAL_SERVER_ERROR).json({
      error: { statusCode: HTTP_STATUS.INTERNAL_SERVER_ERROR, message: ERROR_MESSAGES.INTERNAL_ERROR, details: error.message },
    });
  }
};

export const updateInstallment = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { id } = req.params;
    const installment = await installmentService.updateInstallment(id, userId, req.body);

    return res.status(HTTP_STATUS.OK).json({ success: true, installment });
  } catch (error) {
    console.error('Update installment error:', error);
    const statusCode = error.message.includes('not found') ? HTTP_STATUS.NOT_FOUND : HTTP_STATUS.INTERNAL_SERVER_ERROR;
    return res.status(statusCode).json({
      error: { statusCode, message: error.message },
    });
  }
};

export const deleteInstallment = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { id } = req.params;
    await installmentService.deleteInstallment(id, userId);

    return res.status(HTTP_STATUS.OK).json({ success: true, message: 'Installment deleted' });
  } catch (error) {
    console.error('Delete installment error:', error);
    const statusCode = error.message.includes('not found') ? HTTP_STATUS.NOT_FOUND : HTTP_STATUS.INTERNAL_SERVER_ERROR;
    return res.status(statusCode).json({
      error: { statusCode, message: error.message },
    });
  }
};

export const getMonthlyTotal = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { month, year } = req.query;
    const currentDate = new Date();
    const queryMonth = month ? parseInt(month) : currentDate.getMonth() + 1;
    const queryYear = year ? parseInt(year) : currentDate.getFullYear();

    const total = await installmentService.getTotalForMonth(userId, queryMonth, queryYear);
    return res.status(HTTP_STATUS.OK).json({ success: true, month: queryMonth, year: queryYear, total });
  } catch (error) {
    console.error('Get monthly total error:', error);
    return res.status(HTTP_STATUS.INTERNAL_SERVER_ERROR).json({
      error: { statusCode: HTTP_STATUS.INTERNAL_SERVER_ERROR, message: ERROR_MESSAGES.INTERNAL_ERROR },
    });
  }
};
