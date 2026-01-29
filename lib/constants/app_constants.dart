/// Constantes de l'application Draexlmaier
class AppConstants {
  // Informations de l'application
  static const String appName = 'Draexlmaier';
  static const String appVersion = '1.0.0';
  
  // Assets - Logos
  static const String logoPath = 'assets/images/draclmaier_Avec_coleur.jpg';
  static const String logoWhitePath = 'assets/images/draexlmaier_logo_white.png';
  static const String logoSplashPath = 'assets/images/draclmaier_Avec_coleur.jpg';
  
  // Assets - Icons
  static const String dashboardIcon = 'assets/icons/dashboard_icon.png';
  static const String teamIcon = 'assets/icons/team_icon.png';
  static const String objectiveIcon = 'assets/icons/objective_icon.png';
  static const String chatIcon = 'assets/icons/chat_icon.png';
  static const String profileIcon = 'assets/icons/profile_icon.png';
  static const String notificationIcon = 'assets/icons/notification_icon.png';
  static const String settingsIcon = 'assets/icons/settings_icon.png';
  
  // Tailles
  static const double logoSizeSmall = 80.0;
  static const double logoSizeMedium = 120.0;
  static const double logoSizeLarge = 180.0;
  
  static const double iconSizeSmall = 16.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 32.0;
  
  static const double borderRadiusSmall = 4.0;
  static const double borderRadiusMedium = 8.0;
  static const double borderRadiusLarge = 12.0;
  static const double borderRadiusXLarge = 16.0;
  
  // Espacements
  static const double paddingXSmall = 4.0;
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;
  
  // Animations
  static const Duration animationDurationFast = Duration(milliseconds: 200);
  static const Duration animationDurationNormal = Duration(milliseconds: 300);
  static const Duration animationDurationSlow = Duration(milliseconds: 500);
  
  // API Endpoints
  static const String baseUrl = 'https://backend-draxlmaier-app.onrender.com/api';
  
  // Statuts des objectifs
  static const String statusTodo = 'todo';
  static const String statusInProgress = 'in_progress';
  static const String statusCompleted = 'completed';
  static const String statusBlocked = 'blocked';
  
  static const List<String> objectiveStatuses = [
    statusTodo,
    statusInProgress,
    statusCompleted,
    statusBlocked,
  ];
  
  static const Map<String, String> objectiveStatusLabels = {
    statusTodo: 'À faire',
    statusInProgress: 'En cours',
    statusCompleted: 'Terminé',
    statusBlocked: 'Bloqué',
  };
  
  // Priorités des objectifs
  static const String priorityLow = 'low';
  static const String priorityMedium = 'medium';
  static const String priorityHigh = 'high';
  static const String priorityUrgent = 'urgent';
  
  static const List<String> objectivePriorities = [
    priorityLow,
    priorityMedium,
    priorityHigh,
    priorityUrgent,
  ];
  
  static const Map<String, String> objectivePriorityLabels = {
    priorityLow: 'Basse',
    priorityMedium: 'Moyenne',
    priorityHigh: 'Haute',
    priorityUrgent: 'Urgente',
  };
  
  // Rôles utilisateur
  static const String roleAdmin = 'admin';
  static const String roleManager = 'manager';
  static const String roleEmployee = 'employee';
  
  // Statuts utilisateur
  static const String userStatusPending = 'pending';
  static const String userStatusActive = 'active';
  static const String userStatusInactive = 'inactive';
  static const String userStatusRejected = 'rejected';
  
  // Messages
  static const String errorNetworkMessage = 'Erreur de connexion au serveur';
  static const String errorUnknownMessage = 'Une erreur est survenue';
  static const String successMessage = 'Opération réussie';
  
  // Validation
  static const int passwordMinLength = 1;
  static const int nameMinLength = 2;
  static const int phoneMinLength = 10;
  
  // Regex patterns
  static final RegExp emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );
  
  static final RegExp phoneRegex = RegExp(
    r'^[\d\s\-\+\(\)]+$',
  );
  
  static final RegExp passwordRegex = RegExp(
    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}$',
  );
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // Cache
  static const Duration cacheExpiration = Duration(minutes: 5);
  
  // Local Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String themeKey = 'theme_mode';
  static const String languageKey = 'language_code';
  
  // Limites
  static const int maxFileSize = 10 * 1024 * 1024; // 10 MB
  static const List<String> allowedFileExtensions = [
    'pdf', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx',
    'jpg', 'jpeg', 'png', 'gif',
    'zip', 'rar',
  ];
  
  // Format de date
  static const String dateFormat = 'dd/MM/yyyy';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';
  static const String timeFormat = 'HH:mm';
}
