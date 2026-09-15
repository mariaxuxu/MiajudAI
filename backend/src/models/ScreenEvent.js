import { DataTypes } from 'sequelize';

export default function defineScreenEventModel(sequelize) {
  return sequelize.define(
    'ScreenEvent',
    {
      id: {
        type: DataTypes.INTEGER,
        primaryKey: true,
        autoIncrement: true,
      },
      user_id: {
        type: DataTypes.INTEGER,
        allowNull: false,
        references: {
          model: 'users',
          key: 'id',
        },
      },
      screen_name: {
        type: DataTypes.STRING(100),
        allowNull: false,
        comment: 'Screen identifier: /accounts, /calendar, /chat, etc',
      },
      dwell_time_seconds: {
        type: DataTypes.INTEGER,
        allowNull: true,
        comment: 'Time spent on screen in seconds',
      },
      source_screen: {
        type: DataTypes.STRING(100),
        allowNull: true,
        comment: 'Previous screen name for navigation tracking',
      },
      created_at: {
        type: DataTypes.DATE,
        defaultValue: DataTypes.NOW,
      },
    },
    {
      tableName: 'screen_events',
      timestamps: false,
      underscored: true,
    }
  );
}
