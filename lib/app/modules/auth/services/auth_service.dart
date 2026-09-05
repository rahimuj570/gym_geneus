import 'dart:convert';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

import '../../../constants/appconstants.dart';

import '../models/signupmodel.dart';
import '../models/usermodel.dart';

class AuthProvider {
  final String _baseUrl = AppConstants.baseUrl;
  final GetStorage box = GetStorage();
  final RxString emaill = "".obs;
  final RxString password = "".obs;
  final String refreshtoken = ""; // single storage instance

  // login
  Future<String> login(UserModel user) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/accounts/login/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(user.toJson()),
      );

      print(response.statusCode);
      print(response.body);
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

  Future<bool> refreshAccessToken() async {
    final refreshToken = box.read('refreshToken');

    if (refreshToken == null || refreshToken.toString().isEmpty) {
      print('No refresh token found. Forcing logout...');
      _forceLogout();
      return false;
    }

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/accounts/token/refresh/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh': refreshToken}),
      );

      print('Token refresh status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final newAccessToken = data['access'];
        final newRefreshToken = data['refresh']; // token rotation support

        if (newAccessToken != null) {
          box.write('loginToken', newAccessToken);
          // If the server rotates refresh tokens, save the new one too
          if (newRefreshToken != null) {
            box.write('refreshToken', newRefreshToken);
          }
          print('Access token refreshed successfully');
          return true;
        }
      } else {
        // 400/401 from refresh endpoint means the refresh token itself is expired
        print('Refresh token expired (${response.statusCode}). Forcing logout...');
        _forceLogout();
      }
    } catch (e) {
      print('Token refresh error: $e');
    }
    return false;
  }

  /// Clears all stored tokens and redirects to login screen.
  void _forceLogout() {
    box.remove('loginToken');
    box.remove('refreshToken');
    box.remove('actionToken');
    Get.offAllNamed('/login');
  }

  // register
  Future<String> register(SignupModel newuser) async {
    try {
      print(_baseUrl);
      final response = await http.post(
        Uri.parse('$_baseUrl/accounts/register/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(newuser.toJson()),
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
      final response = await http.post(
        Uri.parse('$_baseUrl/accounts/verify-email/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'otp': otp}),
      );
      print(response.statusCode);
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

  // otpactivate
  Future<String> otpActivate(String email, String otp) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/verify_otp/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'otp': otp,
          'action': "password_reset",
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['action_token'];
        print(token);
        if (token != null) box.write('actionToken', token);
        return "success";
      }
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      if (data is Map) {
        if (data.containsKey('detail')) return data['detail'].toString();
        if (data.containsKey('error')) return data['error'].toString();
      }
      return "OTP verification failed. Please try again.";
    } catch (e) {
      print('OTP Activation error: $e');
      return e.toString();
    }
  }

  // resend otp
  Future<String> resendOtp(String email) async {
    try {
      print(email);
      final r = await http.post(
        Uri.parse('$_baseUrl/accounts/email-verification/resend/'),
        body: {'email': email},
      );
      if (r.statusCode == 200) return "success";
      final data = jsonDecode(utf8.decode(r.bodyBytes));
      if (data is Map && data.containsKey('detail')) return data['detail'].toString();
      return "Failed to resend OTP. Please try again.";
    } catch (e) {
      return e.toString();
    }
  }

  // reset pass req
  Future<String> resetPassword(String email) async {
    try {
      print(email);
      final r = await http.post(
        Uri.parse('$_baseUrl/auth/request_password_reset/'),
        body: {'email': email},
      );
      if (r.statusCode == 200) return "success";
      final data = jsonDecode(utf8.decode(r.bodyBytes));
      if (data is Map) {
        if (data.containsKey('detail')) return data['detail'].toString();
        if (data.containsKey('email')) {
          final err = data['email'];
          return (err is List && err.isNotEmpty) ? err[0].toString() : err.toString();
        }
      }
      return "Failed to request password reset. Please check your email.";
    } catch (e) {
      return e.toString();
    }
  }

  // set new password
  Future<bool> setNewPassword(String email, String newPassword) async {
    final token = box.read("actionToken");
    print(token);
    final response = await http.post(
      Uri.parse('$_baseUrl/auth/reset_password/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "email": email,
        "new_password": newPassword,
        "action_token": token,
      }),
    );

    if (response.statusCode == 200) {
      print('Password reset successful');
      final data = jsonDecode(response.body);
      if (data['access_token'] != null) {
        box.write('loginToken', data['access_token']);
      }
      return true;
    }
    print('Set password failed: ${response.body}');
    return false;
  }
}


