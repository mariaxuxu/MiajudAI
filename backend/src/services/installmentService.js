import { getDatabase } from '../config/database.js';

const devInstallments = {};
let nextId = 1;

class InstallmentService {
  async getInstallmentsByUserId(userId, isActive = true) {
    try {
      const { Installment } = getDatabase();
      const where = { user_id: userId };
      if (isActive) where.is_active = true;
      return Installment.findAll({ where, order: [['due_day_of_month', 'ASC']] });
    } catch (e) {
      return Object.values(devInstallments)
        .filter((i) => i.user_id === userId && (!isActive || i.is_active))
        .sort((a, b) => a.due_day_of_month - b.due_day_of_month);
    }
  }

  async getInstallmentById(id, userId) {
    try {
      const { Installment } = getDatabase();
      return Installment.findOne({ where: { id, user_id: userId } });
    } catch (e) {
      return devInstallments[id] || null;
    }
  }

  async createInstallment(userId, data) {
    try {
      const { Installment } = getDatabase();
      const installmentValue = (data.total_amount / data.total_installments).toFixed(2);
      return Installment.create({
        user_id: userId,
        name: data.name,
        total_amount: data.total_amount,
        total_installments: data.total_installments,
        installment_value: parseFloat(installmentValue),
        due_day_of_month: data.due_day_of_month,
        start_date: data.start_date,
        description: data.description || null,
        is_active: true,
      });
    } catch (e) {
      const id = nextId++;
      const installmentValue = (data.total_amount / data.total_installments).toFixed(2);
      const inst = {
        id,
        user_id: userId,
        name: data.name,
        total_amount: data.total_amount,
        total_installments: data.total_installments,
        installment_value: parseFloat(installmentValue),
        due_day_of_month: data.due_day_of_month,
        start_date: new Date(data.start_date),
        description: data.description || null,
        is_active: true,
        created_at: new Date(),
      };
      devInstallments[id] = inst;
      return inst;
    }
  }

  async updateInstallment(id, userId, data) {
    const { Installment } = getDatabase();
    const installment = await this.getInstallmentById(id, userId);
    if (!installment) throw new Error('Installment not found');

    const updateData = {
      name: data.name ?? installment.name,
      total_amount: data.total_amount ?? installment.total_amount,
      total_installments: data.total_installments ?? installment.total_installments,
      due_day_of_month: data.due_day_of_month ?? installment.due_day_of_month,
      start_date: data.start_date ?? installment.start_date,
      description: data.description ?? installment.description,
    };

    if (data.total_amount || data.total_installments) {
      const totalAmount = data.total_amount ?? installment.total_amount;
      const totalInstallments = data.total_installments ?? installment.total_installments;
      updateData.installment_value = (totalAmount / totalInstallments).toFixed(2);
    }

    await installment.update(updateData);
    return installment;
  }

  async deleteInstallment(id, userId) {
    try {
      const { Installment } = getDatabase();
      const installment = await Installment.findOne({ where: { id, user_id: userId } });
      if (!installment) throw new Error('Installment not found');
      await installment.destroy();
    } catch (e) {
      if (devInstallments[id]) {
        delete devInstallments[id];
      } else {
        throw new Error('Installment not found');
      }
    }
  }

  async getTotalForMonth(userId, month, year) {
    const installments = await this.getInstallmentsByUserId(userId);
    let total = 0;

    installments.forEach((inst) => {
      const startDate = new Date(inst.start_date);
      const startMonth = startDate.getMonth() + 1;
      const startYear = startDate.getFullYear();

      const monthsDiff = (year - startYear) * 12 + (month - startMonth);
      const isActiveInMonth = monthsDiff >= 0 && monthsDiff < inst.total_installments;

      if (isActiveInMonth) {
        total += parseFloat(inst.installment_value);
      }
    });

    return total;
  }
}

export default new InstallmentService();
