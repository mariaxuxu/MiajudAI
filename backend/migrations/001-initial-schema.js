import { DataTypes } from 'sequelize';

export async function up({ context: sequelize }) {
  const queryInterface = sequelize.getQueryInterface();

  await queryInterface.createTable('users', {
    id: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
    firebase_uid: { type: DataTypes.STRING(255), allowNull: false, unique: true },
    email: { type: DataTypes.STRING(255), allowNull: false, unique: true },
    phone: { type: DataTypes.STRING(20), allowNull: true },
    full_name: { type: DataTypes.STRING(255), allowNull: true },
    avatar_url: { type: DataTypes.TEXT, allowNull: true },
    created_at: { type: DataTypes.DATE, defaultValue: DataTypes.NOW },
    updated_at: { type: DataTypes.DATE, defaultValue: DataTypes.NOW },
    last_activity: { type: DataTypes.DATE, allowNull: true },
  });

  await queryInterface.createTable('emergency_contacts', {
    id: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
    user_id: {
      type: DataTypes.INTEGER,
      allowNull: false,
      references: { model: 'users', key: 'id' },
      onDelete: 'CASCADE',
    },
    name: { type: DataTypes.STRING(255), allowNull: false },
    phone: { type: DataTypes.STRING(20), allowNull: false },
    is_verified: { type: DataTypes.BOOLEAN, defaultValue: false },
    verification_code: { type: DataTypes.STRING(6), allowNull: true },
    verification_code_expires_at: { type: DataTypes.DATE, allowNull: true },
    created_at: { type: DataTypes.DATE, defaultValue: DataTypes.NOW },
  });

  await queryInterface.createTable('user_context', {
    id: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
    user_id: {
      type: DataTypes.INTEGER,
      allowNull: false,
      references: { model: 'users', key: 'id' },
      onDelete: 'CASCADE',
    },
    agent_type: { type: DataTypes.STRING(50), allowNull: true },
    interests: { type: DataTypes.JSONB, allowNull: true, defaultValue: {} },
    routine_data: { type: DataTypes.JSONB, allowNull: true, defaultValue: {} },
    preferences: { type: DataTypes.JSONB, allowNull: true, defaultValue: {} },
    common_questions: {
      type: DataTypes.ARRAY(DataTypes.TEXT),
      allowNull: true,
      defaultValue: [],
    },
    last_updated: { type: DataTypes.DATE, defaultValue: DataTypes.NOW },
  });

  await queryInterface.createTable('events', {
    id: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
    user_id: {
      type: DataTypes.INTEGER,
      allowNull: false,
      references: { model: 'users', key: 'id' },
      onDelete: 'CASCADE',
    },
    title: { type: DataTypes.STRING, allowNull: false },
    event_date: { type: DataTypes.DATEONLY, allowNull: false },
    created_at: { type: DataTypes.DATE, defaultValue: DataTypes.NOW },
    updated_at: { type: DataTypes.DATE, defaultValue: DataTypes.NOW },
  });

  await queryInterface.createTable('accounts', {
    id: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
    user_id: {
      type: DataTypes.INTEGER,
      allowNull: false,
      references: { model: 'users', key: 'id' },
      onDelete: 'CASCADE',
    },
    name: { type: DataTypes.STRING(255), allowNull: false },
    type: {
      type: DataTypes.ENUM('checking', 'savings', 'credit_card', 'other'),
      allowNull: false,
      defaultValue: 'checking',
    },
    balance: { type: DataTypes.DECIMAL(10, 2), allowNull: false, defaultValue: 0 },
    bank_name: { type: DataTypes.STRING(100), allowNull: true },
    account_number: { type: DataTypes.STRING(50), allowNull: true },
    is_active: { type: DataTypes.BOOLEAN, defaultValue: true },
    created_at: { type: DataTypes.DATE, defaultValue: DataTypes.NOW },
    updated_at: { type: DataTypes.DATE, defaultValue: DataTypes.NOW },
  });

  await queryInterface.createTable('categories', {
    id: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
    user_id: {
      type: DataTypes.INTEGER,
      allowNull: true,
      references: { model: 'users', key: 'id' },
      onDelete: 'CASCADE',
    },
    name: { type: DataTypes.STRING(100), allowNull: false },
    icon: { type: DataTypes.STRING(50), allowNull: true },
    color: { type: DataTypes.STRING(7), allowNull: true },
    is_default: { type: DataTypes.BOOLEAN, defaultValue: false },
    created_at: { type: DataTypes.DATE, defaultValue: DataTypes.NOW },
  });

  await queryInterface.createTable('income', {
    id: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
    user_id: {
      type: DataTypes.INTEGER,
      allowNull: false,
      references: { model: 'users', key: 'id' },
      onDelete: 'CASCADE',
    },
    account_id: {
      type: DataTypes.INTEGER,
      allowNull: true,
      references: { model: 'accounts', key: 'id' },
      onDelete: 'SET NULL',
    },
    amount: { type: DataTypes.DECIMAL(10, 2), allowNull: false },
    description: { type: DataTypes.STRING(255), allowNull: false },
    type: {
      type: DataTypes.ENUM('salary', 'freelance', 'investment', 'gift', 'other'),
      allowNull: false,
      defaultValue: 'salary',
    },
    income_date: { type: DataTypes.DATE, allowNull: false },
    is_recurring: { type: DataTypes.BOOLEAN, defaultValue: false },
    recurrence_type: {
      type: DataTypes.ENUM('monthly', 'yearly', 'weekly'),
      allowNull: true,
    },
    created_at: { type: DataTypes.DATE, defaultValue: DataTypes.NOW },
    updated_at: { type: DataTypes.DATE, defaultValue: DataTypes.NOW },
  });

  await queryInterface.createTable('expenses', {
    id: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
    user_id: {
      type: DataTypes.INTEGER,
      allowNull: false,
      references: { model: 'users', key: 'id' },
      onDelete: 'CASCADE',
    },
    account_id: {
      type: DataTypes.INTEGER,
      allowNull: true,
      references: { model: 'accounts', key: 'id' },
      onDelete: 'SET NULL',
    },
    category_id: {
      type: DataTypes.INTEGER,
      allowNull: false,
      references: { model: 'categories', key: 'id' },
      onDelete: 'CASCADE',
    },
    amount: { type: DataTypes.DECIMAL(10, 2), allowNull: false },
    description: { type: DataTypes.STRING(255), allowNull: false },
    expense_date: { type: DataTypes.DATE, allowNull: false },
    is_recurring: { type: DataTypes.BOOLEAN, defaultValue: false },
    recurrence_type: {
      type: DataTypes.ENUM('monthly', 'yearly', 'weekly'),
      allowNull: true,
    },
    payment_method: {
      type: DataTypes.ENUM('cash', 'credit_card', 'debit_card', 'transfer', 'other'),
      defaultValue: 'cash',
    },
    status: {
      type: DataTypes.ENUM('pending', 'paid', 'overdue'),
      defaultValue: 'paid',
    },
    tags: { type: DataTypes.STRING(500), allowNull: true },
    created_at: { type: DataTypes.DATE, defaultValue: DataTypes.NOW },
    updated_at: { type: DataTypes.DATE, defaultValue: DataTypes.NOW },
  });
}

export async function down({ context: sequelize }) {
  const queryInterface = sequelize.getQueryInterface();

  await queryInterface.dropTable('expenses');
  await queryInterface.dropTable('income');
  await queryInterface.dropTable('categories');
  await queryInterface.dropTable('accounts');
  await queryInterface.dropTable('events');
  await queryInterface.dropTable('user_context');
  await queryInterface.dropTable('emergency_contacts');
  await queryInterface.dropTable('users');

  // Sequelize leaves native ENUM types orphaned after dropTable; drop them so
  // `up` can run again without a duplicate-type conflict.
  const enumTypes = [
    'enum_expenses_status',
    'enum_expenses_payment_method',
    'enum_expenses_recurrence_type',
    'enum_income_recurrence_type',
    'enum_income_type',
    'enum_accounts_type',
  ];
  for (const enumType of enumTypes) {
    await sequelize.query(`DROP TYPE IF EXISTS "${enumType}";`);
  }
}
