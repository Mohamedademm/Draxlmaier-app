import '../models/department_model.dart';
import '../models/team_model.dart';
import 'api_service.dart';

/// Service for managing departments via API
/// Now uses ChatGroups (type='department') as the source of truth
class DepartmentService {
  final ApiService _apiService = ApiService();

  /// Get all department groups
  Future<List<Department>> getDepartments({bool? isActive}) async {
    try {
      // Call the endpoint that returns all department groups
      final response = await _apiService.get('/groups/department/all');
      final data = _apiService.handleResponse(response);
      
      if (data['status'] == 'success') {
        final List<dynamic> groups = data['groups'] ?? [];
        return groups.map((json) {
          // Map ChatGroup to Department model
          return Department(
            id: json['_id'] ?? json['id'] ?? '',
            name: json['department'] ?? json['name'] ?? 'Unknown',
            description: json['description'],
            isActive: json['isActive'] ?? true,
            // ChatGroup doesn't have location/budget/color by default, use defaults or extended fields
            location: '', 
            budget: 0,
            color: '#4CAF50', // Default green
          );
        }).toList();
      }
      
      throw Exception('Failed to load departments: ${data['message']}');
    } catch (e) {
      print('Error in getDepartments: $e');
      rethrow;
    }
  }

  /// Get a single department by ID (ChatGroup ID)
  Future<Department> getDepartment(String departmentId) async {
    try {
      final response = await _apiService.get('/groups/$departmentId');
      final data = _apiService.handleResponse(response);
      
      if (data['status'] == 'success') {
        final json = data['group'];
        return Department(
            id: json['_id'] ?? json['id'] ?? '',
            name: json['department'] ?? json['name'] ?? 'Unknown',
            description: json['description'],
            isActive: json['isActive'] ?? true,
            location: '',
            budget: 0,
            color: '#4CAF50',
        );
      }
      
      throw Exception('Failed to load department: ${data['message']}');
    } catch (e) {
      print('Error in getDepartment: $e');
      rethrow;
    }
  }

  /// Create a new department group
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
        'department': name, // The backend expects 'department' for the name in findOrCreate/createDepartmentGroup
        'name': 'Groupe $name',
        'description': description,
        // managerId is handled by the backend (current user or added later)
        // If we need to assign a specific manager, backend needs to support it. 
        // For now, assume the user creating it is admin.
      };

      final response = await _apiService.post('/groups/department/create', data);
      final result = _apiService.handleResponse(response);
      
      if (result['status'] == 'success') {
        final json = result['group'];
         return Department(
            id: json['_id'] ?? json['id'] ?? '',
            name: json['department'] ?? json['name'] ?? 'Unknown',
            description: json['description'],
            isActive: json['isActive'] ?? true,
            location: '',
            budget: 0,
            color: '#4CAF50',
        );
      }
      
      throw Exception('Failed to create department: ${result['message']}');
    } catch (e) {
      print('Error in createDepartment: $e');
      rethrow;
    }
  }

  /// Update an existing department (ChatGroup)
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
    // Currently API doesn't have specific update endpoint for department details on ChatGroup
    // relying on generic logic or implementation in future.
    // Making it a no-op or basic update for now to prevent crash
    throw UnimplementedError('Update department is not yet supported with ChatGroups');
  }

  /// Delete a department (ChatGroup)
  Future<void> deleteDepartment(String departmentId) async {
    // Soft delete or real delete? ChatGroup usually hard deletes or flags inactive
    // Assuming backend standard
    try {
       // Using generic group delete? 
       // Currently no group delete endpoint exposed in groupController.js shown above.
       // Will assume it exists or implementation needed later.
       // Check groupController.js again? It didn't have delete.
       throw UnimplementedError('Delete department is not yet supported via API');
    } catch (e) {
      print('Error in deleteDepartment: $e');
      rethrow;
    }
  }

  /// Get all teams in a department
  Future<List<Team>> getDepartmentTeams(String departmentId) async {
    try {
      // Use the teams endpoint with department filter
      final response = await _apiService.get('/teams', queryParams: {'department': departmentId});
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
    return {};
  }
}
