import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../res/assets/asset.dart';
import '../../../res/colors/colors.dart';
import '../../../res/fonts/textstyle.dart';
import '../../../widgets/custom_button.dart';
import '../../auth/views/login.dart';
import '../../auth/views/signup.dart';
import '../controllers/onboard_controller.dart';

class Onboard5 extends StatelessWidget {
  final OnboardController controller = Get.find();
  Onboard5({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.black111214,
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
          Container(color: Colors.black.withValues(alpha: 0.35)),

          // Content
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 20.h,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(height: 140.h),

                          // Center Brand & Title
                          Column(
                            children: [
                              SvgPicture.asset(ImageAssets.svg2, height: 75.h),
                              SizedBox(height: 16.h),
                              Text(
                                "Welcome To\nGym Genius AI",
                                style: AppTextStyles.workSansBold.copyWith(
                                  fontSize: 32.sp,
                                  color: Colors.white,
                                  height: 1.2,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 12.h),
                              Text(
                                "Your personal fitness AI Assistant 🤖",
                                style: AppTextStyles.workSansRegular.copyWith(
                                  fontSize: 14.sp,
                                  color: Colors.white70,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),

                          SizedBox(height: 40.h),

                          // Bottom Action Buttons
                          Column(
                            children: [
                              CustomButton(
                                onPress: () async {
                                  Get.to(
                                    Signup(),
                                    transition: Transition.rightToLeft,
                                  );
                                },
                                title: "Get Started",
                                fontSize: 16.sp,
                                height: 48.h,
                                width: double.infinity,
                                fontFamily: 'WorkSans',
                                radius: 20.r,
                                svgorimage: true,
                                trailing: ImageAssets.svg3,
                                fontWeight: FontWeight.bold,
                                textColor: AppColor.white,
                                borderColor: AppColor.customPurple,
                                buttonColor: AppColor.customPurple,
                              ),
                              SizedBox(height: 24.h),
                              Center(
                                child: RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: 'Already have an account? ',
                                        style: AppTextStyles.workSansBold
                                            .copyWith(
                                              color: AppColor.white,
                                              fontSize: 14.sp,
                                            ),
                                      ),
                                      TextSpan(
                                        text: 'Log in',
                                        style: AppTextStyles.workSansBold
                                            .copyWith(
                                              color: AppColor.customPurple,
                                              fontSize: 14.sp,
                                              decoration:
                                                  TextDecoration.underline,
                                              decorationColor:
                                                  AppColor.customPurple,
                                            ),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () {
                                            Get.to(
                                              Login(),
                                              transition:
                                                  Transition.rightToLeft,
                                            );
                                          },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: 12.h),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
