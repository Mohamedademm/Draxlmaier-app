import '../models/team_model.dart';
import '../models/user_model.dart';
import 'api_service.dart';

/// Service for managing teams via API
class TeamService {
  final ApiService _apiService = ApiService();

  /// Get all teams
  /// Optional filters: isActive, department
  Future<List<Team>> getTeams({bool? isActive, String? departmentId}) async {
    try {
      final queryParams = <String, String>{};
      if (isActive != null) {
        queryParams['isActive'] = isActive.toString();
      }
      if (departmentId != null) {
        queryParams['department'] = departmentId;
      }

      final response = await _apiService.get('/teams', queryParams: queryParams);
      final data = _apiService.handleResponse(response);
      
      if (data['status'] == 'success') {
        final List<dynamic> teams = data['data'] ?? [];
        return teams.map((json) => Team.fromJson(json)).toList();
      }
      
      throw Exception('Failed to load teams: ${data['message']}');
    } catch (e) {
      print('Error in getTeams: $e');
      rethrow;
    }
  }

  /// Get a single team by ID
  Future<Team> getTeam(String teamId) async {
    try {
      final response = await _apiService.get('/teams/$teamId');
      final data = _apiService.handleResponse(response);
      
      if (data['status'] == 'success') {
        return Team.fromJson(data['data']);
      }
      
      throw Exception('Failed to load team: ${data['message']}');
    } catch (e) {
      print('Error in getTeam: $e');
      rethrow;
    }
  }

  /// Create a new team
  Future<Team> createTeam({
    required String name,
    String? description,
    String? departmentId,
    required String leaderId,
    List<String>? memberIds,
    String? color,
  }) async {
    try {
      final data = {
        'name': name,
        if (description != null) 'description': description,
        if (departmentId != null) 'department': departmentId,
        'leader': leaderId,
        if (memberIds != null && memberIds.isNotEmpty) 'members': memberIds,
        if (color != null) 'color': color,
      };

      final response = await _apiService.post('/teams', data);
      final result = _apiService.handleResponse(response);
      
      if (result['status'] == 'success') {
        return Team.fromJson(result['data']);
      }
      
      throw Exception('Failed to create team: ${result['message']}');
    } catch (e) {
      print('Error in createTeam: $e');
      rethrow;
    }
  }

  /// Update an existing team
  Future<Team> updateTeam({
    required String teamId,
    String? name,
    String? description,
    String? departmentId,
    String? leaderId,
    List<String>? memberIds,
    String? color,
    bool? isActive,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (description != null) data['description'] = description;
      if (departmentId != null) data['department'] = departmentId;
      if (leaderId != null) data['leader'] = leaderId;
      if (memberIds != null) data['members'] = memberIds;
      if (color != null) data['color'] = color;
      if (isActive != null) data['isActive'] = isActive;

      final response = await _apiService.put('/teams/$teamId', data);
      final result = _apiService.handleResponse(response);
      
      if (result['status'] == 'success') {
        return Team.fromJson(result['data']);
      }
      
      throw Exception('Failed to update team: ${result['message']}');
    } catch (e) {
      print('Error in updateTeam: $e');
      rethrow;
    }
  }

  /// Delete a team (soft delete)
  Future<void> deleteTeam(String teamId) async {
    try {
      final response = await _apiService.delete('/teams/$teamId');
      final result = _apiService.handleResponse(response);
      
      if (result['status'] != 'success') {
        throw Exception('Failed to delete team: ${result['message']}');
      }
    } catch (e) {
      print('Error in deleteTeam: $e');
      rethrow;
    }
  }

  /// Get all members of a team
  Future<List<User>> getTeamMembers(String teamId) async {
    try {
      final response = await _apiService.get('/teams/$teamId/members');
      final data = _apiService.handleResponse(response);
      
      if (data['status'] == 'success') {
        final List<dynamic> members = data['data'] ?? [];
        return members.map((json) => User.fromJson(json)).toList();
      }
      
      throw Exception('Failed to load team members: ${data['message']}');
    } catch (e) {
      print('Error in getTeamMembers: $e');
      rethrow;
    }
  }

  /// Add a member to a team
  Future<Team> addMemberToTeam(String teamId, String userId) async {
    try {
      final response = await _apiService.post(
        '/teams/$teamId/members',
        {'userId': userId},
      );
      final result = _apiService.handleResponse(response);
      
      if (result['status'] == 'success') {
        return Team.fromJson(result['data']);
      }
      
      throw Exception('Failed to add member: ${result['message']}');
    } catch (e) {
      print('Error in addMemberToTeam: $e');
      rethrow;
    }
  }

  /// Remove a member from a team
  Future<Team> removeMemberFromTeam(String teamId, String userId) async {
    try {
      final response = await _apiService.delete('/teams/$teamId/members/$userId');
      final result = _apiService.handleResponse(response);
      
      if (result['status'] == 'success') {
        return Team.fromJson(result['data']);
      }
      
      throw Exception('Failed to remove member: ${result['message']}');
    } catch (e) {
      print('Error in removeMemberFromTeam: $e');
      rethrow;
    }
  }
}
