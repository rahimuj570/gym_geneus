import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';
import 'package:kenzeno/app/res/colors/colors.dart';
import 'package:kenzeno/app/res/fonts/textstyle.dart';

class CustomSnackbar {
  static void showSuccess(String message, {String title = 'Success'}) {
    toastification.show(
      type: ToastificationType.success,
      style: ToastificationStyle.fillColored,
      primaryColor: AppColor.green16A34A,
      foregroundColor: Colors.white,
      title: Text(
        title,
        style: AppTextStyles.poppinsBold.copyWith(color: Colors.white),
      ),
      description: Text(
        message,
        style: AppTextStyles.poppinsRegular.copyWith(color: Colors.white),
      ),
      alignment: Alignment.topRight,
      autoCloseDuration: const Duration(seconds: 4),
      borderRadius: BorderRadius.circular(12),
      showProgressBar: true,
    );
  }

  static void showError(String message, {String title = 'Error'}) {
    toastification.show(
      type: ToastificationType.error,
      style: ToastificationStyle.fillColored,
      primaryColor: Colors.red,
      foregroundColor: Colors.white,
      title: Text(
        title,
        style: AppTextStyles.poppinsBold.copyWith(color: Colors.white),
      ),
      description: Text(
        message,
        style: AppTextStyles.poppinsRegular.copyWith(color: Colors.white),
      ),
      alignment: Alignment.topRight,
      autoCloseDuration: const Duration(seconds: 4),
      borderRadius: BorderRadius.circular(12),
      showProgressBar: true,
    );
  }

  static void showWarning(String message, {String title = 'Warning'}) {
    toastification.show(
      type: ToastificationType.warning,
      style: ToastificationStyle.fillColored,
      primaryColor: Colors.orange,
      foregroundColor: Colors.white,
      title: Text(
        title,
        style: AppTextStyles.poppinsBold.copyWith(color: Colors.white),
      ),
      description: Text(
        message,
        style: AppTextStyles.poppinsRegular.copyWith(color: Colors.white),
      ),
      alignment: Alignment.topRight,
      autoCloseDuration: const Duration(seconds: 4),
      borderRadius: BorderRadius.circular(12),
      showProgressBar: true,
    );
  }

  static void showInfo(String message, {String title = 'Info'}) {
    toastification.show(
      type: ToastificationType.info,
      style: ToastificationStyle.fillColored,
      primaryColor: AppColor.customPurple,
      foregroundColor: Colors.white,
      title: Text(
        title,
        style: AppTextStyles.poppinsBold.copyWith(color: Colors.white),
      ),
      description: Text(
        message,
        style: AppTextStyles.poppinsRegular.copyWith(color: Colors.white),
      ),
      alignment: Alignment.topRight,
      autoCloseDuration: const Duration(seconds: 4),
      borderRadius: BorderRadius.circular(12),
      showProgressBar: true,
    );
  }
}
