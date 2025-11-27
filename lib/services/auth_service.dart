import '../models/user_model.dart';
import 'api_service.dart';

/// Authentication service handling user login and token management
class AuthService {
  final ApiService _apiService = ApiService();

  /// Login with email and password
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _apiService.post('/auth/login', {
        'email': email,
        'password': password,
      });

      final data = _apiService.handleResponse(response);
      
      if (data['token'] != null) {
        await _apiService.setToken(data['token']);
      }
      
      return data;
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  /// Logout and clear token
  Future<void> logout() async {
    await _apiService.clearToken();
  }

  /// Get current user profile
  Future<User> getCurrentUser() async {
    try {
      final response = await _apiService.get('/auth/me');
      final data = _apiService.handleResponse(response);
      return User.fromJson(data['user']);
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final token = await _apiService.getToken();
    return token != null && token.isNotEmpty;
  }

  /// Update FCM token for push notifications
  Future<void> updateFcmToken(String fcmToken) async {
    try {
      await _apiService.post('/auth/fcm-token', {
        'fcmToken': fcmToken,
      });
    } catch (e) {
      throw Exception('Failed to update FCM token: $e');
    }
  }
}
