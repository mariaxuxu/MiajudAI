export async function up({ context: sequelize }) {
  const queryInterface = sequelize.getQueryInterface();

  await queryInterface.addColumn('users', 'gender', {
    type: 'VARCHAR(50)',
    allowNull: true,
  });

  await queryInterface.addColumn('users', 'birth_date', {
    type: 'DATE',
    allowNull: true,
  });

  await queryInterface.addColumn('users', 'birth_country', {
    type: 'VARCHAR(100)',
    allowNull: true,
  });

  await queryInterface.addColumn('users', 'birth_state', {
    type: 'VARCHAR(100)',
    allowNull: true,
  });

  await queryInterface.addColumn('users', 'birth_city', {
    type: 'VARCHAR(100)',
    allowNull: true,
  });

  await queryInterface.addColumn('users', 'nationality', {
    type: 'VARCHAR(100)',
    allowNull: true,
  });

  await queryInterface.addColumn('users', 'marital_status', {
    type: 'VARCHAR(50)',
    allowNull: true,
  });

  await queryInterface.addColumn('users', 'emergency_contact_1_name', {
    type: 'VARCHAR(255)',
    allowNull: true,
  });

  await queryInterface.addColumn('users', 'emergency_contact_1_phone', {
    type: 'VARCHAR(20)',
    allowNull: true,
  });

  await queryInterface.addColumn('users', 'emergency_contact_2_name', {
    type: 'VARCHAR(255)',
    allowNull: true,
  });

  await queryInterface.addColumn('users', 'emergency_contact_2_phone', {
    type: 'VARCHAR(20)',
    allowNull: true,
  });

  await queryInterface.addColumn('users', 'emergency_contact_3_name', {
    type: 'VARCHAR(255)',
    allowNull: true,
  });

  await queryInterface.addColumn('users', 'emergency_contact_3_phone', {
    type: 'VARCHAR(20)',
    allowNull: true,
  });

  console.log('✅ Migration applied: Added user profile fields');
}

export async function down({ context: sequelize }) {
  const queryInterface = sequelize.getQueryInterface();

  await queryInterface.removeColumn('users', 'gender');
  await queryInterface.removeColumn('users', 'birth_date');
  await queryInterface.removeColumn('users', 'birth_country');
  await queryInterface.removeColumn('users', 'birth_state');
  await queryInterface.removeColumn('users', 'birth_city');
  await queryInterface.removeColumn('users', 'nationality');
  await queryInterface.removeColumn('users', 'marital_status');
  await queryInterface.removeColumn('users', 'emergency_contact_1_name');
  await queryInterface.removeColumn('users', 'emergency_contact_1_phone');
  await queryInterface.removeColumn('users', 'emergency_contact_2_name');
  await queryInterface.removeColumn('users', 'emergency_contact_2_phone');
  await queryInterface.removeColumn('users', 'emergency_contact_3_name');
  await queryInterface.removeColumn('users', 'emergency_contact_3_phone');

  console.log('✅ Migration reverted: Removed user profile fields');
}
