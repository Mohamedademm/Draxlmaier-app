import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../utils/constants.dart';

/// Base API service handling HTTP requests to the backend
class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final _storage = const FlutterSecureStorage();
  String? _token;

  /// Get the current authentication token
  Future<String?> getToken() async {
    _token ??= await _storage.read(key: StorageKeys.authToken);
    return _token;
  }

  /// Set the authentication token
  Future<void> setToken(String token) async {
    _token = token;
    await _storage.write(key: StorageKeys.authToken, value: token);
  }

  /// Clear the authentication token
  Future<void> clearToken() async {
    _token = null;
    await _storage.delete(key: StorageKeys.authToken);
  }

  /// Get default headers including authentication
  Future<Map<String, String>> _getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// GET request
  Future<http.Response> get(String endpoint) async {
    try {
      final headers = await _getHeaders();
      final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
      return await http.get(uri, headers: headers);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// POST request
  Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
    try {
      final headers = await _getHeaders();
      final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
      return await http.post(
        uri,
        headers: headers,
        body: json.encode(body),
      );
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// PUT request
  Future<http.Response> put(String endpoint, Map<String, dynamic> body) async {
    try {
      final headers = await _getHeaders();
      final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
      return await http.put(
        uri,
        headers: headers,
        body: json.encode(body),
      );
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// DELETE request
  Future<http.Response> delete(String endpoint) async {
    try {
      final headers = await _getHeaders();
      final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
      return await http.delete(uri, headers: headers);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Handle API response
  Map<String, dynamic> handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json.decode(response.body);
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized - Please login again');
    } else if (response.statusCode == 403) {
      throw Exception('Forbidden - You do not have permission');
    } else if (response.statusCode == 404) {
      throw Exception('Not found');
    } else if (response.statusCode >= 500) {
      throw Exception('Server error - Please try again later');
    } else {
      final body = json.decode(response.body);
      throw Exception(body['message'] ?? 'Request failed');
    }
  }
}
