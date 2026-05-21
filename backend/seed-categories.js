import { initializeDatabase } from './src/config/database.js';

async function seedCategories() {
  try {
    console.log('🌱 Seeding categories...');
    const { sequelize } = await initializeDatabase();

    // Delete existing categories
    await sequelize.query('TRUNCATE TABLE categories CASCADE');
    console.log('  🗑️  Cleared categories table');

    // Insert default categories
    const categories = [
      { name: 'Água', icon: 'water', color: '#2196F3' },
      { name: 'Luz', icon: 'lightbulb', color: '#FFC107' },
      { name: 'Internet', icon: 'wifi', color: '#4CAF50' },
      { name: 'Aluguel', icon: 'home', color: '#F44336' },
      { name: 'Alimentação', icon: 'restaurant', color: '#FF9800' },
      { name: 'Transporte', icon: 'directions_car', color: '#9C27B0' },
      { name: 'Saúde', icon: 'health_and_beauty', color: '#00BCD4' },
      { name: 'Educação', icon: 'school', color: '#3F51B5' },
      { name: 'Diversão', icon: 'entertainment', color: '#E91E63' },
    ];

    for (const category of categories) {
      await sequelize.query(
        `INSERT INTO categories (name, icon, color, is_default, created_at)
         VALUES (:name, :icon, :color, true, NOW())`,
        { replacements: category }
      );
    }

    console.log(`  ✅ Inserted ${categories.length} categories`);

    // Verify
    const count = await sequelize.query('SELECT COUNT(*) as count FROM categories', {
      type: sequelize.QueryTypes.SELECT,
    });
    console.log(`  ✔️  Database now has ${count[0].count} categories`);

    await sequelize.close();
    process.exit(0);
  } catch (error) {
    console.error('❌ Seed failed:', error.message);
    process.exit(1);
  }
}

seedCategories();
