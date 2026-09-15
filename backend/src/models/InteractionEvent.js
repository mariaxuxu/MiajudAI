import { DataTypes } from 'sequelize';

export default function defineInteractionEventModel(sequelize) {
  return sequelize.define(
    'InteractionEvent',
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
      interaction_type: {
        type: DataTypes.STRING(100),
        allowNull: false,
        comment: 'Type of interaction: clicked_add_income, submitted_chat, etc',
      },
      screen_name: {
        type: DataTypes.STRING(100),
        allowNull: true,
        comment: 'Screen where interaction occurred',
      },
      created_at: {
        type: DataTypes.DATE,
        defaultValue: DataTypes.NOW,
      },
    },
    {
      tableName: 'interaction_events',
      timestamps: false,
      underscored: true,
    }
  );
}
