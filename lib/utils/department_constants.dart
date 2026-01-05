/// Constants for department names
class DepartmentConstants {
  static const List<String> allowedDepartments = [
    'Qualité',
    'Logistique',
    'MM shift A',
    'MM shift B',
    'SZB shift A',
    'SZB shift B',
  ];

  /// Check if a department name is valid
  static bool isValidDepartment(String? department) {
    if (department == null) return false;
    return allowedDepartments.contains(department);
  }

  /// Get department color
  static String getDepartmentColor(String department) {
    switch (department) {
      case 'Qualité':
        return '#4CAF50'; // Green
      case 'Logistique':
        return '#2196F3'; // Blue
      case 'MM shift A':
        return '#FF9800'; // Orange
      case 'MM shift B':
        return '#F44336'; // Red
      case 'SZB shift A':
        return '#9C27B0'; // Purple
      case 'SZB shift B':
        return '#00BCD4'; // Cyan
      default:
        return '#757575'; // Grey
    }
  }

  /// Get department icon
  static String getDepartmentIcon(String department) {
    switch (department) {
      case 'Qualité':
        return '✓';
      case 'Logistique':
        return '📦';
      case 'MM shift A':
      case 'MM shift B':
        return '⚙️';
      case 'SZB shift A':
      case 'SZB shift B':
        return '🔧';
      default:
        return '👥';
    }
  }
}
