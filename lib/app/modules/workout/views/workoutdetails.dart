import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:kenzeno/app/modules/setting/controller/profilecontroller.dart';
import 'package:kenzeno/app/modules/workout/widgets/stepswidgets.dart';
import 'package:kenzeno/app/res/assets/asset.dart';
import 'package:kenzeno/app/widgets/backbutton_widget.dart';

import '../../../res/colors/colors.dart';
import '../../../res/fonts/textstyle.dart';
import '../../../widgets/daytrainningcard.dart';

import '../controllers/workoutcontroller.dart';

import 'excercisedetails.dart';

class WorkoutDetailsScreen extends StatelessWidget {
  const WorkoutDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the detailed workout from controller (loaded via loadWorkoutDetail(id))
    final workout = Get.find<WorkoutController>().selectedWorkoutDetail.value;

    // Safety: if somehow null (should never happen)
    if (workout == null ||
        workout.exercises == null ||
        workout.exercises!.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          leading: BackButtonBox(),
          centerTitle: true,
          title: Text("Workout"),
        ),
        body: Center(
          child: Text(
            "No exercises found",
            style: TextStyle(color: AppColor.white),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: BackButtonBox(),
        centerTitle: true,
        title: Text(
          workout.difficulty.toUpperCase(), // Shows BEGINNER / INTERMEDIATE / ADVANCED
          style: AppTextStyles.poppinsBold.copyWith(
            color: AppColor.white,
            fontSize: 20.sp,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header Card (Training of the Day style)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10.h),
              child: Container(
                color: AppColor.customPurple,
                padding: EdgeInsets.all(12.w),
                child: TrainingOfTheDayCard(
                  headtitle: workout.name,
                  title: workout.name,
                  imagePath: workout.image?.isNotEmpty == true
                      ? workout.image!
                      : (Get.isRegistered<ProfileController>()
                          ? Get.find<ProfileController>().activeCoachImagePath
                          : ImageAssets.img_12),
                  duration: workout.estimatedDuration,
                  calories: workout.estimatedCalories,
                  exercises: "${workout.exerciseCount} Exercises",
                  ontap: () {},
                ),
              ),
            ),
            SizedBox(height: 20.h),

            // 2. Single Round (your design uses one round)
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 10.h),
              child: Text(
                "Round 1", // You can make this dynamic later if needed
                style: AppTextStyles.poppinsBold.copyWith(
                  color: AppColor.white,
                  fontSize: 20.sp,
                ),
              ),
            ),

            // 3. All Exercises (using your existing TrainingStepWidget)
            ...workout.exercises!.map((exercise) {
              return TrainingStepWidget(
                step: exercise, // Pass the real UserExercise object
                onTap: () {
                  Get.to(
                    () => ExerciseDetailsScreen(workutid: workout.id),
                    arguments: exercise, // Pass the clicked exercise
                    transition: Transition.rightToLeft,
                  );
                },
              );
            }).toList(),

            SizedBox(height: 50.h),
          ],
        ),
      ),
    );
  }
}
