import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../utils/constants.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final _storage = const FlutterSecureStorage();
  String? _token;

  Future<String?> getToken() async {
    _token ??= await _storage.read(key: StorageKeys.authToken);
    return _token;
  }

  Future<void> setToken(String token) async {
    _token = token;
    await _storage.write(key: StorageKeys.authToken, value: token);
  }

  Future<void> clearToken() async {
    _token = null;
    await _storage.delete(key: StorageKeys.authToken);
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<http.Response> get(String endpoint, {Map<String, String>? queryParams}) async {
    try {
      final headers = await _getHeaders();
      var uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
      if (queryParams != null && queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParams);
      }
      return await http.get(uri, headers: headers);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

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

  Future<http.Response> delete(String endpoint) async {
    try {
      final headers = await _getHeaders();
      final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
      return await http.delete(uri, headers: headers);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Map<String, dynamic> handleResponse(http.Response response) {
    try {
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return json.decode(response.body);
      }
      
      String errorMessage = 'Request failed';
      try {
        final body = json.decode(response.body);
        errorMessage = body['message'] ?? body['error'] ?? errorMessage;
      } catch (e) {
      }
      
      if (response.statusCode == 401) {
        throw Exception('Session expirée - Veuillez vous reconnecter');
      } else if (response.statusCode == 403) {
        throw Exception('Accès refusé - Permissions insuffisantes');
      } else if (response.statusCode == 404) {
        throw Exception('Ressource introuvable');
      } else if (response.statusCode == 400) {
        throw Exception('Requête invalide: $errorMessage');
      } else if (response.statusCode >= 500) {
        throw Exception('Erreur serveur - Veuillez réessayer plus tard');
      } else {
        throw Exception(errorMessage);
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Erreur de traitement de la réponse: $e');
    }
  }
}
