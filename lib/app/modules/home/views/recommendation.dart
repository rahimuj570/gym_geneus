// lib/app/modules/workout/views/recommendation.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:kenzeno/app/modules/home/controllers/homecontroller.dart';
import 'package:kenzeno/app/modules/workout/controllers/workoutcontroller.dart';
import '../../../res/colors/colors.dart';
import '../../../res/fonts/textstyle.dart';
import '../../../res/assets/asset.dart';
import '../../../widgets/backbutton_widget.dart';
import '../../../widgets/daytrainningcard.dart';
import '../../../widgets/workoutcard.dart';

import 'package:kenzeno/app/modules/setting/controller/profilecontroller.dart';

class Recommendation extends StatelessWidget {
  const Recommendation({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>(); // Connects to backend
    final profileController = Get.isRegistered<ProfileController>()
        ? Get.find<ProfileController>()
        : Get.put(ProfileController());

    return Scaffold(
      appBar: AppBar(
        leading: const BackButtonBox(),
        title: Text(
          'Recommendations',
          style: AppTextStyles.poppinsBold.copyWith(
            color: AppColor.white,
            fontSize: 20.sp,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 8.h),
            child: Text(
              'Most Popular',
              style: AppTextStyles.poppinsBold.copyWith(
                color: AppColor.customPurple,
                fontSize: 18.sp,
              ),
            ),
          ),

          // Real data from backend
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return Center(
                  child: CircularProgressIndicator(
                    color: AppColor.customPurple,
                  ),
                );
              }

              if (controller.recommendedWorkouts.isEmpty) {
                return Center(
                  child: Text(
                    "No workouts available",
                    style: TextStyle(
                      color: AppColor.gray9CA3AF,
                      fontSize: 16.sp,
                    ),
                  ),
                );
              }

              final isTablet = MediaQuery.of(context).size.width >= 600;

              return GridView.builder(
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isTablet ? 3 : 2,
                  crossAxisSpacing: 12.w,
                  mainAxisSpacing: 18.h,
                  childAspectRatio: isTablet ? 0.85 : 0.72,
                ),
                itemCount: controller.recommendedWorkouts.length,
                itemBuilder: (context, index) {
                  final workout = controller.recommendedWorkouts[index];

                  return Container(
                    child: WorkoutCardWidget(
                      title: workout.name,
                      duration: workout.estimatedDuration,
                      exercises: "${workout.exerciseCount} exercises",
                      imagePath:
                          (workout.image != null && workout.image!.isNotEmpty)
                          ? workout.image!
                          : profileController.activeCoachImagePath,
                      isFavorite: workout.isFavorite,
                      onFavoriteToggle: () => controller.toggleFavorite(
                        contentType: 'userworkout',
                        id: workout.id,
                      ),
                      onTap: () {
                        final workoutController =
                            Get.isRegistered<WorkoutController>()
                            ? Get.find<WorkoutController>()
                            : Get.put(WorkoutController());
                        workoutController.loadWorkoutDetail(workout.id);
                      },
                    ),
                  );
                },
              );
            }),
          ),

          SizedBox(height: 20.h),
        ],
      ),
    );
  }
}
