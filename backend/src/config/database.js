import { Sequelize } from 'sequelize';
import config from './env.js';
import { defineUserModel } from '../models/User.js';
import { defineEmergencyContactModel } from '../models/EmergencyContact.js';
import { defineUserContextModel } from '../models/UserContext.js';

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

    // Sync models
    await sequelize.sync({ alter: false });
    console.log('✅ Database models synchronized');

    db = {
      sequelize,
      User,
      EmergencyContact,
      UserContext,
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
