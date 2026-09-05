import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:kenzeno/app/modules/auth/controllers/authcontroller.dart';
// Assuming Login page is in the same directory structure
import 'package:kenzeno/app/modules/auth/views/login.dart';
// Assuming a placeholder for the main app navigation after successful signup
import 'package:kenzeno/app/modules/home/views/navbar.dart';
// Placeholder for the main app navigation after successful signup
import '../../../res/assets/asset.dart';
import '../../../res/colors/colors.dart';
import '../../../res/fonts/textstyle.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/textfield.dart';

class Signup extends StatelessWidget {
  final Authcontroller controller = Get.find();
  Signup({super.key});

  @override
  Widget build(BuildContext context) {
    controller.frompage.value = "signup";
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColor.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image (same as Login)
          Image.asset(
            ImageAssets
                .img_27, // Assuming img_5 is the path to your background image
            fit: BoxFit.cover,
            // Apply color blending/overlay for darker effect
            colorBlendMode: BlendMode.darken,
          ),

          // Overlay
          Container(color: Colors.black.withOpacity(0.3)),

          // Content
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 30.h),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 30.h), // Top padding
                  // Logo
                  Container(
                    padding: EdgeInsets.all(2.w),
                    child: SvgPicture.asset(ImageAssets.svg2, height: 60.h),
                  ),

                  // Title
                  Text(
                    'Sign Up For Free',
                    style: AppTextStyles.workSansBold.copyWith(
                      color: Colors.white,
                      fontSize: 25.sp,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 6.h),

                  // Subtitle
                  Text(
                    'Quickly make your account in 1 minute',
                    style: AppTextStyles.workSansBold.copyWith(
                      color: Colors.white,
                      fontSize: 12.sp,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20.h),

                  // Full Name (New Field for Signup)
                  Text(
                    'Full Name',
                    style: AppTextStyles.workSansBold.copyWith(
                      color: Colors.white,
                      fontSize: 12.sp,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  InputTextWidget(
                    controller: controller.namecontroller,
                    hintText: 'Enter your full name',
                    onChanged: (value) {},
                    leading: true,
                    leadingIcon:
                        ImageAssets.svg54, // Assuming a person icon asset
                    backgroundColor: AppColor.white,
                    borderColor: AppColor.customPurple,
                    textColor: AppColor
                        .greyDark, // Text color should be dark if background is white
                    hintTextColor: AppColor.greyDark, // Placeholder text color
                    borderRadius: 10.r,
                    contentPadding: true,
                    height: 40.h,
                  ),
                  SizedBox(height: 14.h),

                  // Email or Phone Number
                  Text(
                    'Email',
                    style: AppTextStyles.workSansBold.copyWith(
                      color: Colors.white,
                      fontSize: 12.sp,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  InputTextWidget(
                    controller: controller.emailController,
                    hintText: 'Email',
                    onChanged: (value) {},
                    leading: true,
                    leadingIcon:
                        ImageAssets.email, // Assuming an email icon asset
                    backgroundColor: AppColor.white,
                    borderColor: AppColor.customPurple,
                    textColor: AppColor.greyDark,
                    hintTextColor: AppColor.greyDark,
                    borderRadius: 10.r,
                    contentPadding: true,
                    height: 40.h,
                  ),
                  SizedBox(height: 14.h),

                  // Password
                  Text(
                    'Password',
                    style: AppTextStyles.workSansBold.copyWith(
                      color: Colors.white,
                      fontSize: 12.sp,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  InputTextWidget(
                    controller: controller.passwordController,
                    hintText: 'Enter your password',
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
                    height: 40.h,
                  ),
                  SizedBox(height: 14.h),

                  // Confirm Password (New Field for Signup)
                  Text(
                    'Confirm Password',
                    style: AppTextStyles.workSansBold.copyWith(
                      color: Colors.white,
                      fontSize: 12.sp,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  InputTextWidget(
                    controller: controller.confirmpasswordController,
                    hintText: 'Re-enter your password',
                    onChanged: (value) {},
                    obscureText: true,
                    leading: true,
                    leadingIcon: ImageAssets.svg53,
                    passwordIcon: ImageAssets.obsecure,
                    backgroundColor: AppColor.white,
                    borderColor: AppColor.customPurple,
                    textColor: AppColor.greyDark,
                    hintTextColor: AppColor.greyDark,
                    borderRadius: 10.r,
                    height: 40.h,
                  ),
                  SizedBox(height: 30.h),

                  // Sign Up Button
                  Obx(
                    () => CustomButton(
                      onPress: () async => controller.register(),
                      loading: controller.isLoadingsignup.value,
                      title: "Sign Up",
                      fontSize: 16.sp,
                      height: 40.h, // Increased height for better visibility
                      svgorimage: true,
                      trailing: ImageAssets
                          .svg3, // Assuming this is the right arrow icon
                      fontFamily: 'WorkSans',
                      radius: 20.r,
                      fontWeight: FontWeight.w700,
                      textColor: AppColor.white,
                      borderColor: AppColor.customPurple,
                      buttonColor: AppColor.customPurple,
                    ),
                  ),

                  SizedBox(height: 30.h),

                  // Login Link
                  Center(
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Already have an account?  ',
                            style: AppTextStyles.workSansRegular.copyWith(
                              color: AppColor
                                  .white, // Changed to white to contrast with dark background
                              fontSize: 14.sp,
                            ),
                          ),
                          TextSpan(
                            text: 'Login',
                            style: AppTextStyles.workSansBold.copyWith(
                              color: AppColor
                                  .customPurple, // Use a bright color like purple
                              fontSize: 14.sp,
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                // Navigate back to the Login screen
                                Get.off(
                                  () => Login(),
                                  transition: Transition.rightToLeftWithFade,
                                );
                              },
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h), // Bottom padding
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
