import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kenzeno/app/modules/setting/service/setting_service.dart';
import 'package:toastification/toastification.dart';
import 'package:kenzeno/app/res/fonts/textstyle.dart';
import 'package:kenzeno/app/res/colors/colors.dart';

class Settingcontroller extends GetxController {
  var content = "".obs;
  var updatedAt = "".obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadPrivacyPolicy();
  }

  Future<void> loadPrivacyPolicy() async {
    try {
      isLoading(true);
      final Map<String, dynamic> data = await SettingService().fetchPrivacyPolicyContent();
      content.value = data['content'] ?? "No content available.";
      updatedAt.value = data['updated_at'] ?? "";
    } catch (e) {
      toastification.show(
        type: ToastificationType.error,
        style: ToastificationStyle.fillColored,
        primaryColor: Colors.red,
        foregroundColor: Colors.white,
        title: Text(
          "Error",
          style: AppTextStyles.poppinsBold.copyWith(color: Colors.white),
        ),
        description: Text(
          e.toString(),
          style: AppTextStyles.poppinsRegular.copyWith(color: Colors.white),
        ),
        alignment: Alignment.topRight,
        autoCloseDuration: const Duration(seconds: 4),
        borderRadius: BorderRadius.circular(12),
        showProgressBar: true,
      );
      content.value = "Failed to load privacy policy.";
    } finally {
      isLoading(false);
    }
  }
}
