import { getDatabase } from '../config/database.js';

const devFixedCosts = {};
let nextId = 1;

class FixedCostService {
  async getFixedCostsByUserId(userId, isActive = true) {
    try {
      const { FixedCost } = getDatabase();
      const where = { user_id: userId };
      if (isActive) where.is_active = true;
      return FixedCost.findAll({ where, order: [['due_day_of_month', 'ASC']] });
    } catch (e) {
      return Object.values(devFixedCosts)
        .filter((f) => f.user_id === userId && (!isActive || f.is_active))
        .sort((a, b) => a.due_day_of_month - b.due_day_of_month);
    }
  }

  async getFixedCostById(id, userId) {
    try {
      const { FixedCost } = getDatabase();
      return FixedCost.findOne({ where: { id, user_id: userId } });
    } catch (e) {
      return devFixedCosts[id] || null;
    }
  }

  async createFixedCost(userId, data) {
    try {
      const { FixedCost } = getDatabase();
      return FixedCost.create({
        user_id: userId,
        name: data.name,
        amount: data.amount,
        due_day_of_month: data.due_day_of_month,
        category: data.category || 'other',
        description: data.description || null,
        is_active: true,
      });
    } catch (e) {
      const id = nextId++;
      const cost = {
        id,
        user_id: userId,
        name: data.name,
        amount: data.amount,
        due_day_of_month: data.due_day_of_month,
        category: data.category || 'other',
        description: data.description || null,
        is_active: true,
        created_at: new Date(),
      };
      devFixedCosts[id] = cost;
      return cost;
    }
  }

  async updateFixedCost(id, userId, data) {
    const { FixedCost } = getDatabase();
    const fixedCost = await this.getFixedCostById(id, userId);
    if (!fixedCost) throw new Error('Fixed cost not found');

    await fixedCost.update({
      name: data.name ?? fixedCost.name,
      amount: data.amount ?? fixedCost.amount,
      due_day_of_month: data.due_day_of_month ?? fixedCost.due_day_of_month,
      category: data.category ?? fixedCost.category,
      description: data.description ?? fixedCost.description,
    });

    return fixedCost;
  }

  async deleteFixedCost(id, userId) {
    try {
      const { FixedCost } = getDatabase();
      const fixedCost = await FixedCost.findOne({ where: { id, user_id: userId } });
      if (!fixedCost) throw new Error('Fixed cost not found');
      await fixedCost.destroy();
    } catch (e) {
      if (devFixedCosts[id]) {
        delete devFixedCosts[id];
      } else {
        throw new Error('Fixed cost not found');
      }
    }
  }

  async getTotalForMonth(userId) {
    const fixedCosts = await this.getFixedCostsByUserId(userId);
    return fixedCosts.reduce((sum, cost) => sum + parseFloat(cost.amount), 0);
  }
}

export default new FixedCostService();
