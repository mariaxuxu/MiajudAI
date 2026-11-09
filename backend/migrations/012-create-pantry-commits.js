import { DataTypes } from 'sequelize';

// Idempotency ledger for market-trip commits. A row records "this commit_key
// was already applied for this user", so a retry (double tap, timeout retry)
// is a no-op instead of a second increment. It deliberately stores no item or
// quantity data — user_pantry remains the only source of truth for what the
// user owns; this table only remembers which operations were applied.
//
// The key is client-generated, so uniqueness is scoped to the user rather
// than global: two users may legitimately produce the same UUID.
export async function up({ context: sequelize }) {
  const queryInterface = sequelize.getQueryInterface();

  await queryInterface.createTable('pantry_commits', {
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
    commit_key: {
      type: DataTypes.UUID,
      allowNull: false,
    },
    created_at: {
      type: DataTypes.DATE,
      allowNull: false,
      defaultValue: DataTypes.NOW,
    },
  });

  await sequelize.query(
    'ALTER TABLE pantry_commits ADD CONSTRAINT pantry_commits_user_key_unique UNIQUE (user_id, commit_key);'
  );
}

export async function down({ context: sequelize }) {
  const queryInterface = sequelize.getQueryInterface();

  await queryInterface.dropTable('pantry_commits');
}
