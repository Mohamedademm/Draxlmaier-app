import 'package:flutter/material.dart';
import '../models/matricule_model.dart';
import '../services/matricule_service.dart';

class MatriculeProvider with ChangeNotifier {
  final MatriculeService _service = MatriculeService();

  List<Matricule> _matricules = [];
  MatriculeStats? _stats;
  bool _isLoading = false;
  String? _errorMessage;

  String? _statusFilter;
  String? _departmentFilter;
  String? _searchQuery;

  List<Matricule> get matricules => _matricules;
  MatriculeStats? get stats => _stats;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get statusFilter => _statusFilter;
  String? get departmentFilter => _departmentFilter;
  String? get searchQuery => _searchQuery;

  List<Matricule> get availableMatricules =>
      _matricules.where((m) => !m.isUsed).toList();
  
  List<Matricule> get usedMatricules =>
      _matricules.where((m) => m.isUsed).toList();

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

  Future<void> loadStats() async {
    try {
      _stats = await _service.getStats();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

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

      await loadStats();

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<Map<String, int>?> importExcel(List<Map<String, String>> matricules) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _service.importExcel(matricules);
      _isLoading = false;
      notifyListeners();

      await loadMatricules();

      return result;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

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

  Future<bool> deleteMatricule(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _service.deleteMatricule(id);
      _matricules.removeWhere((m) => m.id == id);
      _isLoading = false;
      notifyListeners();

      await loadStats();

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

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

  void clearFilters() {
    _statusFilter = null;
    _departmentFilter = null;
    _searchQuery = null;
    loadMatricules();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
