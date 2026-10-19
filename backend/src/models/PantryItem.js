import { DataTypes } from 'sequelize';

export default function definePantryItemModel(sequelize) {
  return sequelize.define(
    'PantryItem',
    {
      id: {
        type: DataTypes.INTEGER,
        primaryKey: true,
        autoIncrement: true,
      },
      name: {
        type: DataTypes.STRING(100),
        allowNull: false,
      },
      emoji: {
        type: DataTypes.STRING(16),
        allowNull: false,
      },
      domain: {
        type: DataTypes.STRING(20),
        allowNull: false,
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
      tableName: 'pantry_items',
      timestamps: false,
      underscored: true,
    }
  );
}
