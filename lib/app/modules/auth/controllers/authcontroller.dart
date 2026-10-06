import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_debug_logger/flutter_debug_logger.dart';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:http/http.dart' as http;
import 'package:kenzeno/app/constants/push_notification.dart';
import 'package:kenzeno/app/modules/auth/views/otp.dart';
import 'package:kenzeno/app/modules/home/views/navbar.dart';
import 'package:kenzeno/app/modules/setup/views/setup.dart';

import '../../../constants/appconstants.dart';

import '../../../res/colors/colors.dart';

import '../../../res/fonts/textstyle.dart';

import '../models/signupmodel.dart';
import '../models/usermodel.dart';
import '../services/auth_service.dart';
import 'package:kenzeno/app/modules/setting/service/setting_service.dart';
import 'package:toastification/toastification.dart';
import 'package:kenzeno/app/widgets/custom_snackbar.dart';

class Authcontroller extends GetxController {
  RxBool ischecked = false.obs;
  final storage = GetStorage();
  final RxString frompage = "".obs;

  // Login controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // Dedicated Signup controllers (completely isolated from Login)
  final signupNameController = TextEditingController();
  final signupEmailController = TextEditingController();
  final signupPasswordController = TextEditingController();
  final signupConfirmPasswordController = TextEditingController();

  // Dedicated Forgot Password controller
  final forgotEmailController = TextEditingController();

  // Legacy aliases
  TextEditingController get namecontroller => signupNameController;
  TextEditingController get confirmpasswordController => signupConfirmPasswordController;

  final TextEditingController countryController = TextEditingController();
  final isLoading = false.obs;
  final isLoadingsignup = false.obs;
  final isLoadingpass = false.obs;
  final isLoadingverify = false.obs;
  final isLoadingresend = false.obs;
  final isLoadingnewpass = false.obs;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final String _baseUrl = AppConstants.baseUrl;

  final isloadinggmail = false.obs;
  final _authProvider = AuthProvider();
  String registeredEmail = '';

  @override
  void onInit() {
    super.onInit();
    final refreshToken = storage.read('refreshToken');
    if (refreshToken != null && refreshToken.toString().isNotEmpty) {
      _authProvider.refreshAccessToken();
    }
    final savedEmail = storage.read<String>('email');
    final savedPassword = storage.read<String>('password');
    if (savedEmail != null && savedPassword != null) {
      emailController.text = savedEmail;
      passwordController.text = savedPassword;
      ischecked.value = true;
    }
  }

  void _validateInputs({required bool isLogin}) {
    if (isLogin) {
      final email = emailController.text.trim();
      final password = passwordController.text.trim();

      if (email.isEmpty) {
        throw 'Email cannot be empty';
      }
      if (!GetUtils.isEmail(email)) {
        throw 'Please enter a valid email address';
      }
      if (password.isEmpty) {
        throw 'Password cannot be empty';
      }
      return;
    } else {
      final name = signupNameController.text.trim();
      final email = signupEmailController.text.trim();
      final password = signupPasswordController.text.trim();
      final confirmPass = signupConfirmPasswordController.text.trim();

      if (name.isEmpty) {
        throw 'Name cannot be empty';
      }
      if (email.isEmpty) {
        throw 'Email cannot be empty';
      }
      if (!GetUtils.isEmail(email)) {
        throw 'Please enter a valid email address';
      }
      if (password.isEmpty) {
        throw 'Password cannot be empty';
      }
      if (confirmPass.isEmpty) {
        throw 'Confirm password cannot be empty';
      }
      if (password != confirmPass) {
        throw 'Passwords do not match';
      }
      if (password.length < 6) {
        throw 'Password must be at least 6 characters';
      }
    }
  }

  void clearSignupFields() {
    signupNameController.clear();
    signupEmailController.clear();
    signupPasswordController.clear();
    signupConfirmPasswordController.clear();
  }

  void clearLoginFields() {
    emailController.clear();
    passwordController.clear();
  }

  void clearAllControllers({bool preserveRemembered = false}) {
    clearSignupFields();
    forgotEmailController.clear();
    countryController.clear();
    registeredEmail = '';
    frompage.value = '';

    if (preserveRemembered && ischecked.value) {
      final savedEmail = storage.read<String>('email');
      final savedPassword = storage.read<String>('password');
      emailController.text = savedEmail ?? '';
      passwordController.text = savedPassword ?? '';
    } else {
      clearLoginFields();
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      if (account == null) {
        toastification.show(
          type: ToastificationType.warning,
          style: ToastificationStyle.fillColored,
          primaryColor: Colors.orange,
          foregroundColor: Colors.white,
          title: Text(
            'Google Login Cancelled',
            style: AppTextStyles.poppinsBold.copyWith(color: Colors.white),
          ),
          description: Text(
            'Google login was cancelled',
            style: AppTextStyles.poppinsRegular.copyWith(color: Colors.white),
          ),
          alignment: Alignment.topRight,
          autoCloseDuration: const Duration(seconds: 4),
          borderRadius: BorderRadius.circular(12),
          showProgressBar: true,
        );
        return;
      }

      final String name = account.displayName ?? '';
      final String email = account.email;
      isloadinggmail.value = true;

      final url = '$_baseUrl/accounts/login-social/';
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "name": name,
          "email": email,
          "auth_provider": "google",
        }),
      );

      FlutterDebugLogger.printJsonResponse(
        url: url,
        method: Method.POST,
        tag: 'Auth-GoogleSocialLogin',
        statusCode: response.statusCode,
        responseBody: response.body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final box = GetStorage();
        if (data['refresh'] != null) {
          box.write('refreshToken', data['refresh']);
        }
        if (data['access'] != null) {
          box.write('loginToken', data['access']);
        }

        clearAllControllers(preserveRemembered: false);

        toastification.show(
          type: ToastificationType.success,
          style: ToastificationStyle.fillColored,
          primaryColor: AppColor.green16A34A,
          foregroundColor: Colors.white,
          title: Text(
            'Success',
            style: AppTextStyles.poppinsBold.copyWith(color: Colors.white),
          ),
          description: Text(
            'Google login successful',
            style: AppTextStyles.poppinsRegular.copyWith(color: Colors.white),
          ),
          alignment: Alignment.topRight,
          autoCloseDuration: const Duration(seconds: 4),
          borderRadius: BorderRadius.circular(12),
          showProgressBar: true,
        );

        try {
          await syncFCMToken().timeout(const Duration(seconds: 5));
        } catch (e) {
          print("⚠️ FCM sync failed on Google login: $e");
        }

        try {
          final profile = await SettingService().fetchProfile();
          if (profile.hasMissingProfileFields) {
            Get.offAll(() => Setup(), transition: Transition.rightToLeft);
            return;
          }
        } catch (e) {
          print("Error checking profile on Google login: $e");
        }

        Get.offAll(() => Navbar(), transition: Transition.rightToLeft);
      } else {
        toastification.show(
          type: ToastificationType.error,
          style: ToastificationStyle.fillColored,
          primaryColor: Colors.red,
          foregroundColor: Colors.white,
          title: Text(
            'Error',
            style: AppTextStyles.poppinsBold.copyWith(color: Colors.white),
          ),
          description: Text(
            'Google login failed: ${response.body}',
            style: AppTextStyles.poppinsRegular.copyWith(color: Colors.white),
          ),
          alignment: Alignment.topRight,
          autoCloseDuration: const Duration(seconds: 4),
          borderRadius: BorderRadius.circular(12),
          showProgressBar: true,
        );
      }
    } catch (e) {
      toastification.show(
        type: ToastificationType.info,
        style: ToastificationStyle.fillColored,
        primaryColor: AppColor.green16A34A,
        foregroundColor: Colors.white,
        title: Text(
          'Exception',
          style: AppTextStyles.poppinsBold.copyWith(color: Colors.white),
        ),
        description: Text(
          'An error occurred: $e',
          style: AppTextStyles.poppinsRegular.copyWith(color: Colors.white),
        ),
        alignment: Alignment.topRight,
        autoCloseDuration: const Duration(seconds: 4),
        borderRadius: BorderRadius.circular(12),
        showProgressBar: true,
      );
    } finally {
      isloadinggmail.value = false;
    }
  }

  Future<void> login() async {
    try {
      _validateInputs(isLogin: true);
      isLoading.value = true;

      final user = UserModel(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final result = await _authProvider.login(user);

      if (result == "success") {
        if (ischecked.value) {
          storage.write('email', user.email);
          storage.write('password', user.password);
        } else {
          storage.remove('email');
          storage.remove('password');
        }

        clearAllControllers(preserveRemembered: false);
        CustomSnackbar.showSuccess('Login successful! Welcome back.');

        try {
          await syncFCMToken().timeout(
            const Duration(seconds: 5),
          ); // don't block longer than 5s
        } catch (e) {
          print("⚠️ FCM token sync failed or timed out: $e");
        }

        try {
          final profile = await SettingService().fetchProfile();
          if (profile.hasMissingProfileFields) {
            Get.offAll(() => Setup(), transition: Transition.rightToLeft);
            return;
          }
        } catch (e) {
          print("Error checking profile on login: $e");
        }

        Get.offAll(() => Navbar(), transition: Transition.rightToLeft);
      } else {
        CustomSnackbar.showError(result);
      }
    } catch (e) {
      CustomSnackbar.showError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> register() async {
    try {
      _validateInputs(isLogin: false);
      isLoadingsignup.value = true;

      final newuser = SignupModel(
        name: signupNameController.text.trim(),
        email: signupEmailController.text.trim(),
        password: signupPasswordController.text.trim(),
      );

      final result = await _authProvider.register(newuser);

      if (result == "success") {
        registeredEmail = newuser.email;
        final verifyEmail = signupEmailController.text.trim();
        clearSignupFields();

        CustomSnackbar.showSuccess(
          'Registration successful! Please verify your OTP code.',
        );
        Get.offAll(
          OtpVerification(email: verifyEmail, fromPage: "signup"),
          transition: Transition.rightToLeft,
        );
      } else {
        CustomSnackbar.showError(result);
      }
    } catch (e) {
      CustomSnackbar.showError(e.toString());
    } finally {
      isLoadingsignup.value = false;
    }
  }

  Future<void> activateAccount(String otp) async {
    final trimmedOtp = otp.trim();
    if (trimmedOtp.isEmpty) {
      CustomSnackbar.showError('Please enter the verification code');
      return;
    }
    if (trimmedOtp.length != 4) {
      CustomSnackbar.showError('Please enter the complete 4-digit verification code');
      return;
    }

    try {
      isLoadingverify.value = true;

      if (frompage.value == "signup") {
        final result = await _authProvider.activateAccount(
          registeredEmail.isNotEmpty ? registeredEmail : signupEmailController.text.trim(),
          trimmedOtp,
        );
        if (result == "success") {
          clearAllControllers(preserveRemembered: false);
          CustomSnackbar.showSuccess('Account activated successfully!');

          try {
            await syncFCMToken().timeout(const Duration(seconds: 5));
          } catch (e) {
            print("⚠️ FCM sync failed on activation: $e");
          }

          Get.offAll(Setup(), transition: Transition.rightToLeft);
        } else {
          CustomSnackbar.showError(result);
        }
      }
    } catch (e) {
      CustomSnackbar.showError(e.toString());
    } finally {
      isLoadingverify.value = false;
    }
  }

  Future<bool> verifyOtpForPasswordReset(String email, String otp) async {
    final trimmedOtp = otp.trim();
    final trimmedEmail = email.trim().isNotEmpty
        ? email.trim()
        : (registeredEmail.isNotEmpty ? registeredEmail : forgotEmailController.text.trim());

    if (trimmedEmail.isEmpty) {
      CustomSnackbar.showError('Email is required');
      return false;
    }
    if (trimmedOtp.isEmpty) {
      CustomSnackbar.showError('Please enter the verification code');
      return false;
    }
    if (trimmedOtp.length != 4) {
      CustomSnackbar.showError('Please enter the complete 4-digit verification code');
      return false;
    }

    try {
      isLoadingverify.value = true;
      final result = await _authProvider.checkOtp(
        email: trimmedEmail,
        otp: trimmedOtp,
        purpose: "password_reset",
      );

      if (result == "success") {
        CustomSnackbar.showSuccess('OTP verified successfully!');
        return true;
      } else {
        CustomSnackbar.showError(result);
        return false;
      }
    } catch (e) {
      CustomSnackbar.showError(e.toString());
      return false;
    } finally {
      isLoadingverify.value = false;
    }
  }

  Future<void> resendOtp({String? email}) async {
    final targetEmail = email ??
        (registeredEmail.isNotEmpty
            ? registeredEmail
            : (signupEmailController.text.trim().isNotEmpty
                ? signupEmailController.text.trim()
                : forgotEmailController.text.trim()));

    if (targetEmail.isEmpty) {
      CustomSnackbar.showError('Email is required to resend OTP');
      return;
    }
    try {
      isLoadingresend.value = true;
      String result;
      if (frompage.value == "signup") {
        result = await _authProvider.resendOtp(targetEmail);
      } else {
        result = await _authProvider.resetPassword(
          targetEmail,
          purpose: "password_reset",
        );
      }

      if (result == "success") {
        CustomSnackbar.showInfo('A new OTP code has been sent to your email.');
      } else {
        CustomSnackbar.showError(result);
      }
    } catch (e) {
      CustomSnackbar.showError(e.toString());
    } finally {
      isLoadingresend.value = false;
    }
  }

  Future<bool> resetPasswordRequest(String email) async {
    final trimmedEmail = email.trim();
    if (trimmedEmail.isEmpty) {
      CustomSnackbar.showError('Email cannot be empty');
      return false;
    }
    if (!GetUtils.isEmail(trimmedEmail)) {
      CustomSnackbar.showError('Please enter a valid email address');
      return false;
    }

    try {
      isLoadingpass.value = true;
      registeredEmail = trimmedEmail;
      final result = await _authProvider.resetPassword(
        registeredEmail,
        purpose: "password_reset",
      );

      if (result == "success") {
        CustomSnackbar.showInfo('OTP code sent for password reset.');
        return true;
      } else {
        CustomSnackbar.showError(result);
        return false;
      }
    } catch (e) {
      CustomSnackbar.showError(e.toString());
      return false;
    } finally {
      isLoadingpass.value = false;
    }
  }

  Future<bool> resetPasswordConfirm({
    required String email,
    required String otp,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final trimmedPassword = newPassword.trim();
    final trimmedConfirm = confirmPassword.trim();

    if (trimmedPassword.isEmpty) {
      CustomSnackbar.showError('Please enter a new password');
      return false;
    }
    if (trimmedPassword.length < 6) {
      CustomSnackbar.showError('Password must be at least 6 characters');
      return false;
    }
    if (trimmedConfirm.isEmpty) {
      CustomSnackbar.showError('Please confirm your new password');
      return false;
    }
    if (trimmedPassword != trimmedConfirm) {
      CustomSnackbar.showError('Passwords do not match');
      return false;
    }

    try {
      isLoadingnewpass.value = true;
      final result = await _authProvider.resetPasswordConfirm(
        email: email.trim(),
        otp: otp.trim(),
        newPassword: trimmedPassword,
      );

      if (result == "success") {
        clearAllControllers(preserveRemembered: false);
        return true;
      } else {
        CustomSnackbar.showError(result);
        return false;
      }
    } catch (e) {
      CustomSnackbar.showError(e.toString());
      return false;
    } finally {
      isLoadingnewpass.value = false;
    }
  }

  Future<void> logout() async {
    try {
      await unregisterFCM().timeout(
        const Duration(seconds: 3),
      );
    } catch (e) {
      print("⚠️ FCM unregister failed: $e");
    }

    try {
      await _googleSignIn.signOut();
    } catch (e) {
      print('Google sign out error: $e');
    }

    storage.remove('loginToken');
    storage.remove('refreshToken');
    storage.remove('actionToken');
    storage.remove('email');
    storage.remove('password');
    ischecked.value = false;

    clearAllControllers(preserveRemembered: false);
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    signupNameController.dispose();
    signupEmailController.dispose();
    signupPasswordController.dispose();
    signupConfirmPasswordController.dispose();
    forgotEmailController.dispose();
    countryController.dispose();
    super.onClose();
  }
}

