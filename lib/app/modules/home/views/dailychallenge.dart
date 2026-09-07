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
          int? challengeId = controller.dailyChallenge.value?.id;
          if (challengeId == null) {
            await controller.fetchChallenges("DAILY");
            if (controller.challenges.isNotEmpty) {
              challengeId = controller.challenges.first.id;
            }
          }

          if (challengeId == null) {
            Get.back(); // close dialog
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

          // Call Start API (POST) and fetch complete details + progress (GET)
          final challenge =
              await controller.startChallengeAndLoad(challengeId);
          Get.back(); // close dialog

          if (challenge == null) return;

          // Convert Challenge → Workout for WorkoutDetailsScreen
          final workout = Workout(
            id: challenge.id,
            name: challenge.name,
            description: challenge.description,
            estimatedDuration: '${challenge.estimatedDuration} min',
            estimatedCalories: '${challenge.estimatedCalories} kcal',
            exerciseCount: challenge.exercises.length,
            difficulty: challenge.difficultyDisplay.isNotEmpty
                ? challenge.difficultyDisplay
                : 'Beginner',
            image: '',
            exercises: challenge.exercises,
          );

          // Set it for WorkoutDetailsScreen
          workoutController.selectedWorkoutDetail.value = workout;

          Get.to(
            () => WorkoutDetailsScreen(challengeId: challenge.id),
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
              e.toString().replaceAll("Exception: ", ""),
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
