// lib/app/modules/gamification/views/dailychallenge.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:kenzeno/app/modules/home/controllers/homecontroller.dart';

import 'package:kenzeno/app/modules/workout/controllers/workoutcontroller.dart';
import 'package:kenzeno/app/modules/workout/views/workoutdetails.dart';
import 'package:kenzeno/app/res/assets/asset.dart';
import '../../nutrition/views/contentsplash.dart';

import '../../workout/model/workoutmodel.dart';
import 'package:toastification/toastification.dart';
import 'package:kenzeno/app/res/fonts/textstyle.dart';
import 'package:kenzeno/app/res/colors/colors.dart';
// Your real model

class DailyChallenge extends StatelessWidget {
  const DailyChallenge({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    final workoutController = Get.find<WorkoutController>();

    return ContentSplash(
      imageUrl: ImageAssets.img_24,
      icon: ImageAssets.svg50,
      title: 'Daily Challenge',
      description:
          'Push your limits today! Complete your daily workout challenge to build consistency, stay fit, and unlock your potential.',
      buttonText: 'Start Now',
      onTap: () async {
        // Show loading
        Get.dialog(
          const Center(child: CircularProgressIndicator(color: Colors.white)),
          barrierDismissible: false,
        );

        try {
          await controller.fetchChallenges("DAILY");
          Get.back(); // close dialog

          if (controller.challenges.isEmpty) {
            toastification.show(
              type: ToastificationType.info,
              style: ToastificationStyle.fillColored,
              primaryColor: AppColor.green16A34A,
              foregroundColor: Colors.white,
              title: Text(
                "No Challenge",
                style: AppTextStyles.poppinsBold.copyWith(color: Colors.white),
              ),
              description: Text(
                "No active daily challenge today",
                style: AppTextStyles.poppinsRegular.copyWith(
                  color: Colors.white,
                ),
              ),
              alignment: Alignment.topRight,
              autoCloseDuration: const Duration(seconds: 4),
              borderRadius: BorderRadius.circular(12),
              showProgressBar: true,
            );
            return;
          }

          final challenge = controller.challenges.first;

          // Convert Challenge → Workout (perfect 1:1 mapping)
          final workout = Workout(
            id: challenge.id,
            name: challenge.name,
            description: challenge.description,
            estimatedDuration: challenge.estimatedDuration.toString(),
            estimatedCalories: challenge.estimatedCalories.toString(),
            exerciseCount: challenge.exercises.length,
            difficulty: challenge.difficultyDisplay,
            image: '', // or add image field later
            exercises: challenge.exercises, // Direct reuse!
          );

          // Set it exactly how your WorkoutDetailsScreen expects
          workoutController.selectedWorkoutDetail.value = workout;

          Get.to(
            () => const WorkoutDetailsScreen(),
            transition: Transition.rightToLeft,
          );
        } catch (e) {
          Get.back();
          toastification.show(
            type: ToastificationType.error,
            style: ToastificationStyle.fillColored,
            primaryColor: Colors.red,
            foregroundColor: Colors.white,
            title: Text(
              "Error",
              style: AppTextStyles.poppinsBold.copyWith(color: Colors.white),
            ),
            description: Text(
              "Failed to load challenge",
              style: AppTextStyles.poppinsRegular.copyWith(color: Colors.white),
            ),
            alignment: Alignment.topRight,
            autoCloseDuration: const Duration(seconds: 4),
            borderRadius: BorderRadius.circular(12),
            showProgressBar: true,
          );
        }
      },
    );
  }
}
