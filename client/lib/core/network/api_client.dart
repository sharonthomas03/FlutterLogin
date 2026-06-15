import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'api_exceptions.dart';

class ApiClient {
  String get baseUrl {
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

  Map<String, String> _headers(String? token) {
    final headers = {
      'Content-Type': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> body, {String? token}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: _headers(token),
        body: jsonEncode(body),
      );
      return _processResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error occurred: ${e.toString()}');
    }
  }

  Future<dynamic> put(String endpoint, Map<String, dynamic> body, {String? token}) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: _headers(token),
        body: jsonEncode(body),
      );
      return _processResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error occurred: ${e.toString()}');
    }
  }

  dynamic _processResponse(http.Response response) {
    final body = response.body.trim();
    final decoded = body.isNotEmpty ? jsonDecode(body) : {};

    if (response.statusCode == 200 || response.statusCode == 201) {
      return decoded;
    } else {
      final message = (decoded is Map && decoded['message'] != null)
          ? decoded['message'].toString()
          : 'Request failed with status: ${response.statusCode}';
      throw ApiException(message, response.statusCode);
    }
  }
}
