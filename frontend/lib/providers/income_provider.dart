import 'package:flutter/material.dart';
import '../models/income_model.dart';
import '../services/income_service.dart';

class IncomeProvider extends ChangeNotifier {
  final IncomeService _incomeService = IncomeService();

  List<IncomeModel> _income = [];
  double _monthlyTotal = 0;
  bool _isLoading = false;
  String? _error;

  List<IncomeModel> get income => _income;
  double get monthlyTotal => _monthlyTotal;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadIncome(String token, {int? month, int? year}) async {
    _setLoading(true);
    _clearError();

    try {
      _income = await _incomeService.getIncome(token, month: month, year: year);

      if (month != null && year != null) {
        _monthlyTotal = await _incomeService.getMonthlyTotal(token, month, year);
      } else {
        _monthlyTotal = _income.fold(0, (sum, item) => sum + item.amount);
      }

      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  Future<void> addIncome(
    String token,
    double amount,
    String description,
    String type,
    DateTime incomeDate,
    int? accountId,
    bool isRecurring,
    String? recurrenceType,
  ) async {
    _setLoading(true);
    _clearError();

    try {
      final newIncome = await _incomeService.createIncome(
        token,
        amount,
        description,
        type,
        incomeDate,
        accountId,
        isRecurring,
        recurrenceType,
      );
      _income.add(newIncome);
      _monthlyTotal += amount;
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  void updateAccountBalance(int? accountId, double amount, {bool isAdding = true}) {
    if (accountId == null) return;
    if (isAdding) {
      // Will be called from screen after income is added
    }
  }

  Future<void> updateIncome(
    String token,
    int incomeId,
    double amount,
    String description,
    String type,
    DateTime incomeDate,
  ) async {
    _setLoading(true);
    _clearError();

    try {
      final oldIncome = _income.firstWhere((i) => i.id == incomeId);
      final updatedIncome = await _incomeService.updateIncome(
        token,
        incomeId,
        amount,
        description,
        type,
        incomeDate,
      );

      final index = _income.indexWhere((i) => i.id == incomeId);
      if (index != -1) {
        _monthlyTotal -= oldIncome.amount;
        _income[index] = updatedIncome;
        _monthlyTotal += updatedIncome.amount;
      }

      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  Future<void> removeIncome(String token, int incomeId) async {
    _setLoading(true);
    _clearError();

    try {
      final incomeToRemove = _income.firstWhere((i) => i.id == incomeId);
      await _incomeService.deleteIncome(token, incomeId);
      _income.removeWhere((i) => i.id == incomeId);
      _monthlyTotal -= incomeToRemove.amount;
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
