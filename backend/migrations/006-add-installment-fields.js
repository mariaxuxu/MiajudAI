export async function up({ context: sequelize }) {
  const queryInterface = sequelize.getQueryInterface();
  const Sequelize = sequelize.constructor;

  // Adicionar payment_method
  await queryInterface.sequelize.query(`
    DO 'BEGIN CREATE TYPE "public"."enum_installments_payment_method" AS ENUM(''credit_card'', ''debit_card'', ''pix'', ''cash'', ''transfer'', ''other'');
    EXCEPTION WHEN duplicate_object THEN null; END';
  `);

  await queryInterface.addColumn('installments', 'payment_method', {
    type: Sequelize.ENUM('credit_card', 'debit_card', 'pix', 'cash', 'transfer', 'other'),
    defaultValue: 'credit_card',
  });

  // Adicionar merchant_name
  await queryInterface.addColumn('installments', 'merchant_name', {
    type: Sequelize.STRING(255),
    allowNull: true,
  });
}

export async function down({ context: sequelize }) {
  const queryInterface = sequelize.getQueryInterface();
  await queryInterface.removeColumn('installments', 'merchant_name');
  await queryInterface.removeColumn('installments', 'payment_method');
}
