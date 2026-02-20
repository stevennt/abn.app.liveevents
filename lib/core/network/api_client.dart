import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';

class ApiException implements Exception {
  ApiException(this.message, {this.statusCode, this.body});

  final String message;
  final int? statusCode;
  final dynamic body;

  @override
  String toString() =>
      'ApiException(statusCode: $statusCode, message: $message)';
}

class ApiClient {
  ApiClient({http.Client? client, String? baseUrl})
    : _client = client ?? http.Client(),
      baseUrl = baseUrl ?? AppConfig.apiBaseUrl;

  final http.Client _client;
  final String baseUrl;

  Future<dynamic> get(
    String path, {
    String? bearerToken,
    Map<String, String>? queryParameters,
  }) {
    return _request(
      method: 'GET',
      path: path,
      bearerToken: bearerToken,
      queryParameters: queryParameters,
    );
  }

  Future<dynamic> post(
    String path, {
    String? bearerToken,
    Object? body,
    Map<String, String>? queryParameters,
  }) {
    return _request(
      method: 'POST',
      path: path,
      bearerToken: bearerToken,
      body: body,
      queryParameters: queryParameters,
    );
  }

  Future<dynamic> put(
    String path, {
    String? bearerToken,
    Object? body,
    Map<String, String>? queryParameters,
  }) {
    return _request(
      method: 'PUT',
      path: path,
      bearerToken: bearerToken,
      body: body,
      queryParameters: queryParameters,
    );
  }

  Uri _buildUri(String path, Map<String, String>? queryParameters) {
    final resolved = Uri.parse(baseUrl).resolve(path);
    if (queryParameters == null || queryParameters.isEmpty) {
      return resolved;
    }

    return resolved.replace(
      queryParameters: <String, String>{
        ...resolved.queryParameters,
        ...queryParameters,
      },
    );
  }

  Future<dynamic> _request({
    required String method,
    required String path,
    String? bearerToken,
    Object? body,
    Map<String, String>? queryParameters,
  }) async {
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (bearerToken != null && bearerToken.isNotEmpty)
        'Authorization': 'Bearer $bearerToken',
    };

    final uri = _buildUri(path, queryParameters);

    http.Response response;
    final encodedBody = body == null ? null : jsonEncode(body);

    try {
      switch (method) {
        case 'GET':
          response = await _client
              .get(uri, headers: headers)
              .timeout(AppConfig.requestTimeout);
          break;
        case 'POST':
          response = await _client
              .post(uri, headers: headers, body: encodedBody)
              .timeout(AppConfig.requestTimeout);
          break;
        case 'PUT':
          response = await _client
              .put(uri, headers: headers, body: encodedBody)
              .timeout(AppConfig.requestTimeout);
          break;
        default:
          throw ApiException('Unsupported HTTP method: $method');
      }
    } on ApiException {
      rethrow;
    } on Exception catch (error) {
      throw ApiException('Network error: $error');
    }

    final decoded = _decode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded;
    }

    throw ApiException(
      _extractErrorMessage(decoded, response.statusCode),
      statusCode: response.statusCode,
      body: decoded,
    );
  }

  dynamic _decode(String body) {
    if (body.trim().isEmpty) {
      return <String, dynamic>{};
    }

    try {
      return jsonDecode(body);
    } on FormatException {
      return body;
    }
  }

  String _extractErrorMessage(dynamic decoded, int statusCode) {
    if (decoded is Map<String, dynamic>) {
      final errorValue =
          decoded['error'] ?? decoded['message'] ?? decoded['detail'];
      if (errorValue is String && errorValue.isNotEmpty) {
        return errorValue;
      }
      return 'Request failed ($statusCode)';
    }

    if (decoded is String && decoded.isNotEmpty) {
      return decoded;
    }

    return 'Request failed ($statusCode)';
  }
}
