import 'api_service.dart';
import '../models/account_model.dart';

class AccountService {
  final ApiService _apiService = ApiService();

  Future<List<AccountModel>> getAccounts(String token) async {
    final response = await _apiService.get('/accounts', token: token);
    final accounts = response['accounts'] as List<dynamic>? ?? [];
    return accounts.map((a) => AccountModel.fromJson(a as Map<String, dynamic>)).toList();
  }

  Future<AccountModel> getAccountById(String token, int accountId) async {
    final response = await _apiService.get('/accounts/$accountId', token: token);
    return AccountModel.fromJson(response['account'] as Map<String, dynamic>);
  }

  Future<AccountModel> createAccount(
    String token,
    String name,
    String type,
    String? bankName,
    String? accountNumber,
  ) async {
    final response = await _apiService.post(
      '/accounts',
      {
        'name': name,
        'type': type,
        'bank_name': bankName,
        'account_number': accountNumber,
      },
      token: token,
    );
    return AccountModel.fromJson(response['account'] as Map<String, dynamic>);
  }

  Future<AccountModel> updateAccount(
    String token,
    int accountId,
    String name,
    String type,
    String? bankName,
    String? accountNumber,
  ) async {
    final response = await _apiService.put(
      '/accounts/$accountId',
      {
        'name': name,
        'type': type,
        'bank_name': bankName,
        'account_number': accountNumber,
      },
      token: token,
    );
    return AccountModel.fromJson(response['account'] as Map<String, dynamic>);
  }

  Future<void> deleteAccount(String token, int accountId) async {
    await _apiService.delete('/accounts/$accountId', token: token);
  }
}
