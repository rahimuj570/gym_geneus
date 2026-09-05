import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';

import '../../../res/assets/asset.dart';

import '../../../res/colors/colors.dart';
import '../../../res/fonts/textstyle.dart';
import '../../../widgets/custom_button.dart';
import '../controllers/onboard_controller.dart';
import 'onboard5.dart';

class Onboard4 extends StatelessWidget {
  final OnboardController controller = Get.find();
  Onboard4({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          Image.asset(
            ImageAssets.img_3,
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
                SizedBox(height: 200.h),
                Text(
                  "Your Ai-driven personal trainer",
                  style: AppTextStyles.workSansBold.copyWith(
                    fontSize: 32.sp, // reduced size
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 10.h),

                // Subtitle
                Text(
                  " That delivers top-quality results and intelligence",
                  style: AppTextStyles.workSansRegular.copyWith(
                    fontSize: 14.sp, // reduced size
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 100.h),
                // Button
                CustomButton(
                  onPress: () async {
                    Get.to(
                      Onboard5(),
                      transition: Transition.fadeIn,
                      duration: const Duration(
                        milliseconds: 500,
                      ), // Animation duration
                      curve: Curves.easeInOut,
                    );
                  },
                  title: "Next",
                  fontSize: 16.sp,
                  height: 45.h,

                  fontFamily: 'WorkSans',
                  radius: 20.r,

                  fontWeight: FontWeight.bold,
                  textColor: AppColor.white,
                  borderColor: AppColor.customPurple,
                  buttonColor: AppColor.white15,
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
