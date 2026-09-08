import 'dart:convert';
import 'package:flutter_debug_logger/flutter_debug_logger.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../modules/auth/services/auth_service.dart';
import '../modules/auth/views/login.dart';

class ApiClient {
  static final GetStorage _box = GetStorage();
  static final AuthProvider _authProvider = AuthProvider();

  /// Sends request with auto token-refresh on 401 and logs with FlutterDebugLogger.
  static Future<http.Response> _requestWithRetry(
    Method method,
    Uri url,
    String tag,
    Future<http.Response> Function(String? token) requestFn,
  ) async {
    final token = _box.read<String>('loginToken');
    var response = await requestFn(token);

    FlutterDebugLogger.printJsonResponse(
      url: url.toString(),
      method: method,
      tag: tag,
      statusCode: response.statusCode,
      responseBody: response.body,
    );

    if (response.statusCode == 401) {
      print('🔒 401 Unauthorized for $url. Attempting token refresh...');
      final success = await _authProvider.refreshAccessToken();
      if (success) {
        final newToken = _box.read<String>('loginToken');
        print('🔄 Retrying request with refreshed token...');
        response = await requestFn(newToken);

        FlutterDebugLogger.printJsonResponse(
          url: url.toString(),
          method: method,
          tag: '$tag (Retried)',
          statusCode: response.statusCode,
          responseBody: response.body,
        );
      } else {
        print('❌ Token refresh failed. Redirecting to login...');
        _forceLogout();
      }
    }
    return response;
  }

  /// Clears all auth tokens and redirects to the login screen.
  static void _forceLogout() {
    _box.remove('loginToken');
    _box.remove('refreshToken');
    _box.remove('actionToken');
    if (Get.key.currentState != null) {
      Get.offAll(() => Login());
    }
  }

  static Future<http.Response> get(
    Uri url, {
    Map<String, String>? headers,
    String tag = 'ApiClient-GET',
  }) async {
    return _requestWithRetry(Method.GET, url, tag, (token) {
      final requestHeaders = {
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
        ...?headers,
      };
      return http.get(url, headers: requestHeaders);
    });
  }

  static Future<http.Response> post(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
    String tag = 'ApiClient-POST',
  }) async {
    return _requestWithRetry(Method.POST, url, tag, (token) {
      final requestHeaders = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
        ...?headers,
      };
      final encodedBody =
          (body is Map || body is List) ? jsonEncode(body) : body;
      return http.post(
        url,
        headers: requestHeaders,
        body: encodedBody,
        encoding: encoding,
      );
    });
  }

  static Future<http.Response> put(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
    String tag = 'ApiClient-PUT',
  }) async {
    return _requestWithRetry(Method.PUT, url, tag, (token) {
      final requestHeaders = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
        ...?headers,
      };
      final encodedBody =
          (body is Map || body is List) ? jsonEncode(body) : body;
      return http.put(
        url,
        headers: requestHeaders,
        body: encodedBody,
        encoding: encoding,
      );
    });
  }

  static Future<http.Response> patch(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
    String tag = 'ApiClient-PATCH',
  }) async {
    return _requestWithRetry(Method.PATCH, url, tag, (token) {
      final requestHeaders = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
        ...?headers,
      };
      final encodedBody =
          (body is Map || body is List) ? jsonEncode(body) : body;
      return http.patch(
        url,
        headers: requestHeaders,
        body: encodedBody,
        encoding: encoding,
      );
    });
  }

  static Future<http.Response> delete(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
    String tag = 'ApiClient-DELETE',
  }) async {
    return _requestWithRetry(Method.DELETE, url, tag, (token) {
      final requestHeaders = {
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
        ...?headers,
      };
      final encodedBody =
          (body is Map || body is List) ? jsonEncode(body) : body;
      return http.delete(
        url,
        headers: requestHeaders,
        body: encodedBody,
        encoding: encoding,
      );
    });
  }
}
