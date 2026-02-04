class ApiConstants {
  static String get baseUrl {
    return 'https://pfe-backend-latest.onrender.com';
  }

  static String get socketUrl {
    return 'https://pfe-backend-latest.onrender.com';
  }
  
  static const Duration timeout = Duration(seconds: 30);
}

class StorageKeys {
  static const String authToken = 'auth_token';
  static const String userId = 'user_id';
  static const String fcmToken = 'fcm_token';
}

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
  static const String departmentGroups = '/department-groups';
  static const String adminDepartments = '/admin-departments';
  static const String debugUserCreation = '/debug-user-creation';
  static const String editProfile = '/edit-profile';
  static const String themeCustomization = '/theme-customization';
  static const String matriculeManagement = '/matricule-management';
  static const String pendingUsers = '/pending-users';
  static const String managerObjectives = '/manager-objectives';
  static const String settings = '/settings';
  static const String matriculeRegistration = '/matricule-registration';
  static const String pendingApproval = '/pending-approval';
}

class AppConstants {
  static const String appName = 'Employee Communication';
  static const String companyName = 'Your Company';
  
  static const int pageSize = 20;
  static const int maxFileSize = 10 * 1024 * 1024;
  
  static const Duration locationUpdateInterval = Duration(minutes: 5);
  
  static const Duration chatRefreshInterval = Duration(seconds: 30);
}

class ErrorMessages {
  static const String networkError = 'Network error. Please check your connection.';
  static const String serverError = 'Server error. Please try again later.';
  static const String unauthorized = 'Unauthorized. Please login again.';
  static const String invalidCredentials = 'Invalid email or password.';
  static const String permissionDenied = 'Permission denied.';
  static const String locationPermissionDenied = 'Location permission is required.';
  static const String unknownError = 'An unknown error occurred.';
}

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
