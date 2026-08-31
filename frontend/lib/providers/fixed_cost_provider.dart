import 'package:flutter/material.dart';
import '../models/fixed_cost_model.dart';
import '../services/fixed_cost_service.dart';

class FixedCostProvider extends ChangeNotifier {
  final FixedCostService _fixedCostService = FixedCostService();

  List<FixedCostModel> _fixedCosts = [];
  bool _isLoading = false;
  String? _error;

  List<FixedCostModel> get fixedCosts => _fixedCosts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  double get monthlyTotal => _fixedCosts
      .where((f) => f.isActive)
      .fold(0, (sum, f) => sum + f.amount);

  List<FixedCostModel> getFixedCostsForMonth(DateTime month) {
    return _fixedCosts
        .where((f) => f.isActive && f.createdAt.year <= month.year && (f.createdAt.year < month.year || f.createdAt.month <= month.month))
        .toList();
  }

  double getMonthlyTotal(DateTime month) {
    return getFixedCostsForMonth(month)
        .fold(0, (sum, f) => sum + f.amount);
  }

  Future<void> loadFixedCosts(String token) async {
    _setLoading(true);
    _clearError();
    try {
      _fixedCosts = await _fixedCostService.getFixedCosts(token);
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  Future<void> addFixedCost(String token, {
    required String name,
    required double amount,
    required int dueDayOfMonth,
    required String category,
    String? description,
  }) async {
    try {
      final fixedCost = await _fixedCostService.createFixedCost(token, {
        'name': name,
        'amount': amount,
        'due_day_of_month': dueDayOfMonth,
        'category': category,
        'description': description,
      });
      _fixedCosts.add(fixedCost);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
      rethrow;
    }
  }

  Future<void> updateFixedCost(String token, int id, {
    String? name,
    double? amount,
    int? dueDayOfMonth,
    String? category,
    String? description,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (amount != null) data['amount'] = amount;
      if (dueDayOfMonth != null) data['due_day_of_month'] = dueDayOfMonth;
      if (category != null) data['category'] = category;
      if (description != null) data['description'] = description;

      final updated = await _fixedCostService.updateFixedCost(token, id, data);
      final idx = _fixedCosts.indexWhere((f) => f.id == id);
      if (idx >= 0) {
        _fixedCosts[idx] = updated;
        notifyListeners();
      }
    } catch (e) {
      _setError(e.toString());
      rethrow;
    }
  }

  Future<void> removeFixedCost(String token, int id) async {
    try {
      await _fixedCostService.deleteFixedCost(token, id);
      _fixedCosts.removeWhere((f) => f.id == id);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
      rethrow;
    }
  }

  void _setLoading(bool v) => _isLoading = v;
  void _setError(String e) => _error = e;
  void _clearError() => _error = null;
}
