// lib/app/modules/profile/views/password_settings_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:kenzeno/app/modules/auth/views/forgotpassword.dart';

import 'package:kenzeno/app/res/colors/colors.dart';
import 'package:kenzeno/app/res/fonts/textstyle.dart';
import 'package:kenzeno/app/widgets/backbutton_widget.dart';
import 'package:kenzeno/app/widgets/custom_button.dart';
import 'package:kenzeno/app/widgets/textfield.dart';
import '../controller/passwordcontroller.dart';

class PasswordSettingsScreen extends StatelessWidget {
  final PasswordController controller = Get.put(PasswordController());

  PasswordSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.black111214,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButtonBox(),
        title: Text(
          "Password Settings",
          style: AppTextStyles.poppinsSemiBold.copyWith(
            fontSize: 20.sp,
            color: Colors.white,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 30.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20.h),

              // Current Password
              _buildField(
                label: "Current Password",
                controller: TextEditingController()
                  ..text = controller.oldPassword.value,
                obscureText: true,
                onChanged: (v) => controller.oldPassword.value = v,
                showForgot: true,
              ),

              SizedBox(height: 24.h),

              // New Password
              _buildField(
                label: "New Password",
                controller: TextEditingController()
                  ..text = controller.newPassword.value,
                obscureText: true,
                onChanged: (v) => controller.newPassword.value = v,
              ),

              SizedBox(height: 24.h),

              // Confirm Password + Match Indicator
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Confirm New Password",
                    style: AppTextStyles.poppinsRegular.copyWith(
                      color: AppColor.customPurple,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8.h),

                  Obx(() {
                    final match = controller.passwordsMatch;
                    final hasText = controller.confirmPassword.value.isNotEmpty;

                    return Column(
                      children: [
                        InputTextWidget(
                          controller: TextEditingController()
                            ..text = controller.confirmPassword.value
                            ..selection = TextSelection.fromPosition(
                              TextPosition(
                                offset: controller.confirmPassword.value.length,
                              ),
                            ),
                          hintText: 'Re-enter new password',
                          obscureText: true,
                          onChanged: (v) =>
                              controller.confirmPassword.value = v,
                          backgroundColor: Colors.white,
                          textColor: AppColor.black232323,
                          hintTextColor: AppColor.gray9CA3AF,
                          borderRadius: 15.r,
                          height: 40.h,
                        ),
                        SizedBox(height: 6.h),
                        if (hasText && !match)
                          Text(
                            "Passwords do not match",
                            style: TextStyle(
                              color: Colors.redAccent,
                              fontSize: 12.sp,
                            ),
                          ),
                        if (hasText && match)
                          Text(
                            "Passwords match",
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 12.sp,
                            ),
                          ),
                      ],
                    );
                  }),
                ],
              ),

              SizedBox(height: 80.h),

              Obx(
                () => CustomButton(
                  onPress: () async {
                    await controller.submit();
                  },
                  title: controller.isLoading.value
                      ? "Changing..."
                      : "Change Password",
                  loading: controller.isLoading.value,
                  fontSize: 16.sp,
                  height: 45.h,
                  radius: 28.r,
                  fontWeight: FontWeight.w700,
                  textColor: Colors.white,
                  buttonColor: controller.isValid
                      ? AppColor.customPurple
                      : AppColor.white.withOpacity(0.1),
                  borderColor: AppColor.customPurple.withOpacity(0.3),
                ),
              ),

              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required bool obscureText,
    required Function(String) onChanged,
    bool showForgot = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: AppTextStyles.poppinsRegular.copyWith(
                color: AppColor.customPurple,
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (showForgot)
              GestureDetector(
                onTap: () => Get.to(
                  ForgotPassword(),
                  transition: Transition.rightToLeft,
                ),
                child: Text(
                  "Forgot Password?",
                  style: TextStyle(
                    color: AppColor.customPurple,
                    fontSize: 12.sp,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: 8.h),
        InputTextWidget(
          controller: controller,
          hintText: 'Enter your password',
          obscureText: obscureText,
          onChanged: onChanged,
          backgroundColor: Colors.white,
          textColor: AppColor.black232323,
          hintTextColor: AppColor.gray9CA3AF,
          borderRadius: 15.r,
          height: 40.h,
        ),
      ],
    );
  }
}
