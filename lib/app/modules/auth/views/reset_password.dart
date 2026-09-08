import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:kenzeno/app/modules/auth/controllers/authcontroller.dart';
import 'package:kenzeno/app/modules/auth/views/passconfirmation.dart';
import 'package:kenzeno/app/widgets/backbutton_widget.dart';

import '../../../res/assets/asset.dart';
import '../../../res/colors/colors.dart';
import '../../../res/fonts/textstyle.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/textfield.dart';

class ResetPasswordView extends StatefulWidget {
  final String email;
  final String otp;

  const ResetPasswordView({
    super.key,
    required this.email,
    required this.otp,
  });

  @override
  State<ResetPasswordView> createState() => _ResetPasswordViewState();
}

class _ResetPasswordViewState extends State<ResetPasswordView> {
  final Authcontroller controller = Get.find<Authcontroller>();
  late final TextEditingController newPasswordController;
  late final TextEditingController confirmPasswordController;

  @override
  void initState() {
    super.initState();
    newPasswordController = TextEditingController();
    confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: const BackButtonBox(),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          Image.asset(
            ImageAssets.img_5,
            fit: BoxFit.cover,
            colorBlendMode: BlendMode.darken,
          ),

          // Dark Overlay
          Container(color: Colors.black.withOpacity(0.35)),

          // Content
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 30.h),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 100.h),

                  // Title
                  Text(
                    'Reset Password',
                    style: AppTextStyles.workSansBold.copyWith(
                      color: Colors.white,
                      fontSize: 25.sp,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 6.h),

                  // Subtitle
                  Text(
                    'Enter your new password to secure and reset your account.',
                    style: AppTextStyles.workSansRegular.copyWith(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12.sp,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 35.h),

                  // New Password Label
                  Text(
                    'New Password',
                    style: AppTextStyles.workSansBold.copyWith(
                      color: Colors.white,
                      fontSize: 12.sp,
                    ),
                  ),
                  SizedBox(height: 6.h),

                  // New Password Input
                  InputTextWidget(
                    controller: newPasswordController,
                    hintText: 'Enter new password',
                    onChanged: (value) {},
                    leading: true,
                    leadingIcon: ImageAssets.svg53,
                    obscureText: true,
                    passwordIcon: ImageAssets.obsecure,
                    backgroundColor: AppColor.white,
                    borderColor: AppColor.customPurple,
                    textColor: AppColor.greyDark,
                    hintTextColor: AppColor.greyDark,
                    borderRadius: 10.r,
                    contentPadding: true,
                    height: 40.h,
                  ),
                  SizedBox(height: 16.h),

                  // Confirm Password Label
                  Text(
                    'Confirm New Password',
                    style: AppTextStyles.workSansBold.copyWith(
                      color: Colors.white,
                      fontSize: 12.sp,
                    ),
                  ),
                  SizedBox(height: 6.h),

                  // Confirm Password Input
                  InputTextWidget(
                    controller: confirmPasswordController,
                    hintText: 'Re-enter new password',
                    onChanged: (value) {},
                    leading: true,
                    leadingIcon: ImageAssets.svg53,
                    obscureText: true,
                    passwordIcon: ImageAssets.obsecure,
                    backgroundColor: AppColor.white,
                    borderColor: AppColor.customPurple,
                    textColor: AppColor.greyDark,
                    hintTextColor: AppColor.greyDark,
                    borderRadius: 10.r,
                    contentPadding: true,
                    height: 40.h,
                  ),
                  SizedBox(height: 40.h),

                  // Submit Button
                  Obx(
                    () => CustomButton(
                      onPress: () async {
                        final success = await controller.resetPasswordConfirm(
                          email: widget.email,
                          otp: widget.otp,
                          newPassword: newPasswordController.text.trim(),
                          confirmPassword: confirmPasswordController.text.trim(),
                        );
                        if (success) {
                          Get.offAll(
                            () => const Passconfirmation(),
                            transition: Transition.rightToLeft,
                          );
                        }
                      },
                      loading: controller.isLoadingnewpass.value,
                      title: "Reset Password",
                      fontSize: 16.sp,
                      height: 40.h,
                      svgorimage: false,
                      fontFamily: 'WorkSans',
                      radius: 20.r,
                      fontWeight: FontWeight.w700,
                      textColor: AppColor.white,
                      borderColor: AppColor.customPurple,
                      buttonColor: AppColor.customPurple,
                    ),
                  ),

                  SizedBox(height: 30.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
