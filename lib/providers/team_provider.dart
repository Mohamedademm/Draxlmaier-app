import 'package:flutter/foundation.dart';
import '../models/team_model.dart';
import '../models/department_model.dart';
import '../services/team_service.dart';
import '../services/department_service.dart';

/// Provider for managing teams and departments state
class TeamProvider with ChangeNotifier {
  final TeamService _teamService = TeamService();
  final DepartmentService _departmentService = DepartmentService();

  // State
  List<Team> _teams = [];
  List<Department> _departments = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<Team> get teams => _teams;
  List<Department> get departments => _departments;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Load all teams from API
  Future<void> loadTeams({bool? isActive, String? departmentId}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _teams = await _teamService.getTeams(
        isActive: isActive,
        departmentId: departmentId,
      );
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load teams: ${e.toString()}';
      print('Error loading teams: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load all departments from API
  Future<void> loadDepartments({bool? isActive}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _departments = await _departmentService.getDepartments(isActive: isActive);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load departments: ${e.toString()}';
      print('Error loading departments: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load both teams and departments
  Future<void> loadAll() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Load both in parallel without triggering individual loading states
      final results = await Future.wait([
        _teamService.getTeams(isActive: true),
        _departmentService.getDepartments(isActive: true),
      ]);
      
      _teams = results[0] as List<Team>;
      _departments = results[1] as List<Department>;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load data: ${e.toString()}';
      print('Error loading all data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Create a new team
  Future<bool> createTeam({
    required String name,
    String? description,
    String? departmentId,
    required String leaderId,
    List<String>? memberIds,
    String? color,
  }) async {
    _errorMessage = null;

    try {
      final newTeam = await _teamService.createTeam(
        name: name,
        description: description,
        departmentId: departmentId,
        leaderId: leaderId,
        memberIds: memberIds,
        color: color,
      );

      _teams.add(newTeam);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to create team: ${e.toString()}';
      print('Error creating team: $e');
      notifyListeners();
      return false;
    }
  }

  /// Update an existing team
  Future<bool> updateTeam({
    required String teamId,
    String? name,
    String? description,
    String? departmentId,
    String? leaderId,
    List<String>? memberIds,
    String? color,
    bool? isActive,
  }) async {
    _errorMessage = null;

    try {
      final updatedTeam = await _teamService.updateTeam(
        teamId: teamId,
        name: name,
        description: description,
        departmentId: departmentId,
        leaderId: leaderId,
        memberIds: memberIds,
        color: color,
        isActive: isActive,
      );

      final index = _teams.indexWhere((t) => t.id == teamId);
      if (index != -1) {
        _teams[index] = updatedTeam;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update team: ${e.toString()}';
      print('Error updating team: $e');
      notifyListeners();
      return false;
    }
  }

  /// Delete a team
  Future<bool> deleteTeam(String teamId) async {
    _errorMessage = null;

    try {
      await _teamService.deleteTeam(teamId);
      _teams.removeWhere((t) => t.id == teamId);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete team: ${e.toString()}';
      print('Error deleting team: $e');
      notifyListeners();
      return false;
    }
  }

  /// Add member to team
  Future<bool> addMemberToTeam(String teamId, String userId) async {
    _errorMessage = null;

    try {
      final updatedTeam = await _teamService.addMemberToTeam(teamId, userId);
      final index = _teams.indexWhere((t) => t.id == teamId);
      if (index != -1) {
        _teams[index] = updatedTeam;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _errorMessage = 'Failed to add member: ${e.toString()}';
      print('Error adding member: $e');
      notifyListeners();
      return false;
    }
  }

  /// Remove member from team
  Future<bool> removeMemberFromTeam(String teamId, String userId) async {
    _errorMessage = null;

    try {
      final updatedTeam = await _teamService.removeMemberFromTeam(teamId, userId);
      final index = _teams.indexWhere((t) => t.id == teamId);
      if (index != -1) {
        _teams[index] = updatedTeam;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _errorMessage = 'Failed to remove member: ${e.toString()}';
      print('Error removing member: $e');
      notifyListeners();
      return false;
    }
  }

  /// Create a new department
  Future<bool> createDepartment({
    required String name,
    String? description,
    required String managerId,
    String? location,
    int? budget,
    String? color,
  }) async {
    _errorMessage = null;

    try {
      final newDepartment = await _departmentService.createDepartment(
        name: name,
        description: description,
        managerId: managerId,
        location: location,
        budget: budget,
        color: color,
      );

      _departments.add(newDepartment);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to create department: ${e.toString()}';
      print('Error creating department: $e');
      notifyListeners();
      return false;
    }
  }

  /// Update an existing department
  Future<bool> updateDepartment({
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
    _errorMessage = null;

    try {
      final updatedDepartment = await _departmentService.updateDepartment(
        departmentId: departmentId,
        name: name,
        description: description,
        managerId: managerId,
        location: location,
        budget: budget,
        color: color,
        employeeCount: employeeCount,
        isActive: isActive,
      );

      final index = _departments.indexWhere((d) => d.id == departmentId);
      if (index != -1) {
        _departments[index] = updatedDepartment;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update department: ${e.toString()}';
      print('Error updating department: $e');
      notifyListeners();
      return false;
    }
  }

  /// Delete a department
  Future<bool> deleteDepartment(String departmentId) async {
    _errorMessage = null;

    try {
      await _departmentService.deleteDepartment(departmentId);
      _departments.removeWhere((d) => d.id == departmentId);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete department: ${e.toString()}';
      print('Error deleting department: $e');
      notifyListeners();
      return false;
    }
  }

  /// Get teams by department
  List<Team> getTeamsByDepartment(String departmentId) {
    return _teams.where((team) => team.department?.id == departmentId).toList();
  }

  /// Get team by ID
  Team? getTeamById(String teamId) {
    try {
      return _teams.firstWhere((team) => team.id == teamId);
    } catch (e) {
      return null;
    }
  }

  /// Get department by ID
  Department? getDepartmentById(String departmentId) {
    try {
      return _departments.firstWhere((dept) => dept.id == departmentId);
    } catch (e) {
      return null;
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Refresh all data
  Future<void> refresh() async {
    await loadAll();
  }
}
