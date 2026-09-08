import 'package:flutter/material.dart';
import '../models/installment_model.dart';
import '../services/installment_service.dart';

class InstallmentProvider extends ChangeNotifier {
  final InstallmentService _installmentService = InstallmentService();

  List<InstallmentModel> _installments = [];
  bool _isLoading = false;
  String? _error;

  List<InstallmentModel> get installments => _installments;
  bool get isLoading => _isLoading;
  String? get error => _error;

  double get monthlyTotal => _installments
      .where((i) => i.isActive)
      .fold(0, (sum, i) => sum + i.installmentValue);

  double getMonthlyTotal(DateTime month) {
    return _installments
        .where((i) => i.isActive && _isInstallmentActiveInMonth(i, month))
        .fold(0, (sum, i) => sum + i.installmentValue);
  }

  bool _isInstallmentActiveInMonth(InstallmentModel inst, DateTime month) {
    final startDate = inst.startDate;
    final monthsDiff = (month.year - startDate.year) * 12 + (month.month - startDate.month);
    return monthsDiff >= 0 && monthsDiff < inst.totalInstallments;
  }

  Future<void> loadInstallments(String token) async {
    _setLoading(true);
    _clearError();
    try {
      _installments = await _installmentService.getInstallments(token);
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  Future<void> addInstallment(String token, {
    required String name,
    required double totalAmount,
    required int totalInstallments,
    required int dueDayOfMonth,
    required DateTime startDate,
    String? description,
    String paymentMethod = 'credit_card',
    String? merchantName,
  }) async {
    try {
      final installment = await _installmentService.createInstallment(token, {
        'name': name,
        'total_amount': totalAmount,
        'total_installments': totalInstallments,
        'due_day_of_month': dueDayOfMonth,
        'start_date': startDate.toIso8601String(),
        'description': description,
        'payment_method': paymentMethod,
        'merchant_name': merchantName,
      });
      _installments.add(installment);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
      rethrow;
    }
  }

  Future<void> updateInstallment(String token, int id, {
    String? name,
    double? totalAmount,
    int? totalInstallments,
    int? dueDayOfMonth,
    DateTime? startDate,
    String? description,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (totalAmount != null) data['total_amount'] = totalAmount;
      if (totalInstallments != null) data['total_installments'] = totalInstallments;
      if (dueDayOfMonth != null) data['due_day_of_month'] = dueDayOfMonth;
      if (startDate != null) data['start_date'] = startDate.toIso8601String();
      if (description != null) data['description'] = description;

      final updated = await _installmentService.updateInstallment(token, id, data);
      final idx = _installments.indexWhere((i) => i.id == id);
      if (idx >= 0) {
        _installments[idx] = updated;
        notifyListeners();
      }
    } catch (e) {
      _setError(e.toString());
      rethrow;
    }
  }

  Future<void> removeInstallment(String token, int id) async {
    try {
      await _installmentService.deleteInstallment(token, id);
      _installments.removeWhere((i) => i.id == id);
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
