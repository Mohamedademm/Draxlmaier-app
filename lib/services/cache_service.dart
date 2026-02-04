import 'package:hive_flutter/hive_flutter.dart';
import 'dart:convert';

class CacheService {
  static const String _cacheBoxName = 'cache';
  
  Box get _box => Hive.box(_cacheBoxName);


  Future<void> saveData(String key, dynamic data) async {
    await _box.put(key, jsonEncode(data));
  }

  dynamic getData(String key) {
    final data = _box.get(key);
    if (data != null && data is String) {
      try {
        return jsonDecode(data);
      } catch (e) {
        return data;
      }
    }
    return data;
  }

  Future<void> clearKey(String key) async {
    await _box.delete(key);
  }

  Future<void> clearAll() async {
    await _box.clear();
  }

  
  static String chatHistoryKey(String chatId) => 'chat_history_$chatId';
  static String get userProfileKey => 'user_profile';
  static String get allUsersKey => 'all_users';
  static String get departmentGroupsKey => 'department_groups';
}
