class DepartmentConstants {
  static const List<String> allowedDepartments = [
    'Qualité',
    'Logistique',
    'MM shift A',
    'MM shift B',
    'SZB shift A',
    'SZB shift B',
  ];

  static bool isValidDepartment(String? department) {
    if (department == null) return false;
    return department.trim().isNotEmpty;
  }

  static String getDepartmentColor(String department) {
    switch (department) {
      case 'Qualité':
        return '#4CAF50';
      case 'Logistique':
        return '#2196F3';
      case 'MM shift A':
        return '#FF9800';
      case 'MM shift B':
        return '#F44336';
      case 'SZB shift A':
        return '#9C27B0';
      case 'SZB shift B':
        return '#00BCD4';
      default:
        return '#757575';
    }
  }

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
