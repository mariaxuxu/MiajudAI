const defaultCategories = [
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

export async function up({ context: sequelize }) {
  const queryInterface = sequelize.getQueryInterface();
  const now = new Date();

  await queryInterface.bulkInsert(
    'categories',
    defaultCategories.map((category) => ({
      ...category,
      is_default: true,
      user_id: null,
      created_at: now,
    }))
  );
}

export async function down({ context: sequelize }) {
  const queryInterface = sequelize.getQueryInterface();

  await queryInterface.bulkDelete('categories', {
    is_default: true,
    user_id: null,
  });
}
