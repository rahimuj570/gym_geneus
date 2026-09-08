import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:kenzeno/app/modules/auth/controllers/authcontroller.dart';
import 'package:kenzeno/app/modules/auth/views/otp.dart';
import 'package:kenzeno/app/widgets/backbutton_widget.dart';

import '../../../res/assets/asset.dart';
import '../../../res/colors/colors.dart';
import '../../../res/fonts/textstyle.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/textfield.dart';

class ForgotPassword extends StatelessWidget {
  final Authcontroller controller = Get.find();

  ForgotPassword({super.key});

  @override
  Widget build(BuildContext context) {
    controller.frompage.value = "forgotpass";
    controller.forgotEmailController.clear();
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColor
          .white, // This is just the Scaffold color, overridden by Stack
      // Use a custom back button leading to the previous screen
      appBar: AppBar(
        backgroundColor: Colors.transparent,

        leading: BackButtonBox(),
      ),
      extendBodyBehindAppBar: true, // Allow content to go behind the AppBar

      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            ImageAssets.img_5,
            fit: BoxFit.cover,
            colorBlendMode: BlendMode.darken,
          ),

          // Overlay
          Container(color: Colors.black.withOpacity(0.3)),

          // Content
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 30.h),
            child: SingleChildScrollView(
              // The top padding is handled by extendBodyBehindAppBar and the AppBar height
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Spacer to push content down past the AppBar area
                  SizedBox(height: 100.h),

                  // Title (already in AppBar, but we keep the main title here as per image)
                  Text(
                    'Forgot Password?',
                    style: AppTextStyles.workSansBold.copyWith(
                      color: Colors.white,
                      fontSize: 25.sp,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 6.h),

                  // Subtitle
                  Text(
                    'Enter your registered email to reset your password',
                    style: AppTextStyles.workSansRegular.copyWith(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 13.sp,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 40.h),

                  // Email Label
                  Text(
                    'Email Address',
                    style: AppTextStyles.workSansBold.copyWith(
                      color: Colors.white,
                      fontSize: 12.sp,
                    ),
                  ),
                  SizedBox(height: 6.h),

                  // Email Input
                  InputTextWidget(
                    controller: controller.forgotEmailController,
                    hintText: 'Enter your email',
                    onChanged: (value) {},
                    leading: true,
                    leadingIcon: ImageAssets.email,
                    backgroundColor: AppColor.white,
                    borderColor: AppColor.customPurple,
                    textColor: AppColor.greyDark,
                    hintTextColor: AppColor.greyDark,
                    borderRadius: 10.r,
                    contentPadding: true,
                    height: 40.h,
                  ),
                  SizedBox(height: 40.h),

                  // Send OTP Button
                  Obx(
                    () => CustomButton(
                      onPress: () async {
                        final emailText = controller.forgotEmailController.text
                            .trim();
                        final success = await controller.resetPasswordRequest(
                          emailText,
                        );
                        if (success) {
                          Get.to(
                            OtpVerification(
                              email: emailText,
                              fromPage: "forgotpass",
                            ),
                            transition: Transition.rightToLeft,
                          );
                        }
                      },
                      loading: controller.isLoadingpass.value,
                      title: "Send OTP",
                      fontSize: 16.sp,
                      height: 40.h,
                      svgorimage: false, // Image doesn't show a trailing icon
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
