import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:kenzeno/app/modules/setting/controller/gallery_password_controller.dart';
import 'package:kenzeno/app/res/colors/colors.dart';
import 'package:kenzeno/app/res/fonts/textstyle.dart';
import 'package:kenzeno/app/widgets/backbutton_widget.dart';
import 'package:kenzeno/app/widgets/custom_button.dart';
import 'package:kenzeno/app/widgets/textfield.dart';

class GalleryPasswordSettingsScreen extends StatelessWidget {
  const GalleryPasswordSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<GalleryPasswordController>()
        ? Get.find<GalleryPasswordController>()
        : Get.put(GalleryPasswordController());

    final currentCtrl = TextEditingController(text: controller.currentPassword.value);
    final newCtrl = TextEditingController(text: controller.newPassword.value);
    final confirmCtrl = TextEditingController(text: controller.confirmPassword.value);

    return Scaffold(
      backgroundColor: AppColor.black111214,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButtonBox(),
        title: Text(
          "Gallery PIN Settings",
          style: AppTextStyles.poppinsSemiBold.copyWith(
            fontSize: 20.sp,
            color: Colors.white,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info description
              Container(
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  color: AppColor.customPurple.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: AppColor.customPurple.withValues(alpha: 0.4),
                    width: 1,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.shield_outlined,
                      color: AppColor.customPurple,
                      size: 24.sp,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        "Set a custom 4-digit PIN/Password to secure and lock your personal progress photos gallery.",
                        style: AppTextStyles.poppinsRegular.copyWith(
                          color: Colors.white70,
                          fontSize: 13.sp,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 25.h),

              // Current PIN
              _buildField(
                label: "Current PIN / Password",
                controller: currentCtrl,
                hintText: "Enter current PIN (default: 1234)",
                obscureText: true,
                onChanged: (v) => controller.currentPassword.value = v,
              ),

              SizedBox(height: 20.h),

              // New PIN
              _buildField(
                label: "New PIN / Password",
                controller: newCtrl,
                hintText: "Enter new 4+ digit PIN",
                obscureText: true,
                onChanged: (v) => controller.newPassword.value = v,
              ),

              SizedBox(height: 20.h),

              // Confirm New PIN
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Confirm New PIN",
                    style: AppTextStyles.poppinsRegular.copyWith(
                      color: AppColor.customPurple,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  InputTextWidget(
                    controller: confirmCtrl,
                    hintText: "Re-enter new PIN",
                    obscureText: true,
                    onChanged: (v) => controller.confirmPassword.value = v,
                    backgroundColor: Colors.white,
                    textColor: AppColor.black232323,
                    hintTextColor: AppColor.gray9CA3AF,
                    borderRadius: 15.r,
                    height: 40.h,
                  ),
                  SizedBox(height: 6.h),
                  Obx(() {
                    final hasText = controller.confirmPassword.value.isNotEmpty;
                    final match = controller.pinsMatch;

                    if (!hasText) return const SizedBox.shrink();
                    return Text(
                      match ? "PINs match" : "PINs do not match",
                      style: TextStyle(
                        color: match ? Colors.green : Colors.redAccent,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    );
                  }),
                ],
              ),

              SizedBox(height: 50.h),

              // Submit Button
              Obx(
                () => CustomButton(
                  onPress: () async {
                    await controller.changeGalleryPin();
                  },
                  title: controller.isLoading.value
                      ? "Updating..."
                      : "Save Gallery PIN",
                  loading: controller.isLoading.value,
                  fontSize: 16.sp,
                  height: 45.h,
                  radius: 28.r,
                  fontWeight: FontWeight.w700,
                  textColor: Colors.white,
                  buttonColor: controller.isValid
                      ? AppColor.customPurple
                      : AppColor.white.withValues(alpha: 0.1),
                  borderColor: AppColor.customPurple.withValues(alpha: 0.3),
                ),
              ),

              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    required bool obscureText,
    required Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.poppinsRegular.copyWith(
            color: AppColor.customPurple,
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8.h),
        InputTextWidget(
          controller: controller,
          hintText: hintText,
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
