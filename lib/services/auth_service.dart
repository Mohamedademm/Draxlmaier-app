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

  /// Register new user (public endpoint)
  Future<Map<String, dynamic>> register({
    String? matricule,
    required String firstname,
    required String lastname,
    required String email,
    required String password,
    required String phone,
    required String position,
    required String department,
    required String address,
    required String city,
    required String postalCode,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final response = await _apiService.post('/auth/register', {
        if (matricule != null) 'matricule': matricule,
        'firstname': firstname,
        'lastname': lastname,
        'email': email,
        'password': password,
        'phone': phone,
        'position': position,
        'department': department,
        'address': address,
        'city': city,
        'postalCode': postalCode,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
      });

      final data = _apiService.handleResponse(response);
      
      // Save token for automatic login after registration
      if (data['token'] != null) {
        await _apiService.setToken(data['token']);
      }
      
      return data;
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  /// Forgot Password - Request reset token
  Future<void> forgotPassword(String email) async {
    try {
      final response = await _apiService.post('/auth/forgotpassword', {
        'email': email,
      });
      _apiService.handleResponse(response);
    } catch (e) {
      throw Exception('Failed to send reset email: $e');
    }
  }

  /// Register with matricule
  Future<Map<String, dynamic>> registerWithMatricule({
    required String matricule,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiService.post('/auth/register-with-matricule', {
        'matricule': matricule,
        'email': email,
        'password': password,
      });

      final data = _apiService.handleResponse(response);
      
      if (data['token'] != null) {
        await _apiService.setToken(data['token']);
      }
      
      return data;
    } catch (e) {
      throw Exception('Registration with matricule failed: $e');
    }
  }
}
