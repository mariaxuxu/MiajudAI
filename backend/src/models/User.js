import { DataTypes } from 'sequelize';

export const defineUserModel = (sequelize) => {
  const User = sequelize.define(
    'User',
    {
      id: {
        type: DataTypes.INTEGER,
        primaryKey: true,
        autoIncrement: true,
      },
      firebase_uid: {
        type: DataTypes.STRING(255),
        unique: true,
        allowNull: false,
      },
      email: {
        type: DataTypes.STRING(255),
        unique: true,
        allowNull: false,
        validate: {
          isEmail: true,
        },
      },
      phone: {
        type: DataTypes.STRING(20),
        allowNull: true,
      },
      full_name: {
        type: DataTypes.STRING(255),
        allowNull: true,
      },
      avatar_url: {
        type: DataTypes.TEXT,
        allowNull: true,
      },
      gender: {
        type: DataTypes.STRING(50),
        allowNull: true,
      },
      birth_date: {
        type: DataTypes.DATE,
        allowNull: true,
      },
      birth_country: {
        type: DataTypes.STRING(100),
        allowNull: true,
      },
      birth_state: {
        type: DataTypes.STRING(100),
        allowNull: true,
      },
      birth_city: {
        type: DataTypes.STRING(100),
        allowNull: true,
      },
      nationality: {
        type: DataTypes.STRING(100),
        allowNull: true,
      },
      marital_status: {
        type: DataTypes.STRING(50),
        allowNull: true,
      },
      emergency_contact_1_name: {
        type: DataTypes.STRING(255),
        allowNull: true,
      },
      emergency_contact_1_phone: {
        type: DataTypes.STRING(20),
        allowNull: true,
      },
      emergency_contact_2_name: {
        type: DataTypes.STRING(255),
        allowNull: true,
      },
      emergency_contact_2_phone: {
        type: DataTypes.STRING(20),
        allowNull: true,
      },
      emergency_contact_3_name: {
        type: DataTypes.STRING(255),
        allowNull: true,
      },
      emergency_contact_3_phone: {
        type: DataTypes.STRING(20),
        allowNull: true,
      },
      created_at: {
        type: DataTypes.DATE,
        defaultValue: DataTypes.NOW,
      },
      updated_at: {
        type: DataTypes.DATE,
        defaultValue: DataTypes.NOW,
      },
      last_activity: {
        type: DataTypes.DATE,
        allowNull: true,
      },
    },
    {
      tableName: 'users',
      timestamps: false,
      underscored: true,
    }
  );

  return User;
};
