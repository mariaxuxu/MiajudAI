import { Sequelize } from 'sequelize';
import config from './env.js';
import { defineUserModel } from '../models/User.js';
import { defineEmergencyContactModel } from '../models/EmergencyContact.js';
import { defineUserContextModel } from '../models/UserContext.js';
import defineEventModel from '../models/Event.js';
import defineAccountModel from '../models/Account.js';
import defineIncomeModel from '../models/Income.js';
import defineExpenseModel from '../models/Expense.js';
import defineCategoryModel from '../models/Category.js';

let sequelize = null;
let db = null;

const sslDialectOptions = {
  ssl: {
    require: true,
    rejectUnauthorized: false,
  },
};

// Pure seam: turns a database config into the options/connection-string Sequelize needs.
export const buildSequelizeOptions = (dbConfig = config.database) => {
  const options = {
    dialect: dbConfig.dialect,
    pool: dbConfig.pool,
    logging: dbConfig.logging,
    define: {
      underscored: true,
      timestamps: true,
    },
  };

  if (dbConfig.ssl !== false) {
    options.dialectOptions = sslDialectOptions;
  }

  if (dbConfig.databaseUrl) {
    return {
      useUrl: true,
      connectionString: dbConfig.databaseUrl,
      options,
    };
  }

  return {
    useUrl: false,
    database: dbConfig.name,
    username: dbConfig.username,
    password: dbConfig.password,
    options: {
      ...options,
      host: dbConfig.host,
      port: dbConfig.port,
    },
  };
};

// Single factory that turns env config into a Sequelize instance.
export const createSequelize = (dbConfig = config.database) => {
  const connection = buildSequelizeOptions(dbConfig);

  if (connection.useUrl) {
    return new Sequelize(connection.connectionString, connection.options);
  }

  return new Sequelize(
    connection.database,
    connection.username,
    connection.password,
    connection.options
  );
};

export const initializeDatabase = async () => {
  try {
    if (sequelize) {
      return { sequelize, db };
    }

    sequelize = createSequelize();

    // Test connection
    await sequelize.authenticate();
    console.log('✅ Database connection established');

    // Define models
    const User = defineUserModel(sequelize);
    const EmergencyContact = defineEmergencyContactModel(sequelize);
    const UserContext = defineUserContextModel(sequelize);
    const Event = defineEventModel(sequelize);
    const Account = defineAccountModel(sequelize);
    const Income = defineIncomeModel(sequelize);
    const Expense = defineExpenseModel(sequelize);
    const Category = defineCategoryModel(sequelize);

    // Define associations
    User.hasMany(EmergencyContact, {
      foreignKey: 'user_id',
      onDelete: 'CASCADE',
    });
    EmergencyContact.belongsTo(User, { foreignKey: 'user_id' });

    User.hasMany(UserContext, {
      foreignKey: 'user_id',
      onDelete: 'CASCADE',
    });
    UserContext.belongsTo(User, { foreignKey: 'user_id' });

    User.hasMany(Event, {
      foreignKey: 'user_id',
      onDelete: 'CASCADE',
    });
    Event.belongsTo(User, { foreignKey: 'user_id' });

    User.hasMany(Account, {
      foreignKey: 'user_id',
      onDelete: 'CASCADE',
    });
    Account.belongsTo(User, { foreignKey: 'user_id' });

    User.hasMany(Income, {
      foreignKey: 'user_id',
      onDelete: 'CASCADE',
    });
    Income.belongsTo(User, { foreignKey: 'user_id' });
    Income.belongsTo(Account, { foreignKey: 'account_id' });

    User.hasMany(Expense, {
      foreignKey: 'user_id',
      onDelete: 'CASCADE',
    });
    Expense.belongsTo(User, { foreignKey: 'user_id' });
    Expense.belongsTo(Account, { foreignKey: 'account_id' });
    Expense.belongsTo(Category, { foreignKey: 'category_id' });

    Category.hasMany(Expense, {
      foreignKey: 'category_id',
      onDelete: 'CASCADE',
    });

    db = {
      sequelize,
      User,
      EmergencyContact,
      UserContext,
      Event,
      Account,
      Income,
      Expense,
      Category,
    };

    return { sequelize, db };
  } catch (error) {
    console.error('❌ Database initialization error:', error);
    throw error;
  }
};

export const getDatabase = () => {
  if (!db) {
    throw new Error('Database not initialized. Call initializeDatabase first.');
  }
  return db;
};

export const closeDatabase = async () => {
  if (sequelize) {
    await sequelize.close();
    console.log('✅ Database connection closed');
  }
};

export default {
  initializeDatabase,
  getDatabase,
  closeDatabase,
};
