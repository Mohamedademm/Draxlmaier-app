import '../models/department_model.dart';
import '../models/team_model.dart';
import 'api_service.dart';

/// Service for managing departments via API
class DepartmentService {
  final ApiService _apiService = ApiService();

  /// Get all departments
  /// Optional filter: isActive
  Future<List<Department>> getDepartments({bool? isActive}) async {
    try {
      final queryParams = <String, String>{};
      if (isActive != null) {
        queryParams['isActive'] = isActive.toString();
      }

      final response = await _apiService.get('/departments', queryParams: queryParams);
      final data = _apiService.handleResponse(response);
      
      if (data['status'] == 'success') {
        final List<dynamic> depts = data['data'] ?? [];
        return depts.map((json) => Department.fromJson(json)).toList();
      }
      
      throw Exception('Failed to load departments: ${data['message']}');
    } catch (e) {
      print('Error in getDepartments: $e');
      rethrow;
    }
  }

  /// Get a single department by ID
  Future<Department> getDepartment(String departmentId) async {
    try {
      final response = await _apiService.get('/departments/$departmentId');
      final data = _apiService.handleResponse(response);
      
      if (data['status'] == 'success') {
        return Department.fromJson(data['data']);
      }
      
      throw Exception('Failed to load department: ${data['message']}');
    } catch (e) {
      print('Error in getDepartment: $e');
      rethrow;
    }
  }

  /// Create a new department
  Future<Department> createDepartment({
    required String name,
    String? description,
    required String managerId,
    String? location,
    int? budget,
    String? color,
  }) async {
    try {
      final data = {
        'name': name,
        if (description != null) 'description': description,
        'manager': managerId,
        if (location != null) 'location': location,
        if (budget != null) 'budget': budget,
        if (color != null) 'color': color,
      };

      final response = await _apiService.post('/departments', data);
      final result = _apiService.handleResponse(response);
      
      if (result['status'] == 'success') {
        return Department.fromJson(result['data']);
      }
      
      throw Exception('Failed to create department: ${result['message']}');
    } catch (e) {
      print('Error in createDepartment: $e');
      rethrow;
    }
  }

  /// Update an existing department
  Future<Department> updateDepartment({
    required String departmentId,
    String? name,
    String? description,
    String? managerId,
    String? location,
    int? budget,
    String? color,
    int? employeeCount,
    bool? isActive,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (description != null) data['description'] = description;
      if (managerId != null) data['manager'] = managerId;
      if (location != null) data['location'] = location;
      if (budget != null) data['budget'] = budget;
      if (color != null) data['color'] = color;
      if (employeeCount != null) data['employeeCount'] = employeeCount;
      if (isActive != null) data['isActive'] = isActive;

      final response = await _apiService.put('/departments/$departmentId', data);
      final result = _apiService.handleResponse(response);
      
      if (result['status'] == 'success') {
        return Department.fromJson(result['data']);
      }
      
      throw Exception('Failed to update department: ${result['message']}');
    } catch (e) {
      print('Error in updateDepartment: $e');
      rethrow;
    }
  }

  /// Delete a department (soft delete)
  Future<void> deleteDepartment(String departmentId) async {
    try {
      final response = await _apiService.delete('/departments/$departmentId');
      final result = _apiService.handleResponse(response);
      
      if (result['status'] != 'success') {
        throw Exception('Failed to delete department: ${result['message']}');
      }
    } catch (e) {
      print('Error in deleteDepartment: $e');
      rethrow;
    }
  }

  /// Get all teams in a department
  Future<List<Team>> getDepartmentTeams(String departmentId) async {
    try {
      final response = await _apiService.get('/departments/$departmentId/teams');
      final data = _apiService.handleResponse(response);
      
      if (data['status'] == 'success') {
        final List<dynamic> teams = data['data'] ?? [];
        return teams.map((json) => Team.fromJson(json)).toList();
      }
      
      throw Exception('Failed to load department teams: ${data['message']}');
    } catch (e) {
      print('Error in getDepartmentTeams: $e');
      rethrow;
    }
  }

  /// Get department statistics
  Future<Map<String, dynamic>> getDepartmentStats(String departmentId) async {
    try {
      final response = await _apiService.get('/departments/$departmentId/stats');
      final data = _apiService.handleResponse(response);
      
      if (data['status'] == 'success') {
        return data['data'];
      }
      
      throw Exception('Failed to load department stats: ${data['message']}');
    } catch (e) {
      print('Error in getDepartmentStats: $e');
      rethrow;
    }
  }
}
