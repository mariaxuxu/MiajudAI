import { DataTypes } from 'sequelize';

export async function up({ context: sequelize }) {
  const queryInterface = sequelize.getQueryInterface();

  await queryInterface.createTable('diary_entries', {
    id: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
    user_id: {
      type: DataTypes.INTEGER,
      allowNull: false,
      references: { model: 'users', key: 'id' },
      onDelete: 'CASCADE',
    },
    text: { type: DataTypes.TEXT, allowNull: false },
    mood: {
      type: DataTypes.ENUM('happy', 'sad', 'neutral'),
      allowNull: false,
    },
    tags: {
      type: DataTypes.ARRAY(DataTypes.STRING(50)),
      allowNull: true,
      defaultValue: [],
    },
    emotion_score: { type: DataTypes.INTEGER, allowNull: false },
    created_at: { type: DataTypes.DATE, defaultValue: DataTypes.NOW },
    updated_at: { type: DataTypes.DATE, defaultValue: DataTypes.NOW },
  });
  await queryInterface.addIndex('diary_entries', ['user_id', 'created_at']);
  await queryInterface.addIndex('diary_entries', ['tags']);

  await queryInterface.createTable('screen_events', {
    id: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
    user_id: {
      type: DataTypes.INTEGER,
      allowNull: false,
      references: { model: 'users', key: 'id' },
      onDelete: 'CASCADE',
    },
    screen_name: { type: DataTypes.STRING(100), allowNull: false },
    dwell_time_seconds: { type: DataTypes.INTEGER, allowNull: true },
    source_screen: { type: DataTypes.STRING(100), allowNull: true },
    created_at: { type: DataTypes.DATE, defaultValue: DataTypes.NOW },
  });
  await queryInterface.addIndex('screen_events', ['user_id', 'created_at']);
  await queryInterface.addIndex('screen_events', ['screen_name']);

  await queryInterface.createTable('interaction_events', {
    id: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
    user_id: {
      type: DataTypes.INTEGER,
      allowNull: false,
      references: { model: 'users', key: 'id' },
      onDelete: 'CASCADE',
    },
    interaction_type: { type: DataTypes.STRING(100), allowNull: false },
    screen_name: { type: DataTypes.STRING(100), allowNull: true },
    created_at: { type: DataTypes.DATE, defaultValue: DataTypes.NOW },
  });
  await queryInterface.addIndex('interaction_events', ['user_id', 'created_at']);
  await queryInterface.addIndex('interaction_events', ['interaction_type']);
}

export async function down({ context: sequelize }) {
  const queryInterface = sequelize.getQueryInterface();

  await queryInterface.dropTable('interaction_events');
  await queryInterface.dropTable('screen_events');
  await queryInterface.dropTable('diary_entries');

  // Sequelize leaves native ENUM types orphaned after dropTable; drop so `up`
  // can run again without a duplicate-type conflict.
  await sequelize.query(`DROP TYPE IF EXISTS "enum_diary_entries_mood";`);
}
