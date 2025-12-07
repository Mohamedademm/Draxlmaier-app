/// API and network constants
class ApiConstants {
  // Backend base URL - Update this with your actual backend URL
  static const String baseUrl = 'http://localhost:3000/api';
  static const String socketUrl = 'http://localhost:3000';
  
  // Request timeout
  static const Duration timeout = Duration(seconds: 30);
}

/// Storage keys for local storage
class StorageKeys {
  static const String authToken = 'auth_token';
  static const String userId = 'user_id';
  static const String fcmToken = 'fcm_token';
}

/// Route names
class Routes {
  static const String splash = '/';
  static const String login = '/login';
  static const String home = '/home';
  static const String chatList = '/chat-list';
  static const String chatDetail = '/chat-detail';
  static const String notifications = '/notifications';
  static const String map = '/map';
  static const String adminDashboard = '/admin-dashboard';
  static const String userManagement = '/user-management';
  static const String debugUserCreation = '/debug-user-creation';
  static const String editProfile = '/edit-profile';
}

/// App constants
class AppConstants {
  static const String appName = 'Employee Communication';
  static const String companyName = 'Your Company';
  
  // Pagination
  static const int pageSize = 20;
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB
  
  // Location update interval
  static const Duration locationUpdateInterval = Duration(minutes: 5);
  
  // Chat refresh interval
  static const Duration chatRefreshInterval = Duration(seconds: 30);
}

/// Error messages
class ErrorMessages {
  static const String networkError = 'Network error. Please check your connection.';
  static const String serverError = 'Server error. Please try again later.';
  static const String unauthorized = 'Unauthorized. Please login again.';
  static const String invalidCredentials = 'Invalid email or password.';
  static const String permissionDenied = 'Permission denied.';
  static const String locationPermissionDenied = 'Location permission is required.';
  static const String unknownError = 'An unknown error occurred.';
}

/// Success messages
class SuccessMessages {
  static const String loginSuccess = 'Login successful!';
  static const String logoutSuccess = 'Logout successful!';
  static const String userCreated = 'User created successfully!';
  static const String userUpdated = 'User updated successfully!';
  static const String userDeleted = 'User deleted successfully!';
  static const String messageSent = 'Message sent successfully!';
  static const String notificationSent = 'Notification sent successfully!';
  static const String locationUpdated = 'Location updated successfully!';
}
