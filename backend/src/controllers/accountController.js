import accountService from '../services/accountService.js';
import { HTTP_STATUS, ERROR_MESSAGES } from '../utils/constants.js';

export const getAccounts = async (req, res) => {
  try {
    const userId = req.user.userId;
    const accounts = await accountService.getAccountsByUserId(userId);

    return res.status(HTTP_STATUS.OK).json({
      success: true,
      accounts: accounts.map((a) => ({
        id: a.id,
        user_id: a.user_id,
        name: a.name,
        type: a.type,
        balance: a.balance,
        bank_name: a.bank_name,
        account_number: a.account_number,
        is_active: a.is_active,
        created_at: a.created_at,
      })),
    });
  } catch (error) {
    console.error('Get accounts error:', error);
    return res.status(HTTP_STATUS.INTERNAL_SERVER_ERROR).json({
      error: {
        statusCode: HTTP_STATUS.INTERNAL_SERVER_ERROR,
        message: ERROR_MESSAGES.INTERNAL_ERROR,
      },
    });
  }
};

export const getAccountById = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { id } = req.params;

    const account = await accountService.getAccountById(parseInt(id, 10), userId);

    if (!account) {
      return res.status(HTTP_STATUS.NOT_FOUND).json({
        error: {
          statusCode: HTTP_STATUS.NOT_FOUND,
          message: ERROR_MESSAGES.NOT_FOUND,
        },
      });
    }

    return res.status(HTTP_STATUS.OK).json({
      success: true,
      account: {
        id: account.id,
        user_id: account.user_id,
        name: account.name,
        type: account.type,
        balance: account.balance,
        bank_name: account.bank_name,
        account_number: account.account_number,
        is_active: account.is_active,
        created_at: account.created_at,
      },
    });
  } catch (error) {
    console.error('Get account error:', error);
    return res.status(HTTP_STATUS.INTERNAL_SERVER_ERROR).json({
      error: {
        statusCode: HTTP_STATUS.INTERNAL_SERVER_ERROR,
        message: ERROR_MESSAGES.INTERNAL_ERROR,
      },
    });
  }
};

export const createAccount = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { name, type, bank_name, account_number } = req.body;

    if (!name || !type) {
      return res.status(HTTP_STATUS.BAD_REQUEST).json({
        error: {
          statusCode: HTTP_STATUS.BAD_REQUEST,
          message: 'Missing required fields: name, type',
        },
      });
    }

    const account = await accountService.createAccount(
      userId,
      name,
      type,
      bank_name,
      account_number
    );

    return res.status(HTTP_STATUS.OK).json({
      success: true,
      account: {
        id: account.id,
        user_id: account.user_id,
        name: account.name,
        type: account.type,
        balance: account.balance,
        bank_name: account.bank_name,
        account_number: account.account_number,
        is_active: account.is_active,
        created_at: account.created_at,
      },
    });
  } catch (error) {
    console.error('Create account error:', error);
    return res.status(HTTP_STATUS.INTERNAL_SERVER_ERROR).json({
      error: {
        statusCode: HTTP_STATUS.INTERNAL_SERVER_ERROR,
        message: ERROR_MESSAGES.INTERNAL_ERROR,
        details: error.message,
      },
    });
  }
};

export const updateAccount = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { id } = req.params;
    const updateData = req.body;

    const account = await accountService.updateAccount(
      parseInt(id, 10),
      userId,
      updateData
    );

    return res.status(HTTP_STATUS.OK).json({
      success: true,
      account: {
        id: account.id,
        user_id: account.user_id,
        name: account.name,
        type: account.type,
        balance: account.balance,
        bank_name: account.bank_name,
        account_number: account.account_number,
        is_active: account.is_active,
        created_at: account.created_at,
      },
    });
  } catch (error) {
    console.error('Update account error:', error);

    if (error.message === 'Account not found') {
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

export const deleteAccount = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { id } = req.params;

    await accountService.deleteAccount(parseInt(id, 10), userId);

    return res.status(HTTP_STATUS.OK).json({
      success: true,
      message: 'Account deleted successfully',
    });
  } catch (error) {
    console.error('Delete account error:', error);

    if (error.message === 'Account not found') {
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
