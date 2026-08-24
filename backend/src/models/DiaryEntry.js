import { DataTypes } from 'sequelize';

export default function defineDiaryEntryModel(sequelize) {
  return sequelize.define(
    'DiaryEntry',
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
      text: {
        type: DataTypes.TEXT,
        allowNull: false,
      },
      mood: {
        type: DataTypes.ENUM('happy', 'sad', 'neutral'),
        allowNull: false,
      },
      tags: {
        type: DataTypes.ARRAY(DataTypes.STRING(50)),
        defaultValue: [],
        allowNull: true,
        comment: 'Category tags: finance, food, domestic, calendar',
      },
      emotion_score: {
        type: DataTypes.INTEGER,
        allowNull: false,
        comment: 'Auto-derived: happy=80, sad=20, neutral=50',
      },
      created_at: {
        type: DataTypes.DATE,
        defaultValue: DataTypes.NOW,
      },
      updated_at: {
        type: DataTypes.DATE,
        defaultValue: DataTypes.NOW,
      },
    },
    {
      tableName: 'diary_entries',
      timestamps: false,
      underscored: true,
    }
  );
}
