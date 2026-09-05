import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:get/get.dart';
import 'package:kenzeno/app/modules/auth/views/login.dart';
import 'package:kenzeno/app/modules/auth/views/signup.dart';
import 'package:kenzeno/app/modules/setup/views/setup.dart';

import '../../../res/assets/asset.dart';

import '../../../res/colors/colors.dart';
import '../../../res/fonts/textstyle.dart';
import '../../../widgets/custom_button.dart';
import '../controllers/onboard_controller.dart';

class Onboard5 extends StatelessWidget {
  final OnboardController controller = Get.find();
  Onboard5({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          Image.asset(
            ImageAssets.img_4,
            fit: BoxFit.cover,
            colorBlendMode: BlendMode.darken,
          ),

          // Overlay
          Container(color: Colors.black.withOpacity(0.3)),

          // Content
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                SizedBox(height: 250.h),
                SvgPicture.asset(ImageAssets.svg2, height: 80.h),
                Text(
                  "Welcome To\nGym Genius AI",
                  style: AppTextStyles.workSansBold.copyWith(
                    fontSize: 35.sp, // reduced size
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 10.h),

                // Subtitle
                Text(
                  "Your personal fitness AI Assistant 🤖",
                  style: AppTextStyles.workSansRegular.copyWith(
                    fontSize: 14.sp, // reduced size
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 80.h),
                // Button
                CustomButton(
                  onPress: () async {
                    Get.to(Signup(), transition: Transition.rightToLeft);
                  },
                  title: "Get Started",
                  fontSize: 16.sp,
                  height: 45.h,

                  fontFamily: 'WorkSans',
                  radius: 20.r,
                  svgorimage: true,
                  trailing: ImageAssets.svg3,
                  fontWeight: FontWeight.bold,
                  textColor: AppColor.white,
                  borderColor: AppColor.customPurple,
                  buttonColor: AppColor.customPurple,
                ),

                SizedBox(height: 50.h),
                Center(
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Already have an account? ',
                          style: AppTextStyles.workSansBold.copyWith(
                            color: AppColor.white,
                            fontSize: 14.sp,
                          ),
                        ),
                        TextSpan(
                          text: 'Log in',
                          style: AppTextStyles.workSansBold.copyWith(
                            color: AppColor.customPurple,
                            fontSize: 14.sp,
                            decoration: TextDecoration.underline,
                            decorationColor: AppColor.customPurple,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Get.to(
                                Login(),
                                transition: Transition.rightToLeft,
                              );
                            },
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
