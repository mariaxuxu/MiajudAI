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
import defineDiaryEntryModel from '../models/DiaryEntry.js';
import defineScreenEventModel from '../models/ScreenEvent.js';
import defineInteractionEventModel from '../models/InteractionEvent.js';

let sequelize = null;
let db = null;

export const initializeDatabase = async () => {
  try {
    if (sequelize) {
      return { sequelize, db };
    }

    sequelize = new Sequelize(
      config.database.name,
      config.database.username,
      config.database.password,
      {
        host: config.database.host,
        port: config.database.port,
        dialect: config.database.dialect,
        pool: config.database.pool,
        logging: config.database.logging,
        define: {
          underscored: true,
          timestamps: true,
        },
      }
    );

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
    const DiaryEntry = defineDiaryEntryModel(sequelize);
    const ScreenEvent = defineScreenEventModel(sequelize);
    const InteractionEvent = defineInteractionEventModel(sequelize);

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

    User.hasMany(DiaryEntry, {
      foreignKey: 'user_id',
      onDelete: 'CASCADE',
    });
    DiaryEntry.belongsTo(User, { foreignKey: 'user_id' });

    User.hasMany(ScreenEvent, {
      foreignKey: 'user_id',
      onDelete: 'CASCADE',
    });
    ScreenEvent.belongsTo(User, { foreignKey: 'user_id' });

    User.hasMany(InteractionEvent, {
      foreignKey: 'user_id',
      onDelete: 'CASCADE',
    });
    InteractionEvent.belongsTo(User, { foreignKey: 'user_id' });

    // Sync models
    await sequelize.sync({ alter: false });
    console.log('✅ Database models synchronized');

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
      DiaryEntry,
      ScreenEvent,
      InteractionEvent,
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
