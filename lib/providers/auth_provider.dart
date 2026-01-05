import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';

/// Authentication state management provider
class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final NotificationService _notificationService = NotificationService();

  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  /// Check if current user is admin
  bool get isAdmin => _currentUser?.isAdmin ?? false;

  /// Check if current user is manager
  bool get isManager => _currentUser?.isManager ?? false;

  /// Check if current user is employee
  bool get isEmployee => _currentUser?.isEmployee ?? false;

  /// Check if current user can manage other users
  bool get canManageUsers => _currentUser?.canManageUsers ?? false;

  /// Login with email and password
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await _authService.login(email, password);
      _currentUser = User.fromJson(data['user']);

      // Update FCM token after login
      final fcmToken = await _notificationService.getFcmToken();
      if (fcmToken != null) {
        await _authService.updateFcmToken(fcmToken);
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

  /// Logout
  Future<void> logout() async {
    await _authService.logout();
    _currentUser = null;
    _errorMessage = null;
    notifyListeners();
  }

  /// Load current user profile
  Future<void> loadCurrentUser() async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentUser = await _authService.getCurrentUser();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Check if user status is pending
  bool get isPending => _currentUser?.status == 'pending' || (_currentUser?.active == false);

  /// Check if user is authenticated on app start
  Future<bool> checkAuthentication() async {
    try {
      final isAuth = await _authService.isAuthenticated();
      if (isAuth) {
        await loadCurrentUser();
        return _currentUser != null;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Refresh current user data (used after profile updates)
  Future<void> refreshUser() async {
    if (_currentUser != null) {
      try {
        _currentUser = await _authService.getCurrentUser();
        notifyListeners();
      } catch (e) {
        debugPrint('Error refreshing user: $e');
      }
    }
  }

  /// Register with matricule
  Future<bool> registerWithMatricule({
    required String matricule,
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await _authService.registerWithMatricule(
        matricule: matricule,
        email: email,
        password: password,
      );
      _currentUser = User.fromJson(data['user']);
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
}