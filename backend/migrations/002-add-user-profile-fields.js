import { DataTypes } from 'sequelize';

const profileColumns = {
  gender: { type: DataTypes.STRING(50), allowNull: true },
  birth_date: { type: DataTypes.DATE, allowNull: true },
  birth_country: { type: DataTypes.STRING(100), allowNull: true },
  birth_state: { type: DataTypes.STRING(100), allowNull: true },
  birth_city: { type: DataTypes.STRING(100), allowNull: true },
  nationality: { type: DataTypes.STRING(100), allowNull: true },
  marital_status: { type: DataTypes.STRING(50), allowNull: true },
  emergency_contact_1_name: { type: DataTypes.STRING(255), allowNull: true },
  emergency_contact_1_phone: { type: DataTypes.STRING(20), allowNull: true },
  emergency_contact_2_name: { type: DataTypes.STRING(255), allowNull: true },
  emergency_contact_2_phone: { type: DataTypes.STRING(20), allowNull: true },
  emergency_contact_3_name: { type: DataTypes.STRING(255), allowNull: true },
  emergency_contact_3_phone: { type: DataTypes.STRING(20), allowNull: true },
};

export async function up({ context: sequelize }) {
  const queryInterface = sequelize.getQueryInterface();

  for (const [column, definition] of Object.entries(profileColumns)) {
    await queryInterface.addColumn('users', column, definition);
  }
}

export async function down({ context: sequelize }) {
  const queryInterface = sequelize.getQueryInterface();

  for (const column of Object.keys(profileColumns).reverse()) {
    await queryInterface.removeColumn('users', column);
  }
}
