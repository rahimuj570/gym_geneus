import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../modules/auth/services/auth_service.dart';

class ApiClient {
  static final GetStorage _box = GetStorage();
  static final AuthProvider _authProvider = AuthProvider();

  /// Sends request with auto token-refresh on 401.
  /// If refresh also fails (refresh token expired), clears tokens and
  /// navigates to login so the user can re-authenticate.
  static Future<http.Response> _requestWithRetry(
    Future<http.Response> Function(String? token) requestFn,
  ) async {
    final token = _box.read<String>('loginToken');
    var response = await requestFn(token);

    if (response.statusCode == 401) {
      print('Token expired (401). Attempting to refresh token...');
      final success = await _authProvider.refreshAccessToken();
      if (success) {
        final newToken = _box.read<String>('loginToken');
        print('Token refreshed successfully. Retrying request...');
        response = await requestFn(newToken);
      } else {
        print('Token refresh failed. Logging user out...');
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
    // Navigate to login, removing all routes
    Get.offAllNamed('/login');
  }

  static Future<http.Response> get(Uri url,
      {Map<String, String>? headers}) async {
    return _requestWithRetry((token) {
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
  }) async {
    return _requestWithRetry((token) {
      final requestHeaders = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
        ...?headers,
      };
      return http.post(
        url,
        headers: requestHeaders,
        body: body,
        encoding: encoding,
      );
    });
  }

  static Future<http.Response> put(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) async {
    return _requestWithRetry((token) {
      final requestHeaders = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
        ...?headers,
      };
      return http.put(
        url,
        headers: requestHeaders,
        body: body,
        encoding: encoding,
      );
    });
  }

  static Future<http.Response> patch(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) async {
    return _requestWithRetry((token) {
      final requestHeaders = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
        ...?headers,
      };
      return http.patch(
        url,
        headers: requestHeaders,
        body: body,
        encoding: encoding,
      );
    });
  }

  static Future<http.Response> delete(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) async {
    return _requestWithRetry((token) {
      final requestHeaders = {
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
        ...?headers,
      };
      return http.delete(
        url,
        headers: requestHeaders,
        body: body,
        encoding: encoding,
      );
    });
  }
}
