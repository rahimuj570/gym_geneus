import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kenzeno/app/modules/setting/service/setting_service.dart';
import 'package:kenzeno/app/widgets/custom_snackbar.dart';

class PasswordController extends GetxController {
  final SettingService service = Get.find();

  var oldPassword = ''.obs;
  var newPassword = ''.obs;
  var confirmPassword = ''.obs;

  var isLoading = false.obs;
  var showOld = false.obs;
  var showNew = false.obs;
  var showConfirm = false.obs;

  bool get passwordsMatch => newPassword.value == confirmPassword.value;

  bool get isValid =>
      oldPassword.value.isNotEmpty &&
      newPassword.value.isNotEmpty &&
      confirmPassword.value.isNotEmpty &&
      newPassword.value.length >= 8 &&
      passwordsMatch;

  Future<void> submit() async {
    final oldPass = oldPassword.value.trim();
    final newPass = newPassword.value.trim();
    final confirmPass = confirmPassword.value.trim();

    if (oldPass.isEmpty) {
      CustomSnackbar.showError('Old password cannot be empty');
      return;
    }
    if (newPass.isEmpty) {
      CustomSnackbar.showError('New password cannot be empty');
      return;
    }
    if (newPass.length < 8) {
      CustomSnackbar.showError('New password must be at least 8 characters');
      return;
    }
    if (confirmPass.isEmpty) {
      CustomSnackbar.showError('Please confirm your new password');
      return;
    }
    if (newPass != confirmPass) {
      CustomSnackbar.showError('New passwords do not match');
      return;
    }

    isLoading(true);

    final result = await service.changePassword(
      oldPassword: oldPass,
      newPassword: newPass,
      confirmPassword: confirmPass,
    );

    isLoading(false);

    if (result == "success") {
      CustomSnackbar.showSuccess("Password changed successfully");

      // Clear fields
      oldPassword.value = '';
      newPassword.value = '';
      confirmPassword.value = '';

      Get.back(); // close screen
    }
  }
}
