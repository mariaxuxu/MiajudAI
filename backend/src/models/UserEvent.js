import { DataTypes } from 'sequelize';

export default function defineUserEventModel(sequelize) {
  return sequelize.define(
    'UserEvent',
    {
      id: {
        type: DataTypes.UUID,
        primaryKey: true,
        defaultValue: DataTypes.UUIDV4,
      },
      client_event_id: {
        type: DataTypes.UUID,
        allowNull: false,
      },
      user_id: {
        type: DataTypes.INTEGER,
        allowNull: false,
        references: { model: 'users', key: 'id' },
      },
      action: {
        type: DataTypes.STRING(100),
        allowNull: false,
      },
      screen_name: {
        type: DataTypes.STRING(100),
        allowNull: true,
      },
      metadata: {
        type: DataTypes.JSONB,
        allowNull: false,
        defaultValue: {},
      },
      created_at: {
        type: DataTypes.DATE,
        allowNull: false,
        defaultValue: DataTypes.NOW,
      },
    },
    {
      tableName: 'user_events',
      timestamps: false,
      underscored: true,
    }
  );
}
