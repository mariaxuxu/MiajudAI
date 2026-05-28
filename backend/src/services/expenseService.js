import { getDatabase } from '../config/database.js';

// Helper: Retry com delay
const retryWithDelay = async (fn, maxRetries = 2, delayMs = 150) => {
  let lastError;
  for (let attempt = 1; attempt <= maxRetries; attempt++) {
    try {
      return await fn();
    } catch (error) {
      lastError = error;
      if (attempt < maxRetries) {
        console.log(`Retry attempt ${attempt}/${maxRetries} after ${delayMs}ms...`);
        await new Promise((resolve) => setTimeout(resolve, delayMs));
      }
    }
  }
  throw lastError;
};

const getExpensesByUserId = async (userId) => {
  const { Expense } = getDatabase();
  const expenses = await Expense.findAll({
    where: { user_id: userId },
    order: [['expense_date', 'DESC']],
  });
  return expenses;
};

const getExpenseById = async (expenseId, userId) => {
  const { Expense } = getDatabase();
  const expense = await Expense.findOne({
    where: { id: expenseId, user_id: userId },
  });
  return expense;
};

const getExpensesByMonth = async (userId, year, month) => {
  const { Expense } = getDatabase();
  const startDate = new Date(year, month - 1, 1);
  const endDate = new Date(year, month, 0);

  const expenses = await Expense.findAll({
    where: {
      user_id: userId,
      expense_date: {
        [Expense.sequelize.Sequelize.Op.between]: [startDate, endDate],
      },
    },
    order: [['expense_date', 'DESC']],
  });
  return expenses;
};

const getExpensesByCategory = async (userId, categoryId, year, month) => {
  const { Expense } = getDatabase();
  const startDate = new Date(year, month - 1, 1);
  const endDate = new Date(year, month, 0);

  const expenses = await Expense.findAll({
    where: {
      user_id: userId,
      category_id: categoryId,
      expense_date: {
        [Expense.sequelize.Sequelize.Op.between]: [startDate, endDate],
      },
    },
    order: [['expense_date', 'DESC']],
  });
  return expenses;
};

const createExpense = async (
  userId,
  categoryId,
  amount,
  description,
  expenseDate,
  accountId,
  isRecurring,
  recurrenceType,
  paymentMethod,
  status,
  tags
) => {
  const { Expense, Account, Category, sequelize } = getDatabase();

  // Usar transaction para garantir atomicidade
  return await retryWithDelay(async () => {
    const transaction = await sequelize.transaction();

    try {
      // 0. Validar categoria ANTES de criar expense
      const category = await Category.findOne(
        { where: { id: categoryId } },
        { transaction }
      );

      if (!category) {
        throw new Error('Category not found or not accessible');
      }

      // 1. Criar expense dentro da transação
      const expense = await Expense.create(
        {
          user_id: userId,
          category_id: categoryId,
          amount,
          description,
          expense_date: expenseDate,
          account_id: accountId,
          is_recurring: isRecurring || false,
          recurrence_type: recurrenceType,
          payment_method: paymentMethod || 'cash',
          status: status || 'paid',
          tags: tags,
        },
        { transaction }
      );

      // 2. Se tem account_id, atualizar balance (subtrair)
      if (accountId) {
        const account = await Account.findOne(
          { where: { id: accountId, user_id: userId } },
          { transaction }
        );

        if (!account) {
          throw new Error('Account not found or not accessible');
        }

        // Decrementar balance (despesa reduz saldo)
        await account.decrement('balance', {
          by: amount,
          transaction,
        });

        console.log(`✅ Expense created. Account ${accountId} balance updated (decreased by ${amount})`);
      }

      // Commit da transação
      await transaction.commit();
      return expense;
    } catch (error) {
      // Rollback em caso de erro
      await transaction.rollback();
      console.error('❌ Transaction failed, rolled back:', error.message);
      throw error;
    }
  });
};

const updateExpense = async (expenseId, userId, updateData) => {
  const { Expense, Category } = getDatabase();
  const expense = await Expense.findOne({
    where: { id: expenseId, user_id: userId },
  });

  if (!expense) {
    throw new Error('Expense not found');
  }

  // Validar categoria se está sendo atualizada
  if (updateData.category_id !== undefined) {
    const category = await Category.findOne({
      where: { id: updateData.category_id },
    });
    if (!category) {
      throw new Error('Category not found or not accessible');
    }
    expense.category_id = updateData.category_id;
  }
  if (updateData.amount !== undefined) expense.amount = updateData.amount;
  if (updateData.description !== undefined) expense.description = updateData.description;
  if (updateData.expense_date !== undefined) expense.expense_date = updateData.expense_date;
  if (updateData.account_id !== undefined) expense.account_id = updateData.account_id;
  if (updateData.is_recurring !== undefined) expense.is_recurring = updateData.is_recurring;
  if (updateData.recurrence_type !== undefined) expense.recurrence_type = updateData.recurrence_type;
  if (updateData.payment_method !== undefined) expense.payment_method = updateData.payment_method;
  if (updateData.status !== undefined) expense.status = updateData.status;
  if (updateData.tags !== undefined) expense.tags = updateData.tags;

  await expense.save();
  return expense;
};

const deleteExpense = async (expenseId, userId) => {
  const { Expense, Account, sequelize } = getDatabase();

  return await retryWithDelay(async () => {
    const transaction = await sequelize.transaction();

    try {
      const expense = await Expense.findOne(
        { where: { id: expenseId, user_id: userId } },
        { transaction }
      );

      if (!expense) {
        throw new Error('Expense not found');
      }

      const accountId = expense.account_id;
      const amount = expense.amount;

      // Deletar expense
      await expense.destroy({ transaction });

      // Se tem account_id, devolver o saldo (deletar despesa = aumentar saldo)
      if (accountId) {
        const account = await Account.findOne(
          { where: { id: accountId, user_id: userId } },
          { transaction }
        );

        if (!account) {
          throw new Error('Account not found or not accessible');
        }

        // Incrementar balance (deletar despesa devolve o dinheiro)
        await account.increment('balance', {
          by: amount,
          transaction,
        });

        console.log(`✅ Expense deleted. Account ${accountId} balance updated (increased by ${amount})`);
      }

      await transaction.commit();
      return true;
    } catch (error) {
      await transaction.rollback();
      console.error('❌ Delete transaction failed, rolled back:', error.message);
      throw error;
    }
  });
};

const getTotalExpenseByMonth = async (userId, year, month) => {
  const { Expense } = getDatabase();
  const startDate = new Date(year, month - 1, 1);
  const endDate = new Date(year, month, 0);

  const result = await Expense.findOne({
    attributes: [
      [Expense.sequelize.Sequelize.fn('SUM', Expense.sequelize.Sequelize.col('amount')), 'total'],
    ],
    where: {
      user_id: userId,
      expense_date: {
        [Expense.sequelize.Sequelize.Op.between]: [startDate, endDate],
      },
    },
    raw: true,
  });

  return parseFloat(result.total) || 0;
};

const getTotalExpenseByCategoryMonth = async (userId, categoryId, year, month) => {
  const { Expense } = getDatabase();
  const startDate = new Date(year, month - 1, 1);
  const endDate = new Date(year, month, 0);

  const result = await Expense.findOne({
    attributes: [
      [Expense.sequelize.Sequelize.fn('SUM', Expense.sequelize.Sequelize.col('amount')), 'total'],
    ],
    where: {
      user_id: userId,
      category_id: categoryId,
      expense_date: {
        [Expense.sequelize.Sequelize.Op.between]: [startDate, endDate],
      },
    },
    raw: true,
  });

  return parseFloat(result.total) || 0;
};

export default {
  getExpensesByUserId,
  getExpenseById,
  getExpensesByMonth,
  getExpensesByCategory,
  createExpense,
  updateExpense,
  deleteExpense,
  getTotalExpenseByMonth,
  getTotalExpenseByCategoryMonth,
};
