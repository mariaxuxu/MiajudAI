import { DataTypes } from 'sequelize';

export default function definePantryCommitModel(sequelize) {
  return sequelize.define(
    'PantryCommit',
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
      commit_key: {
        type: DataTypes.UUID,
        allowNull: false,
      },
      created_at: {
        type: DataTypes.DATE,
        defaultValue: DataTypes.NOW,
      },
    },
    {
      tableName: 'pantry_commits',
      timestamps: false,
      underscored: true,
    }
  );
}
