import { DataTypes } from 'sequelize';

export default function defineCategoryModel(sequelize) {
  return sequelize.define(
    'Category',
    {
      id: {
        type: DataTypes.INTEGER,
        primaryKey: true,
        autoIncrement: true,
      },
      user_id: {
        type: DataTypes.INTEGER,
        allowNull: true,
        references: {
          model: 'users',
          key: 'id',
        },
      },
      name: {
        type: DataTypes.STRING(100),
        allowNull: false,
      },
      icon: {
        type: DataTypes.STRING(50),
        allowNull: true,
      },
      color: {
        type: DataTypes.STRING(7),
        allowNull: true,
      },
      is_default: {
        type: DataTypes.BOOLEAN,
        defaultValue: false,
      },
      created_at: {
        type: DataTypes.DATE,
        defaultValue: DataTypes.NOW,
      },
    },
    {
      tableName: 'categories',
      timestamps: false,
      underscored: true,
    }
  );
}
