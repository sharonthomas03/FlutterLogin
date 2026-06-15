import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';

class AuthService {
  static const _storageKey = 'auth_user';

  String get _baseUrl {
    if (kIsWeb) {
      return 'http://localhost:5000';
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'http://10.0.2.2:5000';
      default:
        return 'http://localhost:5000';
    }
  }

  Future<User> login({required String email, required String password}) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email.trim(), 'password': password}),
    );

    return _handleAuthResponse(response);
  }

  Future<User> register({
    required String username,
    required String email,
    required String password,
    String bio = '',
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username.trim(),
        'email': email.trim(),
        'password': password,
        'bio': bio.trim(),
      }),
    );

    return _handleAuthResponse(response);
  }

  Future<User> updateProfile({
    required String token,
    required String username,
    required String email,
    required String bio,
  }) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/api/profile'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'username': username.trim(),
        'email': email.trim(),
        'bio': bio.trim(),
      }),
    );

    final data = _decodeResponse(response);
    if (response.statusCode != 200) {
      throw Exception(data['message'] ?? 'Failed to update profile');
    }

    final updatedUser = User.fromStoredJson({
      ...data['user'] as Map<String, dynamic>,
      'token': token,
    });
    await saveUser(updatedUser);
    return updatedUser;
  }

  Future<User?> getSavedUser() async {
    final preferences = await SharedPreferences.getInstance();
    final rawUser = preferences.getString(_storageKey);
    if (rawUser == null || rawUser.isEmpty) {
      return null;
    }

    return User.fromStoredJson(jsonDecode(rawUser) as Map<String, dynamic>);
  }

  Future<void> saveUser(User user) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_storageKey, jsonEncode(user.toJson()));
  }

  Future<void> logout() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_storageKey);
  }

  Future<User> _handleAuthResponse(http.Response response) async {
    final data = _decodeResponse(response);
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(data['message'] ?? 'Request failed');
    }

    final user = User.fromAuthJson(data);
    await saveUser(user);
    return user;
  }

  Map<String, dynamic> _decodeResponse(http.Response response) {
    final body = response.body.trim();
    if (body.isEmpty) {
      return {};
    }

    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    throw Exception('Unexpected server response');
  }
}
