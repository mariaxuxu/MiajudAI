import 'api_service.dart';
import '../models/income_model.dart';

class IncomeService {
  final ApiService _apiService = ApiService();

  Future<List<IncomeModel>> getIncome(String token, {int? month, int? year}) async {
    String url = '/income';
    if (month != null && year != null) {
      url += '?month=$month&year=$year';
    }
    final response = await _apiService.get(url, token: token);
    final income = response['income'] as List<dynamic>? ?? [];
    return income.map((i) => IncomeModel.fromJson(i as Map<String, dynamic>)).toList();
  }

  Future<IncomeModel> getIncomeById(String token, int incomeId) async {
    final response = await _apiService.get('/income/$incomeId', token: token);
    return IncomeModel.fromJson(response['income'] as Map<String, dynamic>);
  }

  Future<double> getMonthlyTotal(String token, int month, int year) async {
    final response = await _apiService.get(
      '/income/monthly-total?month=$month&year=$year',
      token: token,
    );
    return double.parse((response['total'] ?? 0).toString());
  }

  Future<IncomeModel> createIncome(
    String token,
    double amount,
    String description,
    String type,
    DateTime incomeDate,
    int? accountId,
    bool isRecurring,
    String? recurrenceType,
  ) async {
    final response = await _apiService.post(
      '/income',
      {
        'amount': amount,
        'description': description,
        'type': type,
        'income_date': incomeDate.toIso8601String(),
        'account_id': accountId,
        'is_recurring': isRecurring,
        'recurrence_type': recurrenceType,
      },
      token: token,
    );
    return IncomeModel.fromJson(response['income'] as Map<String, dynamic>);
  }

  Future<IncomeModel> updateIncome(
    String token,
    int incomeId,
    double amount,
    String description,
    String type,
    DateTime incomeDate,
  ) async {
    final response = await _apiService.put(
      '/income/$incomeId',
      {
        'amount': amount,
        'description': description,
        'type': type,
        'income_date': incomeDate.toIso8601String(),
      },
      token: token,
    );
    return IncomeModel.fromJson(response['income'] as Map<String, dynamic>);
  }

  Future<void> deleteIncome(String token, int incomeId) async {
    await _apiService.delete('/income/$incomeId', token: token);
  }
}
