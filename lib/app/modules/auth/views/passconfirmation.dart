import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kenzeno/app/modules/auth/controllers/authcontroller.dart';
import 'package:kenzeno/app/modules/auth/views/login.dart'; // Corrected import to match app structure
import '../../../res/assets/asset.dart'; // Assuming ImageAssets are here
import '../../../res/colors/colors.dart';
import '../../../res/fonts/textstyle.dart'; // Using AppTextStyles
import '../../../widgets/custom_button.dart';

class Passconfirmation extends StatelessWidget {
  const Passconfirmation({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      // The background color is now handled by the Stack/Image, but we set
      // Scaffold color to transparent or black for safety
      backgroundColor: Colors.black,

      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent, // Transparent AppBar
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,

      body: Stack(
        // <-- Added Stack for background image
        fit: StackFit.expand,
        children: [
          // 1. Background Image
          Image.asset(
            // Reusing img_5 from your Login example for consistency
            ImageAssets.img_28,
            fit: BoxFit.cover,
            colorBlendMode: BlendMode.darken,
          ),

          // 2. Dark Overlay
          Container(color: Colors.black.withOpacity(0.3)),

          // 3. Main Content
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Spacer to push content down past the AppBar area
                SizedBox(height: 120.h),

                // Image/SVG (The checkmark icon is assumed to be white or purple)
                SizedBox(
                  width: 136.w,
                  height: 160.h,
                  child: SvgPicture.asset(ImageAssets.svg55),
                ),
                SizedBox(height: 40.h),

                // Title: Password Changed!
                Text(
                  'Password Changed!',
                  style: AppTextStyles.workSansBold.copyWith(
                    fontSize: 25.sp,
                    color: AppColor.white,
                  ),
                ),
                SizedBox(height: 8.h),

                // Subtitle
                Text(
                  'Your password has been changed successfully.',
                  style: AppTextStyles.workSansRegular.copyWith(
                    fontSize: 14.sp,
                    color: AppColor.white.withOpacity(0.8),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 40.h),

                // Button: Next (Go to Login)
                CustomButton(
                  onPress: () async {
                    if (Get.isRegistered<Authcontroller>()) {
                      Get.find<Authcontroller>().clearAllControllers(preserveRemembered: true);
                    }
                    // Navigate back to the Login screen
                    Get.offAll(
                      () => Login(),
                      transition: Transition.rightToLeft,
                    );
                  },
                  title: 'Get Started',
                  height: 30.h,
                  svgorimage: true,
                  trailing: ImageAssets.svg3,
                  fontSize: 16.sp,
                  fontFamily: 'WorkSans',
                  fontWeight: FontWeight.w700,
                  textColor: AppColor.white,
                  borderColor: AppColor.customPurple,
                  buttonColor: AppColor.customPurple,
                  width: double.infinity,
                  radius: 20.r,
                ),
                SizedBox(height: 16.h),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
