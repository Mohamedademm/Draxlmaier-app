import '../models/user_model.dart';
import 'api_service.dart';

class UserService {
  final ApiService _apiService = ApiService();

  Future<List<User>> getAllUsers() async {
    try {
      final response = await _apiService.get('/users');
      final data = _apiService.handleResponse(response);
      
      final List<dynamic> usersJson = data['users'];
      return usersJson.map((json) => User.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get users: $e');
    }
  }

  Future<User> getUserById(String userId) async {
    try {
      final response = await _apiService.get('/users/$userId');
      final data = _apiService.handleResponse(response);
      return User.fromJson(data['user']);
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }

  Future<User> createUser({
    required String firstname,
    required String lastname,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    try {
      final response = await _apiService.post('/users', {
        'firstname': firstname,
        'lastname': lastname,
        'email': email,
        'password': password,
        'role': role.name,
      });
      
      final data = _apiService.handleResponse(response);
      return User.fromJson(data['user']);
    } catch (e) {
      throw Exception('Failed to create user: $e');
    }
  }

  Future<User> updateUser({
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
      final body = <String, dynamic>{};
      if (firstname != null) body['firstname'] = firstname;
      if (lastname != null) body['lastname'] = lastname;
      if (email != null) body['email'] = email;
      if (role != null) body['role'] = role.name;
      if (active != null) body['active'] = active;
      if (phone != null) body['phone'] = phone;
      if (department != null) body['department'] = department;
      if (position != null) body['position'] = position;
      if (address != null) body['address'] = address;
      if (city != null) body['city'] = city;
      if (postalCode != null) body['postalCode'] = postalCode;

      final response = await _apiService.put('/users/$userId', body);
      final data = _apiService.handleResponse(response);
      return User.fromJson(data['user']);
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      await _apiService.delete('/users/$userId');
    } catch (e) {
      throw Exception('Failed to delete user: $e');
    }
  }

  Future<User> activateUser(String userId) async {
    try {
      final response = await _apiService.post('/users/$userId/activate', {});
      final data = _apiService.handleResponse(response);
      return User.fromJson(data['user']);
    } catch (e) {
      throw Exception('Failed to activate user: $e');
    }
  }

  Future<User> deactivateUser(String userId) async {
    try {
      final response = await _apiService.post('/users/$userId/deactivate', {});
      final data = _apiService.handleResponse(response);
      return User.fromJson(data['user']);
    } catch (e) {
      throw Exception('Failed to deactivate user: $e');
    }
  }

  Future<List<User>> searchUsers(String query) async {
    try {
      final response = await _apiService.get('/users/search?q=$query');
      final data = _apiService.handleResponse(response);
      
      final List<dynamic> usersJson = data['users'];
      return usersJson.map((json) => User.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to search users: $e');
    }
  }

  Future<List<User>> getPendingUsers() async {
    try {
      final response = await _apiService.get('/users/pending');
      final data = _apiService.handleResponse(response);
      
      final List<dynamic> usersJson = data['users'];
      return usersJson.map((json) => User.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get pending users: $e');
    }
  }

  Future<User> validateUser(String userId, String? matricule, String? team) async {
    try {
      final body = <String, dynamic>{};
      if (matricule != null) body['matricule'] = matricule;
      if (team != null) body['team'] = team;

      final response = await _apiService.post('/users/$userId/validate', body);
      final data = _apiService.handleResponse(response);
      return User.fromJson(data['user']);
    } catch (e) {
      throw Exception('Failed to validate user: $e');
    }
  }

  Future<void> rejectUser(String userId, String reason) async {
    try {
      await _apiService.post('/users/$userId/reject', {
        'reason': reason.isNotEmpty ? reason : 'Non précisée',
      });
    } catch (e) {
      throw Exception('Failed to reject user: $e');
    }
  }

  Future<Map<String, dynamic>> updateUserProfile(String userId, Map<String, dynamic> updates) async {
    try {
      final response = await _apiService.put('/users/$userId/profile', updates);
      final data = _apiService.handleResponse(response);
      return {
        'user': User.fromJson(data['user']),
        'addressChanged': data['addressChanged'] ?? false,
      };
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }
}
