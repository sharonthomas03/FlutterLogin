import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const String _userKey = 'auth_user';

  Future<Map<String, dynamic>?> getSavedUserJson() async {
    final preferences = await SharedPreferences.getInstance();
    final rawUser = preferences.getString(_userKey);
    if (rawUser == null || rawUser.isEmpty) {
      return null;
    }
    return jsonDecode(rawUser) as Map<String, dynamic>;
  }

  Future<void> saveUserJson(Map<String, dynamic> userJson) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_userKey, jsonEncode(userJson));
  }

  Future<void> clearUser() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_userKey);
  }
}
