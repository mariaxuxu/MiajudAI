import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/installment_model.dart';
import 'api_service.dart';

class InstallmentService {
  final ApiService _apiService = ApiService();

  Future<List<InstallmentModel>> getInstallments(String token) async {
    final response = await _apiService.get('/installments', token: token);
    final installments = response['installments'] as List<dynamic>? ?? [];
    return installments.map((e) => InstallmentModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<InstallmentModel> getInstallmentById(String token, int id) async {
    final response = await _apiService.get('/installments/$id', token: token);
    return InstallmentModel.fromJson(response['installment'] as Map<String, dynamic>);
  }

  Future<InstallmentModel> createInstallment(String token, Map<String, dynamic> data) async {
    final response = await _apiService.post('/installments', data, token: token);
    return InstallmentModel.fromJson(response['installment'] as Map<String, dynamic>);
  }

  Future<InstallmentModel> updateInstallment(String token, int id, Map<String, dynamic> data) async {
    final response = await _apiService.put('/installments/$id', data, token: token);
    return InstallmentModel.fromJson(response['installment'] as Map<String, dynamic>);
  }

  Future<void> deleteInstallment(String token, int id) async {
    await _apiService.delete('/installments/$id', token: token);
  }

  Future<double> getMonthlyTotal(String token, {int? month, int? year}) async {
    String url = '/installments/monthly-total';
    if (month != null && year != null) {
      url += '?month=$month&year=$year';
    }
    final response = await _apiService.get(url, token: token);
    return double.parse((response['total'] ?? 0).toString());
  }
}
