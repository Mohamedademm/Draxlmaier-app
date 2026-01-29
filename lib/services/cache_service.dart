import 'package:hive_flutter/hive_flutter.dart';
import 'dart:convert';

class CacheService {
  static const String _cacheBoxName = 'cache';
  
  Box get _box => Hive.box(_cacheBoxName);

  // --- Generic Methods ---

  Future<void> saveData(String key, dynamic data) async {
    // If data is a list or map, we encode it to ensure Hive compatibility 
    // without complex adapters for now
    await _box.put(key, jsonEncode(data));
  }

  dynamic getData(String key) {
    final data = _box.get(key);
    if (data != null && data is String) {
      try {
        return jsonDecode(data);
      } catch (e) {
        return data; // Return as is if not valid JSON
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

  // --- Specific Cache Keys ---
  
  static String chatHistoryKey(String chatId) => 'chat_history_$chatId';
  static String get userProfileKey => 'user_profile';
  static String get allUsersKey => 'all_users';
  static String get departmentGroupsKey => 'department_groups';
}
