import { getDatabase } from '../config/database.js';

const getAccountsByUserId = async (userId) => {
  const { Account } = getDatabase();
  const accounts = await Account.findAll({
    where: { user_id: userId },
    order: [['created_at', 'DESC']],
  });
  return accounts;
};

const getAccountById = async (accountId, userId) => {
  const { Account } = getDatabase();
  const account = await Account.findOne({
    where: { id: accountId, user_id: userId },
  });
  return account;
};

const createAccount = async (userId, name, type, bankName, accountNumber) => {
  const { Account } = getDatabase();
  const account = await Account.create({
    user_id: userId,
    name,
    type,
    bank_name: bankName,
    account_number: accountNumber,
    balance: 0,
    is_active: true,
  });
  return account;
};

const updateAccount = async (accountId, userId, updateData) => {
  const { Account } = getDatabase();
  const account = await Account.findOne({
    where: { id: accountId, user_id: userId },
  });

  if (!account) {
    throw new Error('Account not found');
  }

  if (updateData.name !== undefined) account.name = updateData.name;
  if (updateData.type !== undefined) account.type = updateData.type;
  if (updateData.bank_name !== undefined) account.bank_name = updateData.bank_name;
  if (updateData.account_number !== undefined) account.account_number = updateData.account_number;
  if (updateData.balance !== undefined) account.balance = updateData.balance;
  if (updateData.is_active !== undefined) account.is_active = updateData.is_active;

  await account.save();
  return account;
};

const updateBalance = async (accountId, userId, amount) => {
  const { Account } = getDatabase();
  const account = await Account.findOne({
    where: { id: accountId, user_id: userId },
  });

  if (!account) {
    throw new Error('Account not found');
  }

  account.balance = parseFloat(account.balance) + parseFloat(amount);
  await account.save();
  return account;
};

const deleteAccount = async (accountId, userId) => {
  const { Account } = getDatabase();
  const account = await Account.findOne({
    where: { id: accountId, user_id: userId },
  });

  if (!account) {
    throw new Error('Account not found');
  }

  await account.destroy();
  return true;
};

export default {
  getAccountsByUserId,
  getAccountById,
  createAccount,
  updateAccount,
  updateBalance,
  deleteAccount,
};
