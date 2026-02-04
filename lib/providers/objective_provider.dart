
import 'package:flutter/foundation.dart';
import '../models/objective_model.dart';
import '../services/objective_service.dart';

class ObjectiveProvider with ChangeNotifier {
  final ObjectiveService _objectiveService = ObjectiveService();

  List<Objective> _objectives = [];
  List<Objective> _teamObjectives = [];
  Objective? _selectedObjective;
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic> _stats = {};

  List<Objective> get objectives => _objectives;
  List<Objective> get teamObjectives => _teamObjectives;
  Objective? get selectedObjective => _selectedObjective;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic> get stats => _stats;

  List<Objective> get todoObjectives => 
      _objectives.where((o) => o.status == ObjectiveStatus.todo).toList();
  
  List<Objective> get inProgressObjectives => 
      _objectives.where((o) => o.status == ObjectiveStatus.inProgress).toList();
  
  List<Objective> get completedObjectives => 
      _objectives.where((o) => o.status == ObjectiveStatus.completed).toList();
  
  List<Objective> get blockedObjectives => 
      _objectives.where((o) => o.status == ObjectiveStatus.blocked).toList();
  
  List<Objective> get overdueObjectives => 
      _objectives.where((o) => o.isOverdue).toList();

  Future<void> fetchMyObjectives({
    String? status,
    String? priority,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _objectives = await _objectiveService.getMyObjectives(
        status: status,
        priority: priority,
      );

      _objectives.sort((a, b) => a.dueDate.compareTo(b.dueDate));

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchTeamObjectives({
    String? teamId,
    String? status,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _teamObjectives = await _objectiveService.getTeamObjectives(
        teamId: teamId,
        status: status,
      );

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchObjectiveById(String id) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _selectedObjective = await _objectiveService.getObjectiveById(id);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createObjective({
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
      _isLoading = true;
      _error = null;
      notifyListeners();

      final newObjective = await _objectiveService.createObjective(
        title: title,
        description: description,
        assignedToId: assignedToId,
        priority: priority,
        startDate: startDate,
        dueDate: dueDate,
        teamId: teamId,
        departmentId: departmentId,
        links: links,
        notes: notes,
      );

      _teamObjectives.insert(0, newObjective);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateStatus({
    required String id,
    required String status,
    String? blockReason,
  }) async {
    try {
      _error = null;

      final updatedObjective = await _objectiveService.updateObjectiveStatus(
        id: id,
        status: status,
        blockReason: blockReason,
      );

      final index = _objectives.indexWhere((o) => o.id == id);
      if (index != -1) {
        _objectives[index] = updatedObjective;
      }

      if (_selectedObjective?.id == id) {
        _selectedObjective = updatedObjective;
      }

      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProgress({
    required String id,
    required int progress,
  }) async {
    try {
      _error = null;

      final updatedObjective = await _objectiveService.updateObjectiveProgress(
        id: id,
        progress: progress,
      );

      final index = _objectives.indexWhere((o) => o.id == id);
      if (index != -1) {
        _objectives[index] = updatedObjective;
      }

      if (_selectedObjective?.id == id) {
        _selectedObjective = updatedObjective;
      }

      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> addComment({
    required String id,
    required String text,
  }) async {
    try {
      _error = null;

      final updatedObjective = await _objectiveService.addComment(
        id: id,
        text: text,
      );

      final index = _objectives.indexWhere((o) => o.id == id);
      if (index != -1) {
        _objectives[index] = updatedObjective;
      }

      if (_selectedObjective?.id == id) {
        _selectedObjective = updatedObjective;
      }

      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }


  Future<bool> addSubTask({
    required String id,
    required String title,
  }) async {
    try {
      _error = null;
      final updatedObjective = await _objectiveService.addSubTask(
        id: id,
        title: title,
      );
      _updateObjectiveInLists(updatedObjective);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> toggleSubTask({
    required String objectiveId,
    required String subTaskId,
  }) async {
    try {
      _error = null;
      final updatedObjective = await _objectiveService.toggleSubTask(
        objectiveId: objectiveId,
        subTaskId: subTaskId,
      );
      _updateObjectiveInLists(updatedObjective);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteSubTask({
    required String objectiveId,
    required String subTaskId,
  }) async {
    try {
      _error = null;
      final updatedObjective = await _objectiveService.deleteSubTask(
        objectiveId: objectiveId,
        subTaskId: subTaskId,
      );
      _updateObjectiveInLists(updatedObjective);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void _updateObjectiveInLists(Objective updatedObjective) {
    final index = _objectives.indexWhere((o) => o.id == updatedObjective.id);
    if (index != -1) {
      _objectives[index] = updatedObjective;
    }
    if (_selectedObjective?.id == updatedObjective.id) {
      _selectedObjective = updatedObjective;
    }
    notifyListeners();
  }

  Future<bool> updateObjective({
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
      _error = null;

      final updatedObjective = await _objectiveService.updateObjective(
        id: id,
        title: title,
        description: description,
        priority: priority,
        startDate: startDate,
        dueDate: dueDate,
        links: links,
        notes: notes,
      );

      final index = _objectives.indexWhere((o) => o.id == id);
      if (index != -1) {
        _objectives[index] = updatedObjective;
      }

      final teamIndex = _teamObjectives.indexWhere((o) => o.id == id);
      if (teamIndex != -1) {
        _teamObjectives[teamIndex] = updatedObjective;
      }

      if (_selectedObjective?.id == id) {
        _selectedObjective = updatedObjective;
      }

      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteObjective(String id) async {
    try {
      _error = null;

      await _objectiveService.deleteObjective(id);

      _objectives.removeWhere((o) => o.id == id);
      _teamObjectives.removeWhere((o) => o.id == id);

      if (_selectedObjective?.id == id) {
        _selectedObjective = null;
      }

      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchStats() async {
    try {
      _stats = await _objectiveService.getObjectiveStats();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await fetchMyObjectives();
    await fetchStats();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void selectObjective(Objective objective) {
    _selectedObjective = objective;
    notifyListeners();
  }

  void clearSelectedObjective() {
    _selectedObjective = null;
    notifyListeners();
  }
}
