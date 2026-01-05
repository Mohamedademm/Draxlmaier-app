import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/objective_model.dart';
import '../utils/constants.dart';
import 'api_service.dart';

/// Service for objective statistics and bulk operations
class ObjectiveStatsService {
  final String baseUrl = '${ApiConstants.baseUrl}/objectives';
  final ApiService _apiService = ApiService();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _apiService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Get objectives statistics
  Future<Map<String, dynamic>> getStats() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/stats/overview'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['stats'];
      } else {
        throw Exception('Failed to load statistics');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  /// Bulk update objectives
  Future<void> bulkUpdate({
    required List<String> objectiveIds,
    required Map<String, dynamic> updates,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/bulk-update'),
        headers: headers,
        body: json.encode({
          'objectiveIds': objectiveIds,
          'updates': updates,
        }),
      );

      if (response.statusCode != 200) {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Bulk update failed');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  /// Bulk delete objectives
  Future<void> bulkDelete(List<String> objectiveIds) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/bulk-delete'),
        headers: headers,
        body: json.encode({
          'objectiveIds': objectiveIds,
        }),
      );

      if (response.statusCode != 200) {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Bulk delete failed');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
