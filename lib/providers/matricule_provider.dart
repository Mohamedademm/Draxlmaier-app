import 'package:flutter/material.dart';
import '../models/matricule_model.dart';
import '../services/matricule_service.dart';

/// Provider pour gérer l'état des matricules
class MatriculeProvider with ChangeNotifier {
  final MatriculeService _service = MatriculeService();

  List<Matricule> _matricules = [];
  MatriculeStats? _stats;
  bool _isLoading = false;
  String? _errorMessage;

  // Filtres
  String? _statusFilter; // 'available', 'used', null
  String? _departmentFilter;
  String? _searchQuery;

  // Getters
  List<Matricule> get matricules => _matricules;
  MatriculeStats? get stats => _stats;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get statusFilter => _statusFilter;
  String? get departmentFilter => _departmentFilter;
  String? get searchQuery => _searchQuery;

  // Matricules filtrés
  List<Matricule> get availableMatricules =>
      _matricules.where((m) => !m.isUsed).toList();
  
  List<Matricule> get usedMatricules =>
      _matricules.where((m) => m.isUsed).toList();

  /// Charger tous les matricules
  Future<void> loadMatricules() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _matricules = await _service.getAllMatricules(
        status: _statusFilter,
        department: _departmentFilter,
        search: _searchQuery,
      );
      print('✅ Matricules chargés: ${_matricules.length}'); // DEBUG
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('❌ Erreur chargement matricules: $e'); // DEBUG
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Charger les statistiques
  Future<void> loadStats() async {
    try {
      _stats = await _service.getStats();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// Créer un matricule
  Future<bool> createMatricule({
    required String matricule,
    required String nom,
    required String prenom,
    required String poste,
    required String department,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newMatricule = await _service.createMatricule(
        matricule: matricule,
        nom: nom,
        prenom: prenom,
        poste: poste,
        department: department,
      );

      _matricules.insert(0, newMatricule);
      _isLoading = false;
      notifyListeners();

      // Recharger les stats
      await loadStats();

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Import en masse depuis Excel
  Future<Map<String, int>?> importExcel(List<Map<String, String>> matricules) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _service.importExcel(matricules);
      _isLoading = false;
      notifyListeners();

      // Recharger la liste
      await loadMatricules();

      return result;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// Vérifier un matricule
  Future<MatriculeCheckResult?> checkMatricule(String matricule) async {
    _errorMessage = null;

    try {
      final result = await _service.checkMatricule(matricule);
      return result;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  /// Mettre à jour un matricule
  Future<bool> updateMatricule({
    required String id,
    String? nom,
    String? prenom,
    String? poste,
    String? department,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updated = await _service.updateMatricule(
        id: id,
        nom: nom,
        prenom: prenom,
        poste: poste,
        department: department,
      );

      final index = _matricules.indexWhere((m) => m.id == id);
      if (index != -1) {
        _matricules[index] = updated;
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Supprimer un matricule
  Future<bool> deleteMatricule(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _service.deleteMatricule(id);
      _matricules.removeWhere((m) => m.id == id);
      _isLoading = false;
      notifyListeners();

      // Recharger les stats
      await loadStats();

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Appliquer les filtres
  void setFilters({
    String? status,
    String? department,
    String? search,
  }) {
    _statusFilter = status;
    _departmentFilter = department;
    _searchQuery = search;
    loadMatricules();
  }

  /// Réinitialiser les filtres
  void clearFilters() {
    _statusFilter = null;
    _departmentFilter = null;
    _searchQuery = null;
    loadMatricules();
  }

  /// Effacer l'erreur
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
