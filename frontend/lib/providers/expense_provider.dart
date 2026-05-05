import 'package:flutter/material.dart';
import '../models/expense_model.dart';
import '../services/expense_service.dart';

class ExpenseProvider extends ChangeNotifier {
  final ExpenseService _expenseService = ExpenseService();

  List<ExpenseModel> _expenses = [];
  double _monthlyTotal = 0;
  bool _isLoading = false;
  String? _error;

  List<ExpenseModel> get expenses => _expenses;
  double get monthlyTotal => _monthlyTotal;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadExpenses(String token, {int? month, int? year}) async {
    _setLoading(true);
    _clearError();

    try {
      _expenses = await _expenseService.getExpenses(token, month: month, year: year);

      if (month != null && year != null) {
        _monthlyTotal = await _expenseService.getMonthlyTotal(token, month, year);
      } else {
        _monthlyTotal = _expenses.fold(0, (sum, item) => sum + item.amount);
      }

      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  Future<void> addExpense(
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
    _setLoading(true);
    _clearError();

    try {
      final newExpense = await _expenseService.createExpense(
        token,
        categoryId,
        amount,
        description,
        expenseDate,
        accountId,
        paymentMethod,
        status,
        isRecurring,
        recurrenceType,
        tags,
      );
      _expenses.add(newExpense);
      _monthlyTotal += amount;
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  Future<void> updateExpense(
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
    _setLoading(true);
    _clearError();

    try {
      final oldExpense = _expenses.firstWhere((e) => e.id == expenseId);
      final updatedExpense = await _expenseService.updateExpense(
        token,
        expenseId,
        categoryId,
        amount,
        description,
        expenseDate,
        paymentMethod,
        status,
        tags,
      );

      final index = _expenses.indexWhere((e) => e.id == expenseId);
      if (index != -1) {
        _monthlyTotal -= oldExpense.amount;
        _expenses[index] = updatedExpense;
        _monthlyTotal += updatedExpense.amount;
      }

      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  Future<void> removeExpense(String token, int expenseId) async {
    _setLoading(true);
    _clearError();

    try {
      final expenseToRemove = _expenses.firstWhere((e) => e.id == expenseId);
      await _expenseService.deleteExpense(token, expenseId);
      _expenses.removeWhere((e) => e.id == expenseId);
      _monthlyTotal -= expenseToRemove.amount;
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  List<ExpenseModel> getExpensesByCategory(int categoryId) {
    return _expenses.where((e) => e.categoryId == categoryId).toList();
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
