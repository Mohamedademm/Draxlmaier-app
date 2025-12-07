import 'package:flutter/foundation.dart';
import '../models/objective_model.dart';
import '../services/objective_service.dart';

/// Provider pour gérer l'état des objectifs
class ObjectiveProvider with ChangeNotifier {
  final ObjectiveService _objectiveService = ObjectiveService();

  List<Objective> _objectives = [];
  List<Objective> _teamObjectives = [];
  Objective? _selectedObjective;
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic> _stats = {};

  // Getters
  List<Objective> get objectives => _objectives;
  List<Objective> get teamObjectives => _teamObjectives;
  Objective? get selectedObjective => _selectedObjective;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic> get stats => _stats;

  // Filtres
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

  /// Récupérer mes objectifs
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

      // Trier par date d'échéance
      _objectives.sort((a, b) => a.dueDate.compareTo(b.dueDate));

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Récupérer les objectifs de l'équipe (manager)
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

  /// Récupérer un objectif par ID
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

  /// Créer un nouvel objectif (manager)
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

  /// Mettre à jour le statut d'un objectif
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

      // Mettre à jour dans la liste
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

  /// Mettre à jour la progression
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

      // Mettre à jour dans la liste
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

  /// Ajouter un commentaire
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

      // Mettre à jour dans la liste
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

  /// Mettre à jour un objectif (manager)
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

      // Mettre à jour dans les listes
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

  /// Supprimer un objectif (manager)
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

  /// Récupérer les statistiques
  Future<void> fetchStats() async {
    try {
      _stats = await _objectiveService.getObjectiveStats();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Rafraîchir les données
  Future<void> refresh() async {
    await fetchMyObjectives();
    await fetchStats();
  }

  /// Réinitialiser les erreurs
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Sélectionner un objectif
  void selectObjective(Objective objective) {
    _selectedObjective = objective;
    notifyListeners();
  }

  /// Désélectionner l'objectif actuel
  void clearSelectedObjective() {
    _selectedObjective = null;
    notifyListeners();
  }
}
