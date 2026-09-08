export const defineInstallmentModel = (sequelize, DataTypes) => {
  const Installment = sequelize.define('Installment', {
    id: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true,
    },
    user_id: {
      type: DataTypes.INTEGER,
      allowNull: false,
      references: { model: 'users', key: 'id' },
      onDelete: 'CASCADE',
    },
    name: {
      type: DataTypes.STRING(255),
      allowNull: false,
    },
    total_amount: {
      type: DataTypes.DECIMAL(12, 2),
      allowNull: false,
    },
    total_installments: {
      type: DataTypes.INTEGER,
      allowNull: false,
    },
    installment_value: {
      type: DataTypes.DECIMAL(10, 2),
      allowNull: false,
    },
    due_day_of_month: {
      type: DataTypes.INTEGER,
      allowNull: false,
      validate: { min: 1, max: 31 },
    },
    start_date: {
      type: DataTypes.DATE,
      allowNull: false,
    },
    description: {
      type: DataTypes.TEXT,
      allowNull: true,
    },
    payment_method: {
      type: DataTypes.ENUM('credit_card', 'debit_card', 'pix', 'cash', 'transfer', 'other'),
      defaultValue: 'credit_card',
    },
    merchant_name: {
      type: DataTypes.STRING(255),
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
  }, {
    tableName: 'installments',
    timestamps: true,
    underscored: true,
  });

  return Installment;
};
