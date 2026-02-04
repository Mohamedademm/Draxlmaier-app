import 'dart:math';

class PasswordGenerator {
  static const String _uppercase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  static const String _lowercase = 'abcdefghijklmnopqrstuvwxyz';
  static const String _numbers = '0123456789';
  static const String _special = '@#\$%&*!';

  static String generate({int length = 10}) {
    final random = Random.secure();
    const chars = _uppercase + _lowercase + _numbers + _special;
    
    String password = '';
    password += _uppercase[random.nextInt(_uppercase.length)];
    password += _lowercase[random.nextInt(_lowercase.length)];
    password += _numbers[random.nextInt(_numbers.length)];
    password += _special[random.nextInt(_special.length)];
    
    for (int i = password.length; i < length; i++) {
      password += chars[random.nextInt(chars.length)];
    }
    
    final passwordList = password.split('')..shuffle(random);
    return passwordList.join();
  }

  static String generateFromName(String firstname, String lastname) {
    final random = Random.secure();
    final first = firstname.isNotEmpty ? firstname.substring(0, min(3, firstname.length)) : 'Drx';
    final last = lastname.isNotEmpty ? lastname.substring(0, min(2, lastname.length)) : 'Us';
    final numbers = List.generate(3, (_) => random.nextInt(10)).join();
    final special = _special[random.nextInt(_special.length)];
    
    return 'DRX${first.capitalize()}${last.capitalize()}$numbers$special';
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }
}
