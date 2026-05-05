import { DataTypes } from 'sequelize';

export default function defineAccountModel(sequelize) {
  return sequelize.define(
    'Account',
    {
      id: {
        type: DataTypes.INTEGER,
        primaryKey: true,
        autoIncrement: true,
      },
      user_id: {
        type: DataTypes.INTEGER,
        allowNull: false,
        references: {
          model: 'users',
          key: 'id',
        },
      },
      name: {
        type: DataTypes.STRING(255),
        allowNull: false,
      },
      type: {
        type: DataTypes.ENUM('checking', 'savings', 'credit_card', 'other'),
        allowNull: false,
        defaultValue: 'checking',
      },
      balance: {
        type: DataTypes.DECIMAL(10, 2),
        allowNull: false,
        defaultValue: 0,
      },
      bank_name: {
        type: DataTypes.STRING(100),
        allowNull: true,
      },
      account_number: {
        type: DataTypes.STRING(50),
        allowNull: true,
      },
      is_active: {
        type: DataTypes.BOOLEAN,
        defaultValue: true,
      },
      created_at: {
        type: DataTypes.DATE,
        defaultValue: DataTypes.NOW,
      },
      updated_at: {
        type: DataTypes.DATE,
        defaultValue: DataTypes.NOW,
      },
    },
    {
      tableName: 'accounts',
      timestamps: false,
      underscored: true,
    }
  );
}
