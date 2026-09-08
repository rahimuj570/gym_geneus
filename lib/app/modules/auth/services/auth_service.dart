import 'dart:async';
import 'dart:convert';
import 'package:flutter_debug_logger/flutter_debug_logger.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

import '../../../constants/appconstants.dart';

import '../models/signupmodel.dart';
import '../models/usermodel.dart';
import '../views/login.dart';

class AuthProvider {
  final String _baseUrl = AppConstants.baseUrl;
  final GetStorage box = GetStorage();
  final RxString emaill = "".obs;
  final RxString password = "".obs;
  final String refreshtoken = ""; // single storage instance

  // login
  Future<String> login(UserModel user) async {
    try {
      final url = '$_baseUrl/accounts/login/';
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(user.toJson()),
      );

      FlutterDebugLogger.printJsonResponse(
        url: url,
        method: Method.POST,
        tag: 'Auth-Login',
        statusCode: response.statusCode,
        responseBody: response.body,
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final token = data['access'];
        final refresh = data['refresh'];

        if (token != null) box.write('loginToken', token);
        if (refresh != null) box.write('refreshToken', refresh);

        return "success"; // 👉 CLEAR SUCCESS FLAG
      }

      // 🔥 RETURN USER FRIENDLY SERVER ERROR MESSAGE IF EXISTS
      if (data is Map && data.containsKey('detail')) {
        final detailMsg = data['detail'].toString();
        if (detailMsg.toLowerCase().contains("no active account") ||
            detailMsg.toLowerCase().contains("given credentials") ||
            detailMsg.toLowerCase().contains("invalid credentials") ||
            detailMsg.toLowerCase().contains("incorrect password") ||
            detailMsg.toLowerCase().contains("wrong password")) {
          return "Incorrect email or password. Please try again.";
        }
        return detailMsg;
      }

      // fallback error
      return "Incorrect email or password. Please try again.";
    } catch (e) {
      print('Login error: $e');
      return e.toString();
    }
  }

  static Completer<bool>? _refreshCompleter;

  Future<bool> refreshAccessToken() async {
    // If a refresh request is already in progress, await the existing one to avoid token race condition
    if (_refreshCompleter != null && !_refreshCompleter!.isCompleted) {
      print('⏳ Refresh token request already in progress, awaiting existing result...');
      return _refreshCompleter!.future;
    }

    _refreshCompleter = Completer<bool>();

    final refreshToken = box.read<String>('refreshToken');

    if (refreshToken == null || refreshToken.toString().trim().isEmpty) {
      print('⚠️ No refresh token found in storage.');
      _refreshCompleter!.complete(false);
      _refreshCompleter = null;
      return false;
    }

    try {
      final url = '$_baseUrl/accounts/token/refresh/';
      print('🔄 Refreshing access token via $url...');
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'refresh': refreshToken.trim()}),
      );

      FlutterDebugLogger.printJsonResponse(
        url: url,
        method: Method.POST,
        tag: 'Auth-RefreshToken',
        statusCode: response.statusCode,
        responseBody: response.body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final String? newAccessToken =
            (data['access'] ?? data['access_token'])?.toString();
        final String? newRefreshToken =
            (data['refresh'] ?? data['refresh_token'])?.toString();

        if (newAccessToken != null && newAccessToken.isNotEmpty) {
          box.write('loginToken', newAccessToken);
          if (newRefreshToken != null && newRefreshToken.isNotEmpty) {
            box.write('refreshToken', newRefreshToken);
          }
          print('✅ Access token refreshed successfully.');
          _refreshCompleter!.complete(true);
          _refreshCompleter = null;
          return true;
        }
      }

      print('❌ Refresh token expired or rejected (${response.statusCode}).');
      // If 400 or 401, refresh token is expired or invalid
      if (response.statusCode == 400 || response.statusCode == 401) {
        _forceLogout();
      }
    } catch (e) {
      print('❌ Token refresh network/parsing error: $e');
    }

    _refreshCompleter!.complete(false);
    _refreshCompleter = null;
    return false;
  }

  /// Clears all stored tokens and redirects to login screen.
  void _forceLogout() {
    box.remove('loginToken');
    box.remove('refreshToken');
    box.remove('actionToken');
    if (Get.key.currentState != null) {
      Get.offAll(() => Login());
    }
  }

  // register
  Future<String> register(SignupModel newuser) async {
    try {
      final url = '$_baseUrl/accounts/register/';
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(newuser.toJson()),
      );

      FlutterDebugLogger.printJsonResponse(
        url: url,
        method: Method.POST,
        tag: 'Auth-Register',
        statusCode: response.statusCode,
        responseBody: response.body,
      );

      emaill.value = newuser.email;
      password.value = newuser.password;
      if (response.statusCode == 201 || response.statusCode == 200) {
        return "success";
      }

      final data = jsonDecode(utf8.decode(response.bodyBytes));
      if (data is Map) {
        if (data.containsKey('email')) {
          final err = data['email'];
          final emailErrMsg = (err is List && err.isNotEmpty) ? err[0].toString() : err.toString();
          if (emailErrMsg.toLowerCase().contains("already exist") || emailErrMsg.toLowerCase().contains("registered")) {
            return "An account with this email address already exists.";
          }
          return emailErrMsg;
        }
        if (data.containsKey('detail')) {
          return data['detail'].toString();
        }
        if (data.containsKey('password')) {
          final err = data['password'];
          return (err is List && err.isNotEmpty) ? err[0].toString() : err.toString();
        }
        if (data.containsKey('non_field_errors')) {
          final err = data['non_field_errors'];
          return (err is List && err.isNotEmpty) ? err[0].toString() : err.toString();
        }
      }
      return "Registration failed. Please try again.";
    } catch (e) {
      print('Register error: $e');
      return e.toString();
    }
  }

  Future<String> activateAccount(String email, String otp) async {
    try {
      final url = '$_baseUrl/accounts/verify-email/';
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'otp': otp}),
      );

      FlutterDebugLogger.printJsonResponse(
        url: url,
        method: Method.POST,
        tag: 'Auth-VerifyEmail',
        statusCode: response.statusCode,
        responseBody: response.body,
      );

      if (response.statusCode == 200) {
        await login(UserModel(email: emaill.value, password: password.value));
        return "success";
      }
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      if (data is Map) {
        if (data.containsKey('detail')) return data['detail'].toString();
        if (data.containsKey('otp')) {
          final err = data['otp'];
          return (err is List && err.isNotEmpty) ? err[0].toString() : err.toString();
        }
        if (data.containsKey('error')) return data['error'].toString();
      }
      return "Invalid or expired OTP code.";
    } catch (e) {
      print('Activation error: $e');
      return e.toString();
    }
  }

  // check OTP for password reset or other purposes
  Future<String> checkOtp({
    required String email,
    required String otp,
    String purpose = "password_reset",
  }) async {
    try {
      final url = '$_baseUrl/accounts/check-otp/';
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'otp': otp,
          'purpose': purpose,
        }),
      );

      FlutterDebugLogger.printJsonResponse(
        url: url,
        method: Method.POST,
        tag: 'Auth-CheckOTP',
        statusCode: response.statusCode,
        responseBody: response.body,
      );

      final data = jsonDecode(utf8.decode(response.bodyBytes));
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (data is Map) {
          if (data['is_valid'] == true) {
            return "success";
          }
          if (data['is_valid'] == false) {
            return data['message']?.toString() ?? "Invalid or expired OTP code.";
          }
        }
        return "success";
      }

      if (data is Map) {
        if (data.containsKey('detail')) return data['detail'].toString();
        if (data.containsKey('message')) return data['message'].toString();
        if (data.containsKey('otp')) {
          final err = data['otp'];
          return (err is List && err.isNotEmpty) ? err[0].toString() : err.toString();
        }
        if (data.containsKey('email')) {
          final err = data['email'];
          return (err is List && err.isNotEmpty) ? err[0].toString() : err.toString();
        }
        if (data.containsKey('error')) return data['error'].toString();
        if (data.containsKey('non_field_errors')) {
          final err = data['non_field_errors'];
          return (err is List && err.isNotEmpty) ? err[0].toString() : err.toString();
        }
      }
      return "Invalid or expired OTP code.";
    } catch (e) {
      print('Check OTP error: $e');
      return e.toString();
    }
  }

  // verify email OTP for signup/activation
  Future<String> verifyEmailOtp(String email, String otp) async {
    try {
      final url = '$_baseUrl/accounts/verify-email/';
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'otp': otp,
        }),
      );

      FlutterDebugLogger.printJsonResponse(
        url: url,
        method: Method.POST,
        tag: 'Auth-VerifyEmailOTP',
        statusCode: response.statusCode,
        responseBody: response.body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return "success";
      }

      final data = jsonDecode(utf8.decode(response.bodyBytes));
      if (data is Map) {
        if (data.containsKey('detail')) return data['detail'].toString();
        if (data.containsKey('message')) return data['message'].toString();
        if (data.containsKey('otp')) {
          final err = data['otp'];
          return (err is List && err.isNotEmpty) ? err[0].toString() : err.toString();
        }
        if (data.containsKey('email')) {
          final err = data['email'];
          return (err is List && err.isNotEmpty) ? err[0].toString() : err.toString();
        }
        if (data.containsKey('error')) return data['error'].toString();
        if (data.containsKey('non_field_errors')) {
          final err = data['non_field_errors'];
          return (err is List && err.isNotEmpty) ? err[0].toString() : err.toString();
        }
      }
      return "Invalid or expired OTP code.";
    } catch (e) {
      print('Verify OTP error: $e');
      return e.toString();
    }
  }

  // legacy otpActivate
  Future<String> otpActivate(String email, String otp) async {
    return checkOtp(email: email, otp: otp, purpose: "password_reset");
  }

  // resend otp
  Future<String> resendOtp(String email) async {
    try {
      final url = '$_baseUrl/accounts/email-verification/resend/';
      final r = await http.post(
        Uri.parse(url),
        body: {'email': email},
      );

      FlutterDebugLogger.printJsonResponse(
        url: url,
        method: Method.POST,
        tag: 'Auth-ResendOTP',
        statusCode: r.statusCode,
        responseBody: r.body,
      );

      if (r.statusCode == 200) return "success";
      final data = jsonDecode(utf8.decode(r.bodyBytes));
      if (data is Map && data.containsKey('detail')) return data['detail'].toString();
      return "Failed to resend OTP. Please try again.";
    } catch (e) {
      return e.toString();
    }
  }

  // reset password request (OTP sent to email)
  Future<String> resetPassword(String email, {String purpose = "password_reset"}) async {
    try {
      final url = '$_baseUrl/accounts/password-reset/';
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'purpose': purpose,
        }),
      );

      FlutterDebugLogger.printJsonResponse(
        url: url,
        method: Method.POST,
        tag: 'Auth-RequestPasswordReset',
        statusCode: response.statusCode,
        responseBody: response.body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return "success";
      }

      final data = jsonDecode(utf8.decode(response.bodyBytes));
      if (data is Map) {
        if (data.containsKey('detail')) return data['detail'].toString();
        if (data.containsKey('message')) return data['message'].toString();
        if (data.containsKey('email')) {
          final err = data['email'];
          return (err is List && err.isNotEmpty) ? err[0].toString() : err.toString();
        }
        if (data.containsKey('error')) return data['error'].toString();
        if (data.containsKey('non_field_errors')) {
          final err = data['non_field_errors'];
          return (err is List && err.isNotEmpty) ? err[0].toString() : err.toString();
        }
      }
      return "Failed to request password reset. Please check your email.";
    } catch (e) {
      print('Password reset request error: $e');
      return e.toString();
    }
  }

  // reset password confirm with OTP + new password
  Future<String> resetPasswordConfirm({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    try {
      final url = '$_baseUrl/accounts/password-reset-confirm/';
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'otp': otp,
          'new_password': newPassword,
        }),
      );

      FlutterDebugLogger.printJsonResponse(
        url: url,
        method: Method.POST,
        tag: 'Auth-PasswordResetConfirm',
        statusCode: response.statusCode,
        responseBody: response.body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return "success";
      }

      final data = jsonDecode(utf8.decode(response.bodyBytes));
      if (data is Map) {
        if (data.containsKey('detail')) return data['detail'].toString();
        if (data.containsKey('message')) return data['message'].toString();
        if (data.containsKey('otp')) {
          final err = data['otp'];
          return (err is List && err.isNotEmpty) ? err[0].toString() : err.toString();
        }
        if (data.containsKey('new_password')) {
          final err = data['new_password'];
          return (err is List && err.isNotEmpty) ? err[0].toString() : err.toString();
        }
        if (data.containsKey('email')) {
          final err = data['email'];
          return (err is List && err.isNotEmpty) ? err[0].toString() : err.toString();
        }
        if (data.containsKey('error')) return data['error'].toString();
        if (data.containsKey('non_field_errors')) {
          final err = data['non_field_errors'];
          return (err is List && err.isNotEmpty) ? err[0].toString() : err.toString();
        }
      }
      return "Password reset failed. Please check your OTP and try again.";
    } catch (e) {
      print('Password reset confirm error: $e');
      return e.toString();
    }
  }

  // legacy / fallback set new password
  Future<bool> setNewPassword(String email, String newPassword) async {
    final token = box.read("actionToken");
    final url = '$_baseUrl/auth/reset_password/';
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "email": email,
        "new_password": newPassword,
        "action_token": token,
      }),
    );

    FlutterDebugLogger.printJsonResponse(
      url: url,
      method: Method.POST,
      tag: 'Auth-ResetPassword',
      statusCode: response.statusCode,
      responseBody: response.body,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['access_token'] != null) {
        box.write('loginToken', data['access_token']);
      }
      return true;
    }
    return false;
  }
}



