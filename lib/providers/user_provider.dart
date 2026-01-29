import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';
import '../services/cache_service.dart';

/// User management state management provider
class UserProvider with ChangeNotifier {
  final UserService _userService = UserService();
  final CacheService _cacheService = CacheService();

  List<User> _users = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<User> get users => _users;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Get active users only
  List<User> get activeUsers => _users.where((u) => u.active).toList();

  /// Get inactive users only
  List<User> get inactiveUsers => _users.where((u) => !u.active).toList();

  /// Load all users
  Future<void> loadUsers() async {
    _isLoading = true;
    notifyListeners();

    final String cacheKey = CacheService.allUsersKey;

    // 1. Try to load from cache first
    try {
      final cachedData = _cacheService.getData(cacheKey);
      if (cachedData != null && cachedData is List && cachedData.isNotEmpty) {
        try {
          _users = cachedData
              .where((item) => item != null)
              .map((json) => User.fromJson(json as Map<String, dynamic>))
              .toList();
          notifyListeners();
        } catch (parseError) {
          debugPrint('Error parsing cached users: $parseError');
          _users = []; // Reset to empty if parsing fails
        }
      }
    } catch (e) {
      debugPrint('Error loading users from cache: $e');
    }

    // 2. Fetch from API
    try {
      _users = await _userService.getAllUsers();
      
      // 3. Update cache
      try {
        final usersJson = _users.map((u) => u.toJson()).toList();
        await _cacheService.saveData(cacheKey, usersJson);
      } catch (e) {
        debugPrint('Error saving users to cache: $e');
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      // Keep showing cached data if available
      notifyListeners();
    }
  }

  /// Get user by ID
  Future<User?> getUserById(String userId) async {
    try {
      // Check if user is in cache
      final cachedUser = _users.firstWhere(
        (u) => u.id == userId,
        orElse: () => throw Exception('User not found'),
      );
      return cachedUser;
    } catch (e) {
      // Fetch from server if not in cache
      try {
        return await _userService.getUserById(userId);
      } catch (e) {
        _errorMessage = e.toString();
        notifyListeners();
        return null;
      }
    }
  }

  /// Create new user
  Future<bool> createUser({
    required String firstname,
    required String lastname,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    try {
      final user = await _userService.createUser(
        firstname: firstname,
        lastname: lastname,
        email: email,
        password: password,
        role: role,
      );
      
      _users.add(user);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Update user
  Future<bool> updateUser({
    required String userId,
    String? firstname,
    String? lastname,
    String? email,
    UserRole? role,
    bool? active,
    String? phone,
    String? department,
    String? position,
    String? address,
    String? city,
    String? postalCode,
  }) async {
    try {
      final updatedUser = await _userService.updateUser(
        userId: userId,
        firstname: firstname,
        lastname: lastname,
        email: email,
        role: role,
        active: active,
        phone: phone,
        department: department,
        position: position,
        address: address,
        city: city,
        postalCode: postalCode,
      );
      
      final index = _users.indexWhere((u) => u.id == userId);
      if (index != -1) {
        _users[index] = updatedUser;
        notifyListeners();
      }
      
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Delete user
  Future<bool> deleteUser(String userId) async {
    try {
      await _userService.deleteUser(userId);
      _users.removeWhere((u) => u.id == userId);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Activate user
  Future<bool> activateUser(String userId) async {
    try {
      final updatedUser = await _userService.activateUser(userId);
      
      final index = _users.indexWhere((u) => u.id == userId);
      if (index != -1) {
        _users[index] = updatedUser;
        notifyListeners();
      }
      
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Deactivate user
  Future<bool> deactivateUser(String userId) async {
    try {
      final updatedUser = await _userService.deactivateUser(userId);
      
      final index = _users.indexWhere((u) => u.id == userId);
      if (index != -1) {
        _users[index] = updatedUser;
        notifyListeners();
      }
      
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Search users
  Future<List<User>> searchUsers(String query) async {
    try {
      return await _userService.searchUsers(query);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return [];
    }
  }

  /// Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
