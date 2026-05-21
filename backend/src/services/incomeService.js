import { getDatabase } from '../config/database.js';

const getIncomeByUserId = async (userId) => {
  const { Income } = getDatabase();
  const income = await Income.findAll({
    where: { user_id: userId },
    order: [['income_date', 'DESC']],
  });
  return income;
};

const getIncomeById = async (incomeId, userId) => {
  const { Income } = getDatabase();
  const income = await Income.findOne({
    where: { id: incomeId, user_id: userId },
  });
  return income;
};

const getIncomeByMonth = async (userId, year, month) => {
  const { Income } = getDatabase();
  const startDate = new Date(year, month - 1, 1);
  const endDate = new Date(year, month, 0);

  const income = await Income.findAll({
    where: {
      user_id: userId,
      income_date: {
        [Income.sequelize.Sequelize.Op.between]: [startDate, endDate],
      },
    },
    order: [['income_date', 'DESC']],
  });
  return income;
};

const createIncome = async (
  userId,
  amount,
  description,
  type,
  incomeDate,
  accountId,
  isRecurring,
  recurrenceType
) => {
  const { Income } = getDatabase();
  const income = await Income.create({
    user_id: userId,
    amount,
    description,
    type,
    income_date: incomeDate,
    account_id: accountId,
    is_recurring: isRecurring || false,
    recurrence_type: recurrenceType,
  });
  return income;
};

const updateIncome = async (incomeId, userId, updateData) => {
  const { Income } = getDatabase();
  const income = await Income.findOne({
    where: { id: incomeId, user_id: userId },
  });

  if (!income) {
    throw new Error('Income not found');
  }

  if (updateData.amount !== undefined) income.amount = updateData.amount;
  if (updateData.description !== undefined) income.description = updateData.description;
  if (updateData.type !== undefined) income.type = updateData.type;
  if (updateData.income_date !== undefined) income.income_date = updateData.income_date;
  if (updateData.account_id !== undefined) income.account_id = updateData.account_id;
  if (updateData.is_recurring !== undefined) income.is_recurring = updateData.is_recurring;
  if (updateData.recurrence_type !== undefined) income.recurrence_type = updateData.recurrence_type;

  await income.save();
  return income;
};

const deleteIncome = async (incomeId, userId) => {
  const { Income } = getDatabase();
  const income = await Income.findOne({
    where: { id: incomeId, user_id: userId },
  });

  if (!income) {
    throw new Error('Income not found');
  }

  await income.destroy();
  return true;
};

const getTotalIncomeByMonth = async (userId, year, month) => {
  const { Income } = getDatabase();
  const startDate = new Date(year, month - 1, 1);
  const endDate = new Date(year, month, 0);

  const result = await Income.findOne({
    attributes: [
      [Income.sequelize.Sequelize.fn('SUM', Income.sequelize.Sequelize.col('amount')), 'total'],
    ],
    where: {
      user_id: userId,
      income_date: {
        [Income.sequelize.Sequelize.Op.between]: [startDate, endDate],
      },
    },
    raw: true,
  });

  return parseFloat(result.total) || 0;
};

export default {
  getIncomeByUserId,
  getIncomeById,
  getIncomeByMonth,
  createIncome,
  updateIncome,
  deleteIncome,
  getTotalIncomeByMonth,
};
