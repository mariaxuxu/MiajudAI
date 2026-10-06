export async function up({ context: sequelize }) {
  const queryInterface = sequelize.getQueryInterface();
  const Sequelize = sequelize.constructor;

  await queryInterface.addColumn('users', 'last_sms_alert_at', {
    type: Sequelize.DATE,
    allowNull: true,
    defaultValue: null,
  });
}

export async function down({ context: sequelize }) {
  const queryInterface = sequelize.getQueryInterface();
  await queryInterface.removeColumn('users', 'last_sms_alert_at');
}
