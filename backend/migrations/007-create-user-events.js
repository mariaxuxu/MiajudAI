import { DataTypes, literal } from 'sequelize';

export async function up({ context: sequelize }) {
  const queryInterface = sequelize.getQueryInterface();

  // gen_random_uuid() is built-in on Postgres >= 13 (Supabase uses PG 15);
  // keep the extension as a safeguard for older local Postgres.
  await sequelize.query('CREATE EXTENSION IF NOT EXISTS pgcrypto;');

  await queryInterface.createTable('user_events', {
    id: {
      type: DataTypes.UUID,
      primaryKey: true,
      allowNull: false,
      defaultValue: literal('gen_random_uuid()'),
    },
    user_id: {
      type: DataTypes.INTEGER,
      allowNull: false,
      references: { model: 'users', key: 'id' },
      onDelete: 'CASCADE',
    },
    action: { type: DataTypes.STRING(100), allowNull: false },
    screen_name: { type: DataTypes.STRING(100), allowNull: true },
    metadata: { type: DataTypes.JSONB, allowNull: false, defaultValue: {} },
    created_at: { type: DataTypes.DATE, allowNull: false, defaultValue: DataTypes.NOW },
  });

  await sequelize.query(
    'CREATE INDEX idx_user_events_user_created ON user_events(user_id, created_at DESC);'
  );
}

export async function down({ context: sequelize }) {
  const queryInterface = sequelize.getQueryInterface();

  // Only drops the new table; old tables (screen_events, interaction_events,
  // diary_entries) are intentionally left untouched as fallback.
  await queryInterface.dropTable('user_events');
}
