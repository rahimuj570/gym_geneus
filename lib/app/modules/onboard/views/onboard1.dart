import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:kenzeno/app/modules/onboard/views/onboard2.dart';

import '../../../res/assets/asset.dart';

import '../../../res/colors/colors.dart';
import '../../../res/fonts/textstyle.dart';
import '../../../widgets/custom_button.dart';
import '../controllers/onboard_controller.dart';

class Onboard1 extends StatelessWidget {
  final OnboardController controller = Get.find();
  Onboard1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          Image.asset(
            ImageAssets.img_2,
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
                  "Personalized\nFitness Plans",
                  style: AppTextStyles.workSansBold.copyWith(
                    fontSize: 35.sp, // reduced size
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 10.h),

                // Subtitle
                Text(
                  "Choose your own fitness journey with AI. 🏋️‍♀️",
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
                      Onboard2(),
                      transition: Transition.fadeIn,
                      duration: const Duration(
                        milliseconds: 500,
                      ), // Animation duration
                      curve: Curves.easeInOut, // Optional easing curve
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
