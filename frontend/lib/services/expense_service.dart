import 'api_service.dart';
import '../models/expense_model.dart';

class ExpenseService {
  final ApiService _apiService = ApiService();

  Future<List<ExpenseModel>> getExpenses(String token, {int? month, int? year}) async {
    String url = '/expenses';
    if (month != null && year != null) {
      url += '?month=$month&year=$year';
    }
    final response = await _apiService.get(url, token: token);
    final expenses = response['expenses'] as List<dynamic>? ?? [];
    return expenses.map((e) => ExpenseModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<ExpenseModel> getExpenseById(String token, int expenseId) async {
    final response = await _apiService.get('/expenses/$expenseId', token: token);
    return ExpenseModel.fromJson(response['expense'] as Map<String, dynamic>);
  }

  Future<double> getMonthlyTotal(String token, int month, int year) async {
    final response = await _apiService.get(
      '/expenses/monthly-total?month=$month&year=$year',
      token: token,
    );
    return double.parse((response['total'] ?? 0).toString());
  }

  Future<ExpenseModel> createExpense(
    String token,
    int categoryId,
    double amount,
    String description,
    DateTime expenseDate,
    int? accountId,
    String paymentMethod,
    String status,
    bool isRecurring,
    String? recurrenceType,
    String? tags,
  ) async {
    final response = await _apiService.post(
      '/expenses',
      {
        'category_id': categoryId,
        'amount': amount,
        'description': description,
        'expense_date': expenseDate.toIso8601String(),
        'account_id': accountId,
        'payment_method': paymentMethod,
        'status': status,
        'is_recurring': isRecurring,
        'recurrence_type': recurrenceType,
        'tags': tags,
      },
      token: token,
    );
    return ExpenseModel.fromJson(response['expense'] as Map<String, dynamic>);
  }

  Future<ExpenseModel> updateExpense(
    String token,
    int expenseId,
    int categoryId,
    double amount,
    String description,
    DateTime expenseDate,
    String paymentMethod,
    String status,
    String? tags,
  ) async {
    final response = await _apiService.put(
      '/expenses/$expenseId',
      {
        'category_id': categoryId,
        'amount': amount,
        'description': description,
        'expense_date': expenseDate.toIso8601String(),
        'payment_method': paymentMethod,
        'status': status,
        'tags': tags,
      },
      token: token,
    );
    return ExpenseModel.fromJson(response['expense'] as Map<String, dynamic>);
  }

  Future<void> deleteExpense(String token, int expenseId) async {
    await _apiService.delete('/expenses/$expenseId', token: token);
  }
}
