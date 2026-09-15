import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/fixed_cost_model.dart';
import 'api_service.dart';

class FixedCostService {
  final ApiService _apiService = ApiService();

  Future<List<FixedCostModel>> getFixedCosts(String token) async {
    final response = await _apiService.get('/fixed-costs', token: token);
    final fixedCosts = response['fixedCosts'] as List<dynamic>? ?? [];
    return fixedCosts.map((e) => FixedCostModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<FixedCostModel> getFixedCostById(String token, int id) async {
    final response = await _apiService.get('/fixed-costs/$id', token: token);
    return FixedCostModel.fromJson(response['fixedCost'] as Map<String, dynamic>);
  }

  Future<FixedCostModel> createFixedCost(String token, Map<String, dynamic> data) async {
    final response = await _apiService.post('/fixed-costs', data, token: token);
    return FixedCostModel.fromJson(response['fixedCost'] as Map<String, dynamic>);
  }

  Future<FixedCostModel> updateFixedCost(String token, int id, Map<String, dynamic> data) async {
    final response = await _apiService.put('/fixed-costs/$id', data, token: token);
    return FixedCostModel.fromJson(response['fixedCost'] as Map<String, dynamic>);
  }

  Future<void> deleteFixedCost(String token, int id) async {
    await _apiService.delete('/fixed-costs/$id', token: token);
  }

  Future<double> getMonthlyTotal(String token) async {
    final response = await _apiService.get('/fixed-costs/monthly-total', token: token);
    return double.parse((response['total'] ?? 0).toString());
  }
}
