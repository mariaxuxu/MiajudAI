import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/constants.dart';

class ApiService {
  late final String baseUrl;

  ApiService() {
    baseUrl = ApiConfig.baseUrl;
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
      print('DEBUG API: Headers: $headers');
      print('DEBUG API: Body size: ${jsonEncode(data).length} bytes');

      final startTime = DateTime.now();
      final response = await http
          .post(
            Uri.parse(url),
            headers: headers,
            body: jsonEncode(data),
          )
          .timeout(const Duration(milliseconds: ApiConfig.connectionTimeout));

      final elapsed = DateTime.now().difference(startTime);
      print('DEBUG API: Response received in ${elapsed.inMilliseconds}ms');
      print('DEBUG API: Response status: ${response.statusCode}');
      print('DEBUG API: Response body (first 200 chars): ${response.body.substring(0, minOf(200, response.body.length))}');
      return _handleResponse(response);
    } catch (e) {
      print('DEBUG API ERROR: POST failed - $e');
      print('DEBUG API ERROR: Error type: ${e.runtimeType}');
      print('DEBUG API ERROR: Stack trace: $e');
      rethrow;
    }
  }

  int minOf(int a, int b) => a < b ? a : b;

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
