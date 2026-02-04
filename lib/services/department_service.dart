import '../models/department_model.dart';
import '../models/team_model.dart';
import 'api_service.dart';

class DepartmentService {
  final ApiService _apiService = ApiService();

  Future<List<Department>> getDepartments({bool? isActive}) async {
    try {
      final response = await _apiService.get('/groups/department/all');
      final data = _apiService.handleResponse(response);
      
      if (data['status'] == 'success') {
        final List<dynamic> groups = data['groups'] ?? [];
        return groups.map((json) {
          return Department(
            id: json['_id'] ?? json['id'] ?? '',
            name: json['department'] ?? json['name'] ?? 'Unknown',
            description: json['description'],
            isActive: json['isActive'] ?? true,
            location: '', 
            budget: 0,
            color: '#4CAF50',
          );
        }).toList();
      }
      
      throw Exception('Failed to load departments: ${data['message']}');
    } catch (e) {
      print('Error in getDepartments: $e');
      rethrow;
    }
  }

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
        'department': name,
        'name': 'Groupe $name',
        'description': description,
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
    throw UnimplementedError('Update department is not yet supported with ChatGroups');
  }

  Future<void> deleteDepartment(String departmentId) async {
    try {
       throw UnimplementedError('Delete department is not yet supported via API');
    } catch (e) {
      print('Error in deleteDepartment: $e');
      rethrow;
    }
  }

  Future<List<Team>> getDepartmentTeams(String departmentId) async {
    try {
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

  Future<Map<String, dynamic>> getDepartmentStats(String departmentId) async {
    return {};
  }
}
