import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
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
    final headers = {'Content-Type': 'application/json'};
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  MediaType? _imageContentType(String? fileName) {
    if (fileName == null || fileName.isEmpty) return null;

    final lowerFileName = fileName.toLowerCase();
    if (lowerFileName.endsWith('.jpg') || lowerFileName.endsWith('.jpeg')) {
      return MediaType('image', 'jpeg');
    }
    if (lowerFileName.endsWith('.png')) {
      return MediaType('image', 'png');
    }
    if (lowerFileName.endsWith('.gif')) {
      return MediaType('image', 'gif');
    }
    if (lowerFileName.endsWith('.webp')) {
      return MediaType('image', 'webp');
    }

    return null;
  }

  Future<dynamic> get(String endpoint, {String? token}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: _headers(token)
          ..remove('Content-Type'), // Content-Type not required for GET
      );
      return _processResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error occurred: ${e.toString()}');
    }
  }

  Future<dynamic> post(
    String endpoint,
    Map<String, dynamic> body, {
    String? token,
  }) async {
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

  Future<dynamic> put(
    String endpoint,
    Map<String, dynamic> body, {
    String? token,
  }) async {
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

  Future<dynamic> delete(String endpoint, {String? token}) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: _headers(token)..remove('Content-Type'),
      );
      return _processResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error occurred: ${e.toString()}');
    }
  }

  Future<dynamic> postMultipart({
    required String endpoint,
    required Map<String, String> fields,
    String? filePath,
    Uint8List? fileBytes,
    String? fileName,
    String? token,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final request = http.MultipartRequest('POST', uri);

      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      request.fields.addAll(fields);

      if (filePath != null && filePath.isNotEmpty && !kIsWeb) {
        final resolvedFileName =
            fileName ?? filePath.split(RegExp(r'[\\/]')).last;
        request.files.add(
          await http.MultipartFile.fromPath(
            'image',
            filePath,
            filename: resolvedFileName,
            contentType: _imageContentType(resolvedFileName),
          ),
        );
      } else if (fileBytes != null) {
        final resolvedFileName = fileName ?? 'image.jpg';
        request.files.add(
          http.MultipartFile.fromBytes(
            'image',
            fileBytes,
            filename: resolvedFileName,
            contentType: _imageContentType(resolvedFileName),
          ),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      return _processResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error occurred: ${e.toString()}');
    }
  }

  Future<dynamic> putMultipart({
    required String endpoint,
    required Map<String, String> fields,
    String? filePath,
    Uint8List? fileBytes,
    String? fileName,
    String? token,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final request = http.MultipartRequest('PUT', uri);

      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      request.fields.addAll(fields);

      if (filePath != null && filePath.isNotEmpty && !kIsWeb) {
        final resolvedFileName =
            fileName ?? filePath.split(RegExp(r'[\\/]')).last;
        request.files.add(
          await http.MultipartFile.fromPath(
            'image',
            filePath,
            filename: resolvedFileName,
            contentType: _imageContentType(resolvedFileName),
          ),
        );
      } else if (fileBytes != null) {
        final resolvedFileName = fileName ?? 'image.jpg';
        request.files.add(
          http.MultipartFile.fromBytes(
            'image',
            fileBytes,
            filename: resolvedFileName,
            contentType: _imageContentType(resolvedFileName),
          ),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
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
