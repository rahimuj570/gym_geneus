import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../res/assets/asset.dart';
import '../res/colors/colors.dart';
import '../res/fonts/textstyle.dart';

class TrainingOfTheDayCard extends StatelessWidget {
  final String headtitle;
  final String title;
  final String imagePath;
  final String duration;
  final String calories;
  final String exercises;
  final VoidCallback ontap;

  const TrainingOfTheDayCard({
    super.key,
    this.title = "Functional Training",
    this.imagePath = ImageAssets.img_20,
    this.duration = "45 Minutes",
    this.calories = "1450 Kcal",
    this.exercises = "5 Exercises", required this.headtitle, required this.ontap,
  });

  @override
  Widget build(BuildContext context) {
    // The main container is wrapped in ClipRRect to apply the corner radius to the image
    return GestureDetector(
      onTap: ontap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.r), // Standard corner radius
        child: Container(
          height: 180.h, // Adjusted height for better visual impact
          width: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: imagePath.startsWith('http')
                  ? NetworkImage(imagePath)
                  : AssetImage(imagePath) as ImageProvider,
              fit: BoxFit.cover,
            ),
          ),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. TOP SECTION (Training of the day pill)
              Align(
                alignment: Alignment.topRight,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20.w), // Rounded corner on bottom-left of the pill
                    ),
                  ),
                  child: Text(
                    headtitle,
                    style: AppTextStyles.poppinsSemiBold.copyWith(
                      fontSize: 12.sp,
                      color: AppColor.black232323,
                    ),
                  ),
                ),
              ),

              // 2. BOTTOM SECTION (Title and Stats Overlay)
              Container(
                padding: EdgeInsets.only(left: 16.w, top: 10.h, bottom: 10.h, right: 16.w),
                color: AppColor.black50, // Semi-transparent black overlay
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Functional Training Title
                    Text(
                      title,
                      style: AppTextStyles.poppinsSemiBold.copyWith(
                        fontSize: 18.sp,
                        color: AppColor.white,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    // Stats Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStatItem(Icons.watch_later_outlined, duration),
                        _buildStatItem(Icons.local_fire_department_outlined, calories),
                        _buildStatItem(Icons.fitness_center_outlined, exercises),
                        // Adding a small star icon for aesthetic completion (top right star from reference image context)
                        Icon(Icons.star, color: AppColor.customPurple, size: 18.sp),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method for building the individual stat items
  Widget _buildStatItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppColor.white, size: 14.sp),
        SizedBox(width: 4.w),
        Text(
          text,
          style: AppTextStyles.poppinsRegular.copyWith(
            fontSize: 12.sp,
            color: AppColor.white,
          ),
        ),
      ],
    );
  }
}

