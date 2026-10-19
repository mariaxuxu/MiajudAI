import { DataTypes } from 'sequelize';

// Global pantry catalog, shared by every user and extensible by any of them.
// `domain` reuses the vocabulary already present in userActivityService's
// ALLOWED_TAGS and the agent→tag map (otto→food, tina→domestic).
const catalogItems = [
  // Cozinha (food)
  { name: 'Arroz', emoji: '🍚', domain: 'food' },
  { name: 'Feijão', emoji: '🫘', domain: 'food' },
  { name: 'Macarrão', emoji: '🍝', domain: 'food' },
  { name: 'Óleo', emoji: '🫗', domain: 'food' },
  { name: 'Açúcar', emoji: '🍬', domain: 'food' },
  { name: 'Sal', emoji: '🧂', domain: 'food' },
  { name: 'Café', emoji: '☕', domain: 'food' },
  { name: 'Leite', emoji: '🥛', domain: 'food' },
  { name: 'Ovos', emoji: '🥚', domain: 'food' },
  { name: 'Pão', emoji: '🍞', domain: 'food' },
  { name: 'Manteiga', emoji: '🧈', domain: 'food' },
  { name: 'Queijo', emoji: '🧀', domain: 'food' },
  { name: 'Farinha', emoji: '🌾', domain: 'food' },
  { name: 'Molho de tomate', emoji: '🥫', domain: 'food' },
  { name: 'Frango', emoji: '🍗', domain: 'food' },
  { name: 'Carne', emoji: '🥩', domain: 'food' },
  { name: 'Peixe', emoji: '🐟', domain: 'food' },
  { name: 'Tomate', emoji: '🍅', domain: 'food' },
  { name: 'Cebola', emoji: '🧅', domain: 'food' },
  { name: 'Alho', emoji: '🧄', domain: 'food' },
  { name: 'Batata', emoji: '🥔', domain: 'food' },
  { name: 'Cenoura', emoji: '🥕', domain: 'food' },
  { name: 'Alface', emoji: '🥬', domain: 'food' },
  { name: 'Banana', emoji: '🍌', domain: 'food' },
  { name: 'Maçã', emoji: '🍎', domain: 'food' },
  { name: 'Laranja', emoji: '🍊', domain: 'food' },
  { name: 'Suco', emoji: '🧃', domain: 'food' },
  { name: 'Refrigerante', emoji: '🥤', domain: 'food' },
  // Doméstico (domestic)
  { name: 'Detergente', emoji: '🧴', domain: 'domestic' },
  { name: 'Sabão em pó', emoji: '🧺', domain: 'domestic' },
  { name: 'Amaciante', emoji: '🌸', domain: 'domestic' },
  { name: 'Água sanitária', emoji: '🧪', domain: 'domestic' },
  { name: 'Desinfetante', emoji: '🧼', domain: 'domestic' },
  { name: 'Papel higiênico', emoji: '🧻', domain: 'domestic' },
  { name: 'Papel toalha', emoji: '🧻', domain: 'domestic' },
  { name: 'Esponja', emoji: '🧽', domain: 'domestic' },
  { name: 'Sabonete', emoji: '🧼', domain: 'domestic' },
  { name: 'Creme dental', emoji: '🪥', domain: 'domestic' },
  { name: 'Xampu', emoji: '🧴', domain: 'domestic' },
  { name: 'Saco de lixo', emoji: '🗑️', domain: 'domestic' },
];

export async function up({ context: sequelize }) {
  const queryInterface = sequelize.getQueryInterface();
  const now = new Date();

  // Global catalog — deliberately has no user_id: it is shared across users.
  await queryInterface.createTable('pantry_items', {
    id: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
    name: { type: DataTypes.STRING(100), allowNull: false },
    emoji: { type: DataTypes.STRING(16), allowNull: false },
    domain: { type: DataTypes.STRING(20), allowNull: false },
    created_at: { type: DataTypes.DATE, allowNull: false, defaultValue: DataTypes.NOW },
    updated_at: { type: DataTypes.DATE, allowNull: false, defaultValue: DataTypes.NOW },
  });

  // A user's pantry. quantity is a pack count with no unit of measure;
  // quantity 0 is represented by the absence of a row, never by a zeroed row.
  await queryInterface.createTable('user_pantry', {
    id: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
    user_id: {
      type: DataTypes.INTEGER,
      allowNull: false,
      references: { model: 'users', key: 'id' },
      onDelete: 'CASCADE',
    },
    item_id: {
      type: DataTypes.INTEGER,
      allowNull: false,
      references: { model: 'pantry_items', key: 'id' },
      onDelete: 'CASCADE',
    },
    quantity: { type: DataTypes.INTEGER, allowNull: false },
    created_at: { type: DataTypes.DATE, allowNull: false, defaultValue: DataTypes.NOW },
    updated_at: { type: DataTypes.DATE, allowNull: false, defaultValue: DataTypes.NOW },
  });

  await sequelize.query(
    'ALTER TABLE user_pantry ADD CONSTRAINT user_pantry_quantity_positive CHECK (quantity > 0);'
  );
  await sequelize.query(
    'ALTER TABLE user_pantry ADD CONSTRAINT user_pantry_user_item_key UNIQUE (user_id, item_id);'
  );
  await queryInterface.addIndex('user_pantry', ['user_id'], {
    name: 'idx_user_pantry_user',
  });

  await queryInterface.bulkInsert(
    'pantry_items',
    catalogItems.map((item) => ({
      ...item,
      created_at: now,
      updated_at: now,
    }))
  );
}

export async function down({ context: sequelize }) {
  const queryInterface = sequelize.getQueryInterface();

  await queryInterface.dropTable('user_pantry');
  await queryInterface.dropTable('pantry_items');
}
