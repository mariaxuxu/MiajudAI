import 'package:flutter/material.dart';
import '../models/account_model.dart';
import '../services/account_service.dart';

class AccountProvider extends ChangeNotifier {
  final AccountService _accountService = AccountService();

  List<AccountModel> _accounts = [];
  bool _isLoading = false;
  String? _error;

  List<AccountModel> get accounts => _accounts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  double get totalBalance => _accounts.fold(0, (sum, account) => sum + account.balance);

  void addToAccountBalance(int accountId, double amount) {
    final accountIndex = _accounts.indexWhere((a) => a.id == accountId);
    if (accountIndex != -1) {
      final account = _accounts[accountIndex];
      _accounts[accountIndex] = account.copyWith(balance: account.balance + amount);
      notifyListeners();
    }
  }

  void subtractFromAccountBalance(int accountId, double amount) {
    final accountIndex = _accounts.indexWhere((a) => a.id == accountId);
    if (accountIndex != -1) {
      final account = _accounts[accountIndex];
      _accounts[accountIndex] = account.copyWith(balance: account.balance - amount);
      notifyListeners();
    }
  }

  Future<void> loadAccounts(String token) async {
    _setLoading(true);
    _clearError();

    try {
      _accounts = await _accountService.getAccounts(token);
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  Future<void> addAccount(
    String token,
    String name,
    String type,
    String? bankName,
    String? accountNumber,
  ) async {
    _setLoading(true);
    _clearError();

    try {
      final account = await _accountService.createAccount(
        token,
        name,
        type,
        bankName,
        accountNumber,
      );
      _accounts.add(account);
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  Future<void> updateAccount(
    String token,
    int accountId,
    String name,
    String type,
    String? bankName,
    String? accountNumber,
  ) async {
    _setLoading(true);
    _clearError();

    try {
      final updatedAccount = await _accountService.updateAccount(
        token,
        accountId,
        name,
        type,
        bankName,
        accountNumber,
      );
      final index = _accounts.indexWhere((a) => a.id == accountId);
      if (index != -1) {
        _accounts[index] = updatedAccount;
      }
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  Future<void> removeAccount(String token, int accountId) async {
    _setLoading(true);
    _clearError();

    try {
      await _accountService.deleteAccount(token, accountId);
      _accounts.removeWhere((a) => a.id == accountId);
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
  }

  void _setError(String error) {
    _error = error;
  }

  void _clearError() {
    _error = null;
  }
}
