import { DataTypes } from 'sequelize';

export default function defineUserPantryModel(sequelize) {
  return sequelize.define(
    'UserPantry',
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
      item_id: {
        type: DataTypes.INTEGER,
        allowNull: false,
        references: {
          model: 'pantry_items',
          key: 'id',
        },
      },
      quantity: {
        type: DataTypes.INTEGER,
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
      tableName: 'user_pantry',
      timestamps: false,
      underscored: true,
    }
  );
}
