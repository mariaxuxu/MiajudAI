import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/constants.dart';

class ApiService {
  final String baseUrl = ApiConfig.baseUrl;

  ApiService() {
    print('DEBUG: ApiService initialized with baseUrl: $baseUrl');
  }

  Future<dynamic> get(String endpoint, {String? token}) async {
    try {
      final headers = _buildHeaders(token);
      final url = '$baseUrl$endpoint';
      print('DEBUG API: GET $url');
      final response = await http
          .get(
            Uri.parse(url),
            headers: headers,
          )
          .timeout(const Duration(milliseconds: ApiConfig.connectionTimeout));

      return _handleResponse(response);
    } catch (e) {
      print('DEBUG API ERROR: Request failed - $e');
      rethrow;
    }
  }

  Future<dynamic> post(String endpoint, dynamic data, {String? token}) async {
    try {
      final headers = _buildHeaders(token);
      final url = '$baseUrl$endpoint';
      print('DEBUG API: POST $url');
      print('DEBUG API: Body: ${jsonEncode(data)}');
      final response = await http
          .post(
            Uri.parse(url),
            headers: headers,
            body: jsonEncode(data),
          )
          .timeout(const Duration(milliseconds: ApiConfig.connectionTimeout));

      print('DEBUG API: Response status: ${response.statusCode}');
      return _handleResponse(response);
    } catch (e) {
      print('DEBUG API ERROR: POST failed - $e');
      rethrow;
    }
  }

  Future<dynamic> put(String endpoint, dynamic data, {String? token}) async {
    try {
      final headers = _buildHeaders(token);
      final response = await http
          .put(
            Uri.parse('$baseUrl$endpoint'),
            headers: headers,
            body: jsonEncode(data),
          )
          .timeout(const Duration(milliseconds: ApiConfig.connectionTimeout));

      return _handleResponse(response);
    } catch (e) {
      print('DEBUG API ERROR: Request failed - $e');
      rethrow;
    }
  }

  Future<dynamic> delete(String endpoint, {String? token}) async {
    try {
      final headers = _buildHeaders(token);
      final response = await http
          .delete(
            Uri.parse('$baseUrl$endpoint'),
            headers: headers,
          )
          .timeout(const Duration(milliseconds: ApiConfig.connectionTimeout));

      return _handleResponse(response);
    } catch (e) {
      print('DEBUG API ERROR: Request failed - $e');
      rethrow;
    }
  }

  Map<String, String> _buildHeaders(String? token) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized');
    } else if (response.statusCode == 404) {
      throw Exception('Not found');
    } else {
      throw Exception('Error: ${response.statusCode}');
    }
  }
}
