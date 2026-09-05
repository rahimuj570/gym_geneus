import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kenzeno/app/modules/workout/views/workoutdetails.dart';
import 'package:kenzeno/app/res/assets/asset.dart';
import '../../nutrition/views/contentsplash.dart';
import '../../workout/model/work_out_model.dart';

class Competition extends StatelessWidget {
  const Competition({super.key});

  @override
  Widget build(BuildContext context) {
    final workoutData = WorkoutData(
      title: 'Cycling Challenge',
      duration: '40 min',
      calories: '420 kcal',
      exercises: '10 Exercises',
      imagePath: ImageAssets.img_24,
      isVideo: true,
      steps: beginnerWorkoutSteps,
    );

    return ContentSplash(
      imageUrl: ImageAssets.img_25,
      icon: ImageAssets.svg50,
      title: 'Cycling Challenge',
      description:
          'Challenge yourself and reach new milestones with today\'s high-energy cycling routine!',
      buttonText: 'Start Now',
      onTap: () {
        Get.to(
          () => WorkoutDetailsScreen(),
          transition: Transition.rightToLeft,
        );
      },
    );
  }
}
