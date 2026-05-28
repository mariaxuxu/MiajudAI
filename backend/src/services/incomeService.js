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
  const { Income, Account, sequelize } = getDatabase();

  // Usar transaction para garantir atomicidade
  return await retryWithDelay(async () => {
    const transaction = await sequelize.transaction();

    try {
      // 1. Criar income dentro da transação
      const income = await Income.create(
        {
          user_id: userId,
          amount,
          description,
          type,
          income_date: incomeDate,
          account_id: accountId,
          is_recurring: isRecurring || false,
          recurrence_type: recurrenceType,
        },
        { transaction }
      );

      // 2. Se tem account_id, atualizar balance (adicionar)
      if (accountId) {
        const account = await Account.findOne(
          { where: { id: accountId, user_id: userId } },
          { transaction }
        );

        if (!account) {
          throw new Error('Account not found or not accessible');
        }

        // Incrementar balance (receita aumenta saldo)
        await account.increment('balance', {
          by: amount,
          transaction,
        });

        console.log(`✅ Income created. Account ${accountId} balance updated (increased by ${amount})`);
      }

      // Commit da transação
      await transaction.commit();
      return income;
    } catch (error) {
      // Rollback em caso de erro
      await transaction.rollback();
      console.error('❌ Transaction failed, rolled back:', error.message);
      throw error;
    }
  });
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
  const { Income, Account, sequelize } = getDatabase();

  return await retryWithDelay(async () => {
    const transaction = await sequelize.transaction();

    try {
      const income = await Income.findOne(
        { where: { id: incomeId, user_id: userId } },
        { transaction }
      );

      if (!income) {
        throw new Error('Income not found');
      }

      const accountId = income.account_id;
      const amount = income.amount;

      // Deletar income
      await income.destroy({ transaction });

      // Se tem account_id, remover o saldo (deletar receita = reduzir saldo)
      if (accountId) {
        const account = await Account.findOne(
          { where: { id: accountId, user_id: userId } },
          { transaction }
        );

        if (!account) {
          throw new Error('Account not found or not accessible');
        }

        // Decrementar balance (deletar receita reduz o saldo)
        await account.decrement('balance', {
          by: amount,
          transaction,
        });

        console.log(`✅ Income deleted. Account ${accountId} balance updated (decreased by ${amount})`);
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
