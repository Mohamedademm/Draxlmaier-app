import 'dart:convert';

import 'package:http/http.dart' as http;
import '../models/objective_model.dart';
import '../utils/constants.dart';
import 'api_service.dart';

class ObjectiveService {
  final String baseUrl = '${ApiConstants.baseUrl}/objectives';
  final ApiService _apiService = ApiService();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _apiService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<Objective>> getMyObjectives({
    String? status,
    String? priority,
  }) async {
    try {
      final headers = await _getHeaders();
      var url = '$baseUrl/my-objectives';
      
      final queryParams = <String, String>{};
      if (status != null) queryParams['status'] = status;
      if (priority != null) queryParams['priority'] = priority;
      
      if (queryParams.isNotEmpty) {
        url += '?${queryParams.entries.map((e) => '${e.key}=${e.value}').join('&')}';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final objectives = (data['objectives'] as List)
            .map((obj) => Objective.fromJson(obj))
            .toList();
        return objectives;
      } else {
        throw Exception('Erreur lors de la récupération des objectifs');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<List<Objective>> getTeamObjectives({
    String? teamId,
    String? status,
  }) async {
    try {
      final headers = await _getHeaders();
      var url = '$baseUrl/team/all';
      
      final queryParams = <String, String>{};
      if (teamId != null) queryParams['team'] = teamId;
      if (status != null) queryParams['status'] = status;
      
      if (queryParams.isNotEmpty) {
        url += '?${queryParams.entries.map((e) => '${e.key}=${e.value}').join('&')}';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final objectives = (data['objectives'] as List)
            .map((obj) => Objective.fromJson(obj))
            .toList();
        return objectives;
      } else {
        throw Exception('Erreur lors de la récupération des objectifs de l\'équipe');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<Objective> getObjectiveById(String id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/$id'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Objective.fromJson(data['objective']);
      } else {
        throw Exception('Objectif non trouvé');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<Objective> createObjective({
    required String title,
    required String description,
    required String assignedToId,
    required String priority,
    required DateTime startDate,
    required DateTime dueDate,
    String? teamId,
    String? departmentId,
    List<String>? links,
    String? notes,
  }) async {
    try {
      final headers = await _getHeaders();
      final body = json.encode({
        'title': title,
        'description': description,
        'assignedTo': assignedToId,
        'priority': priority,
        'startDate': startDate.toIso8601String(),
        'dueDate': dueDate.toIso8601String(),
        if (teamId != null) 'team': teamId,
        if (departmentId != null) 'department': departmentId,
        if (links != null) 'links': links,
        if (notes != null) 'notes': notes,
      });

      final response = await http.post(
        Uri.parse('$baseUrl/create'),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return Objective.fromJson(data['data']);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Erreur lors de la création de l\'objectif');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<Objective> updateObjectiveStatus({
    required String id,
    required String status,
    String? blockReason,
  }) async {
    try {
      final headers = await _getHeaders();
      final body = json.encode({
        'status': status,
        if (blockReason != null) 'blockReason': blockReason,
      });

      final response = await http.put(
        Uri.parse('$baseUrl/$id/status'),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Objective.fromJson(data['objective']);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Erreur lors de la mise à jour du statut');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<Objective> updateObjectiveProgress({
    required String id,
    required int progress,
  }) async {
    try {
      final headers = await _getHeaders();
      final body = json.encode({
        'progress': progress,
      });

      final response = await http.put(
        Uri.parse('$baseUrl/$id/progress'),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Objective.fromJson(data['objective']);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Erreur lors de la mise à jour de la progression');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<Objective> addComment({
    required String id,
    required String text,
  }) async {
    try {
      final headers = await _getHeaders();
      final body = json.encode({
        'text': text,
      });

      final response = await http.post(
        Uri.parse('$baseUrl/$id/comments'),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Objective.fromJson(data['objective']);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Erreur lors de l\'ajout du commentaire');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<Objective> updateObjective({
    required String id,
    String? title,
    String? description,
    String? priority,
    DateTime? startDate,
    DateTime? dueDate,
    List<String>? links,
    String? notes,
  }) async {
    try {
      final headers = await _getHeaders();
      final body = json.encode({
        if (title != null) 'title': title,
        if (description != null) 'description': description,
        if (priority != null) 'priority': priority,
        if (startDate != null) 'startDate': startDate.toIso8601String(),
        if (dueDate != null) 'dueDate': dueDate.toIso8601String(),
        if (links != null) 'links': links,
        if (notes != null) 'notes': notes,
      });

      final response = await http.put(
        Uri.parse('$baseUrl/$id'),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Objective.fromJson(data['objective']);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Erreur lors de la mise à jour de l\'objectif');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<void> deleteObjective(String id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/$id'),
        headers: headers,
      );

      if (response.statusCode != 200) {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Erreur lors de la suppression de l\'objectif');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<Map<String, dynamic>> getObjectiveStats() async {
    try {
      final objectives = await getMyObjectives();
      
      final stats = {
        'total': objectives.length,
        'todo': objectives.where((o) => o.status == ObjectiveStatus.todo).length,
        'inProgress': objectives.where((o) => o.status == ObjectiveStatus.inProgress).length,
        'completed': objectives.where((o) => o.status == ObjectiveStatus.completed).length,
        'blocked': objectives.where((o) => o.status == ObjectiveStatus.blocked).length,
        'overdue': objectives.where((o) => o.isOverdue).length,
        'averageProgress': objectives.isEmpty 
            ? 0 
            : (objectives.map((o) => o.progress).reduce((a, b) => a + b) / objectives.length).round(),
      };

      return stats;
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<Objective> addSubTask({
    required String id,
    required String title,
  }) async {
    try {
      final headers = await _getHeaders();
      final body = json.encode({
        'title': title,
      });

      final response = await http.post(
        Uri.parse('$baseUrl/$id/subtasks'),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Objective.fromJson(data['objective']);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Erreur lors de l\'ajout de la sous-tâche');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<Objective> toggleSubTask({
    required String objectiveId,
    required String subTaskId,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/$objectiveId/subtasks/$subTaskId/toggle'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Objective.fromJson(data['objective']);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Erreur lors de la mise à jour de la sous-tâche');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<Objective> deleteSubTask({
    required String objectiveId,
    required String subTaskId,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/$objectiveId/subtasks/$subTaskId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Objective.fromJson(data['objective']);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Erreur lors de la suppression de la sous-tâche');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }
}
