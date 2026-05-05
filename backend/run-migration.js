import { initializeDatabase } from './src/config/database.js';

async function runMigration() {
  try {
    console.log('🔄 Running migrations...');

    const { sequelize } = await initializeDatabase();

    // Adiciona as novas colunas
    const queryInterface = sequelize.getQueryInterface();

    const columns = await queryInterface.describeTable('users');

    const fieldsToAdd = {
      gender: {
        type: 'VARCHAR(50)',
        allowNull: true,
      },
      birth_date: {
        type: 'DATE',
        allowNull: true,
      },
      birth_country: {
        type: 'VARCHAR(100)',
        allowNull: true,
      },
      birth_state: {
        type: 'VARCHAR(100)',
        allowNull: true,
      },
      birth_city: {
        type: 'VARCHAR(100)',
        allowNull: true,
      },
      nationality: {
        type: 'VARCHAR(100)',
        allowNull: true,
      },
      marital_status: {
        type: 'VARCHAR(50)',
        allowNull: true,
      },
      emergency_contact_1_name: {
        type: 'VARCHAR(255)',
        allowNull: true,
      },
      emergency_contact_1_phone: {
        type: 'VARCHAR(20)',
        allowNull: true,
      },
      emergency_contact_2_name: {
        type: 'VARCHAR(255)',
        allowNull: true,
      },
      emergency_contact_2_phone: {
        type: 'VARCHAR(20)',
        allowNull: true,
      },
      emergency_contact_3_name: {
        type: 'VARCHAR(255)',
        allowNull: true,
      },
      emergency_contact_3_phone: {
        type: 'VARCHAR(20)',
        allowNull: true,
      },
    };

    for (const [fieldName, fieldConfig] of Object.entries(fieldsToAdd)) {
      if (!columns[fieldName]) {
        console.log(`  ➕ Adding column: ${fieldName}`);
        await queryInterface.addColumn('users', fieldName, fieldConfig);
      } else {
        console.log(`  ⏭️  Column already exists: ${fieldName}`);
      }
    }

    // Create events table if it doesn't exist
    const tables = await queryInterface.showAllTables();
    if (tables.includes('events')) {
      console.log('  🔄 Checking events table schema');
      try {
        const eventColumns = await queryInterface.describeTable('events');
        if (eventColumns.event_datetime && !eventColumns.event_date) {
          console.log('  🔄 Renaming event_datetime to event_date');
          await queryInterface.renameColumn('events', 'event_datetime', 'event_date');
        }
      } catch (error) {
        console.log('  ⚠️  Could not check events table, will recreate');
        await queryInterface.dropTable('events');
        console.log('  ➕ Creating events table');
        await queryInterface.createTable('events', {
          id: {
            type: 'INTEGER',
            primaryKey: true,
            autoIncrement: true,
          },
          user_id: {
            type: 'INTEGER',
            allowNull: false,
            references: {
              model: 'users',
              key: 'id',
            },
          },
          title: {
            type: 'VARCHAR(255)',
            allowNull: false,
          },
          event_date: {
            type: 'DATE',
            allowNull: false,
          },
          created_at: {
            type: 'TIMESTAMP',
            defaultValue: sequelize.literal('CURRENT_TIMESTAMP'),
          },
          updated_at: {
            type: 'TIMESTAMP',
            defaultValue: sequelize.literal('CURRENT_TIMESTAMP'),
          },
        });
      }
    } else {
      console.log('  ➕ Creating events table');
      await queryInterface.createTable('events', {
        id: {
          type: 'INTEGER',
          primaryKey: true,
          autoIncrement: true,
        },
        user_id: {
          type: 'INTEGER',
          allowNull: false,
          references: {
            model: 'users',
            key: 'id',
          },
        },
        title: {
          type: 'VARCHAR(255)',
          allowNull: false,
        },
        event_date: {
          type: 'DATE',
          allowNull: false,
        },
        created_at: {
          type: 'TIMESTAMP',
          defaultValue: sequelize.literal('CURRENT_TIMESTAMP'),
        },
        updated_at: {
          type: 'TIMESTAMP',
          defaultValue: sequelize.literal('CURRENT_TIMESTAMP'),
        },
      });
    }

    // Create categories table with default categories
    if (!tables.includes('categories')) {
      console.log('  ➕ Creating categories table');
      await queryInterface.createTable('categories', {
        id: {
          type: 'INTEGER',
          primaryKey: true,
          autoIncrement: true,
        },
        user_id: {
          type: 'INTEGER',
          allowNull: true,
          references: {
            model: 'users',
            key: 'id',
          },
        },
        name: {
          type: 'VARCHAR(100)',
          allowNull: false,
        },
        icon: {
          type: 'VARCHAR(50)',
          allowNull: true,
        },
        color: {
          type: 'VARCHAR(7)',
          allowNull: true,
        },
        is_default: {
          type: 'BOOLEAN',
          defaultValue: false,
        },
        created_at: {
          type: 'TIMESTAMP',
          defaultValue: sequelize.literal('CURRENT_TIMESTAMP'),
        },
      });
      console.log('  ✅ Categories table created');
    }

    // Always check and insert missing default categories
    console.log('  🔄 Ensuring default categories exist');
    try {
      const categoryCount = await sequelize.query('SELECT COUNT(*) as count FROM categories WHERE is_default = true', {
        type: sequelize.QueryTypes.SELECT,
      });

      if (categoryCount[0].count === 0) {
        console.log('  ➕ Inserting default categories');
        const defaultCategories = [
          { name: 'Água', icon: 'water', color: '#2196F3', is_default: true },
          { name: 'Luz', icon: 'lightbulb', color: '#FFC107', is_default: true },
          { name: 'Internet', icon: 'wifi', color: '#4CAF50', is_default: true },
          { name: 'Aluguel', icon: 'home', color: '#F44336', is_default: true },
          { name: 'Alimentação', icon: 'restaurant', color: '#FF9800', is_default: true },
          { name: 'Transporte', icon: 'directions_car', color: '#9C27B0', is_default: true },
          { name: 'Saúde', icon: 'health_and_beauty', color: '#00BCD4', is_default: true },
          { name: 'Educação', icon: 'school', color: '#3F51B5', is_default: true },
          { name: 'Diversão', icon: 'entertainment', color: '#E91E63', is_default: true },
        ];

        for (const category of defaultCategories) {
          await sequelize.query(
            `INSERT INTO categories (name, icon, color, is_default, created_at)
             VALUES (:name, :icon, :color, :is_default, NOW())`,
            {
              replacements: category,
              type: sequelize.QueryTypes.INSERT,
            }
          );
        }
        console.log('  ✅ Default categories inserted');
      } else {
        console.log('  ⏭️  Categories already exist');
      }
    } catch (error) {
      console.log('  ⚠️  Error with categories:', error.message);
    }

    // Create accounts table
    if (!tables.includes('accounts')) {
      console.log('  ➕ Creating accounts table');
      await queryInterface.createTable('accounts', {
        id: {
          type: 'INTEGER',
          primaryKey: true,
          autoIncrement: true,
        },
        user_id: {
          type: 'INTEGER',
          allowNull: false,
          references: {
            model: 'users',
            key: 'id',
          },
        },
        name: {
          type: 'VARCHAR(255)',
          allowNull: false,
        },
        type: {
          type: 'ENUM',
          values: ['checking', 'savings', 'credit_card', 'other'],
          allowNull: false,
          defaultValue: 'checking',
        },
        balance: {
          type: 'DECIMAL(10, 2)',
          allowNull: false,
          defaultValue: 0,
        },
        bank_name: {
          type: 'VARCHAR(100)',
          allowNull: true,
        },
        account_number: {
          type: 'VARCHAR(50)',
          allowNull: true,
        },
        is_active: {
          type: 'BOOLEAN',
          defaultValue: true,
        },
        created_at: {
          type: 'TIMESTAMP',
          defaultValue: sequelize.literal('CURRENT_TIMESTAMP'),
        },
        updated_at: {
          type: 'TIMESTAMP',
          defaultValue: sequelize.literal('CURRENT_TIMESTAMP'),
        },
      });
    }

    // Create income table
    if (!tables.includes('income')) {
      console.log('  ➕ Creating income table');
      await queryInterface.createTable('income', {
        id: {
          type: 'INTEGER',
          primaryKey: true,
          autoIncrement: true,
        },
        user_id: {
          type: 'INTEGER',
          allowNull: false,
          references: {
            model: 'users',
            key: 'id',
          },
        },
        account_id: {
          type: 'INTEGER',
          allowNull: true,
          references: {
            model: 'accounts',
            key: 'id',
          },
        },
        amount: {
          type: 'DECIMAL(10, 2)',
          allowNull: false,
        },
        description: {
          type: 'VARCHAR(255)',
          allowNull: false,
        },
        type: {
          type: 'ENUM',
          values: ['salary', 'freelance', 'investment', 'gift', 'other'],
          allowNull: false,
          defaultValue: 'salary',
        },
        income_date: {
          type: 'TIMESTAMP',
          allowNull: false,
        },
        is_recurring: {
          type: 'BOOLEAN',
          defaultValue: false,
        },
        recurrence_type: {
          type: 'ENUM',
          values: ['monthly', 'yearly', 'weekly'],
          allowNull: true,
        },
        created_at: {
          type: 'TIMESTAMP',
          defaultValue: sequelize.literal('CURRENT_TIMESTAMP'),
        },
        updated_at: {
          type: 'TIMESTAMP',
          defaultValue: sequelize.literal('CURRENT_TIMESTAMP'),
        },
      });
    }

    // Create expenses table
    if (!tables.includes('expenses')) {
      console.log('  ➕ Creating expenses table');
      await queryInterface.createTable('expenses', {
        id: {
          type: 'INTEGER',
          primaryKey: true,
          autoIncrement: true,
        },
        user_id: {
          type: 'INTEGER',
          allowNull: false,
          references: {
            model: 'users',
            key: 'id',
          },
        },
        account_id: {
          type: 'INTEGER',
          allowNull: true,
          references: {
            model: 'accounts',
            key: 'id',
          },
        },
        category_id: {
          type: 'INTEGER',
          allowNull: false,
          references: {
            model: 'categories',
            key: 'id',
          },
        },
        amount: {
          type: 'DECIMAL(10, 2)',
          allowNull: false,
        },
        description: {
          type: 'VARCHAR(255)',
          allowNull: false,
        },
        expense_date: {
          type: 'TIMESTAMP',
          allowNull: false,
        },
        is_recurring: {
          type: 'BOOLEAN',
          defaultValue: false,
        },
        recurrence_type: {
          type: 'ENUM',
          values: ['monthly', 'yearly', 'weekly'],
          allowNull: true,
        },
        payment_method: {
          type: 'ENUM',
          values: ['cash', 'credit_card', 'debit_card', 'transfer', 'other'],
          defaultValue: 'cash',
        },
        status: {
          type: 'ENUM',
          values: ['pending', 'paid', 'overdue'],
          defaultValue: 'paid',
        },
        tags: {
          type: 'VARCHAR(500)',
          allowNull: true,
        },
        created_at: {
          type: 'TIMESTAMP',
          defaultValue: sequelize.literal('CURRENT_TIMESTAMP'),
        },
        updated_at: {
          type: 'TIMESTAMP',
          defaultValue: sequelize.literal('CURRENT_TIMESTAMP'),
        },
      });
    } else {
      console.log('  🔄 Checking expenses table schema');
      try {
        const expenseColumns = await queryInterface.describeTable('expenses');
        if (!expenseColumns.tags) {
          console.log('  ➕ Adding tags column to expenses table');
          await queryInterface.addColumn('expenses', 'tags', {
            type: 'VARCHAR(500)',
            allowNull: true,
          });
        }
      } catch (error) {
        console.log('  ⚠️  Could not check expenses table:', error.message);
      }
    }

    console.log('✅ Migrations completed successfully!');
    await sequelize.close();
    process.exit(0);
  } catch (error) {
    console.error('❌ Migration failed:', error);
    process.exit(1);
  }
}

runMigration();
