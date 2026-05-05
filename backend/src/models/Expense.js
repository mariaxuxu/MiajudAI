import { DataTypes } from 'sequelize';

export default function defineExpenseModel(sequelize) {
  return sequelize.define(
    'Expense',
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
      category_id: {
        type: DataTypes.INTEGER,
        allowNull: false,
        references: {
          model: 'categories',
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
      expense_date: {
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
      payment_method: {
        type: DataTypes.ENUM('cash', 'credit_card', 'debit_card', 'transfer', 'other'),
        defaultValue: 'cash',
      },
      status: {
        type: DataTypes.ENUM('pending', 'paid', 'overdue'),
        defaultValue: 'paid',
      },
      tags: {
        type: DataTypes.STRING(500),
        allowNull: true,
        comment: 'Tags separadas por vírgula',
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
      tableName: 'expenses',
      timestamps: false,
      underscored: true,
    }
  );
}
