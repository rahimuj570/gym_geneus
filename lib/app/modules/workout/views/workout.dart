// lib/app/modules/workout/views/workout_view.dart   (or whatever your file is named)

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import 'package:kenzeno/app/res/assets/asset.dart';
import 'package:kenzeno/app/widgets/backbutton_widget.dart';

import '../../../res/colors/colors.dart';
import '../../../res/fonts/textstyle.dart';
import '../../../widgets/daytrainningcard.dart';
import '../../home/controllers/searchcontroller.dart';
import '../../setting/widgets/trainnigstep.dart';
import '../controllers/workoutcontroller.dart';

import 'package:kenzeno/app/modules/setting/controller/profilecontroller.dart';

class Workout extends StatelessWidget {
  final SearchController controller = Get.find();
  Workout({super.key});

  Widget _buildTabBar(WorkoutController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      child: Obx(
        () => SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: controller.tabs.map((tab) {
              final isSelected = tab == controller.selectedTab.value;
              return Padding(
                padding: EdgeInsets.only(right: 10.w),
                child: GestureDetector(
                  onTap: () => controller.selectTab(tab),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColor.customPurple
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10.r),
                      border: isSelected
                          ? null
                          : Border.all(color: AppColor.gray9CA3AF, width: 1.w),
                    ),
                    child: Text(
                      tab,
                      style: AppTextStyles.poppinsRegular.copyWith(
                        color: isSelected ? Colors.white : AppColor.white,
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final WorkoutController controller = Get.put(WorkoutController());
    final SearchController2 searchController=Get.find();
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: const BackButtonBox(),
        centerTitle: true,
        title: Text(
          'Workout',
          style: AppTextStyles.poppinsBold.copyWith(
            color: AppColor.white,
            fontSize: 20.sp,
          ),
        ),
        actions: [
          SvgPicture.asset(ImageAssets.svg38, height: 20.h),
          SizedBox(width: 15.w),
          SvgPicture.asset(ImageAssets.svg39, height: 20.h),
          SizedBox(width: 10.w),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(),
        ),
      ),

      body: Column(
        children: [
          // Tab Bar
          _buildTabBar(controller),

          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              final mainWorkout = controller.mainCardWorkout;
              final sectionWorkouts = controller.sectionWorkouts;

              // Empty state
              if (mainWorkout == null) {
                return const Center(child: Text("No workouts found"));
              }

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Training of the Day Card
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 10.h,
                      ),
                      child: TrainingOfTheDayCard(
                        headtitle: "Trainning of the day",
                        title: mainWorkout.name,
                        imagePath: mainWorkout.image?.isNotEmpty == true
                            ? mainWorkout.image!
                            : (Get.isRegistered<ProfileController>()
                                ? Get.find<ProfileController>().activeCoachImagePath
                                : ImageAssets.img_12),
                        duration: mainWorkout.estimatedDuration,
                        calories: mainWorkout.estimatedCalories,
                        exercises: "${mainWorkout.exerciseCount} Exercises",
                        ontap: () =>
                            controller.loadWorkoutDetail(mainWorkout.id),
                      ),
                    ),
                    SizedBox(height: 10.h),

                    // 2. Section Title
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Text(
                        "Explore ${controller.selectedTab.value} Workouts",
                        style: AppTextStyles.poppinsBold.copyWith(
                          color: AppColor.white,
                          fontSize: 18.sp,
                        ),
                      ),
                    ),
                    SizedBox(height: 5.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Text(
                        "Choose a workout to start your session",
                        style: AppTextStyles.poppinsRegular.copyWith(
                          color: AppColor.white,
                          fontSize: 12.sp,
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),

                    // 3. Sub-Cards (exactly your original layout)
                    ...sectionWorkouts.map(
                      (workout) => TrainingCardWidget(
                        title: workout.name,
                        duration: workout.estimatedDuration,
                        calories: workout.estimatedCalories,
                        exercises: "${workout.exerciseCount} Exercises",
                        imagePath:
                            workout.image != null && workout.image!.isNotEmpty
                            ? workout.image!
                            : (Get.isRegistered<ProfileController>()
                                ? Get.find<ProfileController>().activeCoachImagePath
                                : ImageAssets.img_12),
                        type: 'Workout',
                        isFavorite: workout.isFavorite,
                        onFavoriteToggle: () => searchController.toggleFavorite(
                          contentType: 'workoutvideo',
                          id: workout.id,
                        ),
                        isVideo: false,
                        onTap: () => controller.loadWorkoutDetail(workout.id),
                      ),
                    ),

                    SizedBox(height: 100.h),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
