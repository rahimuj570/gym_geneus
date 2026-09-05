import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:kenzeno/app/modules/home/controllers/homecontroller.dart';
import '../../../res/colors/colors.dart';
import '../../../res/fonts/textstyle.dart';
import '../../../res/assets/asset.dart';
import '../../../widgets/workoutcard.dart';

import 'package:kenzeno/app/modules/setting/controller/profilecontroller.dart';

class WorkoutvideoPage extends StatelessWidget {
  const WorkoutvideoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.find<HomeController>();
    final profileController = Get.isRegistered<ProfileController>()
        ? Get.find<ProfileController>()
        : Get.put(ProfileController());

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sub-heading and Description (UNCHANGED)
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 8.h),
            child: Text(
              'Quick & Easy Workout Videos',
              style: AppTextStyles.poppinsBold.copyWith(
                color: AppColor.customPurple,
                fontSize: 18.sp,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 20.h),
            child: Text(
              'Discover Fresh Workouts: Elevate Your Training',
              style: AppTextStyles.poppinsRegular.copyWith(
                color: AppColor.white30,
                fontSize: 12.sp,
              ),
            ),
          ),

          // REAL DATA + SAME GRID LAYOUT
          Expanded(
            child: Obx(() {
              // Loading State
              if (controller.isLoadingWorkoutVideos.value) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppColor.customPurple,
                  ),
                );
              }

              // Empty State
              if (controller.workoutVideos.isEmpty) {
                return Center(
                  child: Text(
                    "No videos available",
                    style: AppTextStyles.poppinsRegular.copyWith(
                      color: AppColor.white30,
                      fontSize: 14.sp,
                    ),
                  ),
                );
              }

              final isTablet = MediaQuery.of(context).size.width >= 600;

              // Real API Data → Your Exact Grid + WorkoutCardWidget
              return GridView.builder(
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isTablet ? 3 : 2,
                  crossAxisSpacing: 5.w,
                  mainAxisSpacing: 15.h,
                  childAspectRatio: isTablet ? 0.95 : 0.8,
                ),
                itemCount: controller.workoutVideos.length,
                itemBuilder: (context, index) {
                  final video = controller.workoutVideos[index];

                  return WorkoutCardWidget(
                    title: video.title,
                    duration: "${video.durationMinutes} Minutes",
                    exercises:
                        "Workout Video", // or "Full Body", "Beginner", etc.
                    imagePath: profileController.activeCoachImagePath,
                    onTap: () {},
                  );
                },
              );
            }),
          ),

          SizedBox(height: 40.h),
        ],
      ),
    );
  }
}
