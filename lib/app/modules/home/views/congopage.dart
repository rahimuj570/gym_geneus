import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart'; // Assuming GetX for navigation
import 'package:kenzeno/app/modules/home/views/navbar.dart';
import 'package:kenzeno/app/widgets/backbutton_widget.dart';
// Note: Ensure all your imports are correctly configured
import '../../../res/colors/colors.dart';
import '../../../res/fonts/textstyle.dart';
import '../../../res/assets/asset.dart'; // For trophy SVG, etc.

import 'home.dart';

class CongratulationsPage extends StatelessWidget {
  // Data for the achievement summary (e.g., from a completed workout)
  final String duration;
  final String caloriesBurned;
  final String intensity;

  const CongratulationsPage({
    super.key,
    this.duration = '2 Hours', // Default values for demonstration
    this.caloriesBurned = '300 Calories',
    this.intensity = 'Moderate',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 20.h),
            // Trophy SVG with confetti effect
            SvgPicture.asset(
              ImageAssets.svg51, // Your trophy SVG asset
              height: 200.h,
              width: 200.w,
            ),

            SizedBox(height: 30.h),
            // Bottom section with achievement summary and buttons
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 30.h),
              decoration: BoxDecoration(
                color: AppColor.customPurple, // Light purple background
              ),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Text(
                      'Congratulations!',
                      style: AppTextStyles.poppinsBold.copyWith(
                        color: AppColor.black111214,
                        fontSize: 22.sp,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 10.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColor.white, // Solid purple for the summary
                      borderRadius: BorderRadius.circular(30.r),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildAchievementStat(ImageAssets.svg30, duration),
                        _buildAchievementStat(
                          ImageAssets.svg31,
                          caloriesBurned,
                        ),
                        _buildAchievementStat(ImageAssets.svg32, intensity),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 50.w),
              child: ElevatedButton(
                onPressed: () {
                  // Action for next workout
                  print('Go to the next workout');
                  // Get.to(() => NextWorkoutPage()); // Example navigation
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.customPurple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50.r),
                  ),
                  padding: EdgeInsets.symmetric(
                    vertical: 18.h,
                    horizontal: 40.w,
                  ),
                  minimumSize: Size(double.infinity, 0), // Full width
                ),
                child: Text(
                  'Go to the next workout',
                  style: AppTextStyles.poppinsBold.copyWith(
                    color: Colors.white,
                    fontSize: 14.sp,
                  ),
                ),
              ),
            ),
            SizedBox(height: 10.h),
            // "Home" button
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 50.w),
              child: ElevatedButton(
                onPressed: () {
                  // Action for next workout
                  print('Go to the next workout');
                  // Get.to(() => NextWorkoutPage()); // Example navigation
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50.r),
                  ),
                  padding: EdgeInsets.symmetric(
                    vertical: 18.h,
                    horizontal: 40.w,
                  ),
                  minimumSize: Size(double.infinity, 0), // Full width
                ),
                child: Text(
                  'Home',
                  style: AppTextStyles.poppinsBold.copyWith(
                    color: AppColor.black111214,
                    fontSize: 14.sp,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget to build each achievement stat (duration, calories, intensity)
  Widget _buildAchievementStat(String icon, String value) {
    return Column(
      children: [
        SvgPicture.asset(icon, color: AppColor.black111214, height: 15.h),
        SizedBox(height: 8.h),
        Text(
          value,
          style: AppTextStyles.poppinsMedium.copyWith(
            color: AppColor.black111214,
            fontSize: 14.sp,
          ),
        ),
      ],
    );
  }
}
