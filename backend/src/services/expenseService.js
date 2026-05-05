import { getDatabase } from '../config/database.js';

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
  const { Expense } = getDatabase();
  const expense = await Expense.create({
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
  });
  return expense;
};

const updateExpense = async (expenseId, userId, updateData) => {
  const { Expense } = getDatabase();
  const expense = await Expense.findOne({
    where: { id: expenseId, user_id: userId },
  });

  if (!expense) {
    throw new Error('Expense not found');
  }

  if (updateData.category_id !== undefined) expense.category_id = updateData.category_id;
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
  const { Expense } = getDatabase();
  const expense = await Expense.findOne({
    where: { id: expenseId, user_id: userId },
  });

  if (!expense) {
    throw new Error('Expense not found');
  }

  await expense.destroy();
  return true;
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
