import { DataTypes } from 'sequelize';

export const defineUserContextModel = (sequelize) => {
  const UserContext = sequelize.define(
    'UserContext',
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
      agent_type: {
        type: DataTypes.STRING(50),
        allowNull: true,
        comment: 'otto (kitchen), luna (finance), tina (domestic)',
      },
      interests: {
        type: DataTypes.JSONB,
        allowNull: true,
        defaultValue: {},
      },
      routine_data: {
        type: DataTypes.JSONB,
        allowNull: true,
        defaultValue: {},
      },
      preferences: {
        type: DataTypes.JSONB,
        allowNull: true,
        defaultValue: {},
      },
      common_questions: {
        type: DataTypes.ARRAY(DataTypes.TEXT),
        allowNull: true,
        defaultValue: [],
      },
      last_updated: {
        type: DataTypes.DATE,
        defaultValue: DataTypes.NOW,
      },
    },
    {
      tableName: 'user_context',
      timestamps: false,
      underscored: true,
    }
  );

  return UserContext;
};
