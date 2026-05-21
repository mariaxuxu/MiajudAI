import { DataTypes } from 'sequelize';

export default function defineIncomeModel(sequelize) {
  return sequelize.define(
    'Income',
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
      account_id: {
        type: DataTypes.INTEGER,
        allowNull: true,
        references: {
          model: 'accounts',
          key: 'id',
        },
      },
      amount: {
        type: DataTypes.DECIMAL(10, 2),
        allowNull: false,
      },
      description: {
        type: DataTypes.STRING(255),
        allowNull: false,
      },
      type: {
        type: DataTypes.ENUM('salary', 'freelance', 'investment', 'gift', 'other'),
        allowNull: false,
        defaultValue: 'salary',
      },
      income_date: {
        type: DataTypes.DATE,
        allowNull: false,
      },
      is_recurring: {
        type: DataTypes.BOOLEAN,
        defaultValue: false,
      },
      recurrence_type: {
        type: DataTypes.ENUM('monthly', 'yearly', 'weekly'),
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
    },
    {
      tableName: 'income',
      timestamps: false,
      underscored: true,
    }
  );
}
