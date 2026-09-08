export async function up({ context: sequelize }) {
  const queryInterface = sequelize.getQueryInterface();
  const Sequelize = sequelize.constructor;

  // Create Installments table
  await queryInterface.createTable('installments', {
      id: {
        type: Sequelize.INTEGER,
        primaryKey: true,
        autoIncrement: true,
      },
      user_id: {
        type: Sequelize.INTEGER,
        allowNull: false,
        references: {
          model: 'users',
          key: 'id',
        },
        onDelete: 'CASCADE',
      },
      name: {
        type: Sequelize.STRING(255),
        allowNull: false,
      },
      total_amount: {
        type: Sequelize.DECIMAL(10, 2),
        allowNull: false,
      },
      total_installments: {
        type: Sequelize.INTEGER,
        allowNull: false,
      },
      installment_value: {
        type: Sequelize.DECIMAL(10, 2),
        allowNull: false,
      },
      due_day_of_month: {
        type: Sequelize.INTEGER,
        allowNull: false,
      },
      start_date: {
        type: Sequelize.DATE,
        allowNull: false,
      },
      description: {
        type: Sequelize.TEXT,
      },
      is_active: {
        type: Sequelize.BOOLEAN,
        defaultValue: true,
      },
      created_at: {
        type: Sequelize.DATE,
        allowNull: false,
        defaultValue: Sequelize.NOW,
      },
      updated_at: {
        type: Sequelize.DATE,
        allowNull: false,
        defaultValue: Sequelize.NOW,
      },
    });

    // Create FixedCosts table
    await queryInterface.createTable('fixed_costs', {
      id: {
        type: Sequelize.INTEGER,
        primaryKey: true,
        autoIncrement: true,
      },
      user_id: {
        type: Sequelize.INTEGER,
        allowNull: false,
        references: {
          model: 'users',
          key: 'id',
        },
        onDelete: 'CASCADE',
      },
      name: {
        type: Sequelize.STRING(255),
        allowNull: false,
      },
      amount: {
        type: Sequelize.DECIMAL(10, 2),
        allowNull: false,
      },
      due_day_of_month: {
        type: Sequelize.INTEGER,
        allowNull: false,
      },
      category: {
        type: Sequelize.ENUM('streaming', 'rent', 'utility', 'subscription', 'insurance', 'other'),
        defaultValue: 'other',
      },
      description: {
        type: Sequelize.TEXT,
      },
      is_active: {
        type: Sequelize.BOOLEAN,
        defaultValue: true,
      },
      created_at: {
        type: Sequelize.DATE,
        allowNull: false,
        defaultValue: Sequelize.NOW,
      },
      updated_at: {
        type: Sequelize.DATE,
        allowNull: false,
        defaultValue: Sequelize.NOW,
      },
    });

  // Create indexes
  await queryInterface.addIndex('installments', ['user_id']);
  await queryInterface.addIndex('fixed_costs', ['user_id']);
}

export async function down({ context: sequelize }) {
  const queryInterface = sequelize.getQueryInterface();
  await queryInterface.dropTable('fixed_costs');
  await queryInterface.dropTable('installments');
}
