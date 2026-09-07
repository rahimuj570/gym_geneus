import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:kenzeno/app/modules/home/controllers/homecontroller.dart';
import 'package:kenzeno/app/modules/setting/controller/profilecontroller.dart';
import 'package:kenzeno/app/modules/workout/widgets/stepswidgets.dart';
import 'package:kenzeno/app/res/assets/asset.dart';
import 'package:kenzeno/app/widgets/backbutton_widget.dart';
import 'package:toastification/toastification.dart';

import '../../../res/colors/colors.dart';
import '../../../res/fonts/textstyle.dart';
import '../../../widgets/daytrainningcard.dart';

import '../controllers/workoutcontroller.dart';
import 'excercisedetails.dart';

class WorkoutDetailsScreen extends StatelessWidget {
  final int? challengeId;
  const WorkoutDetailsScreen({super.key, this.challengeId});

  @override
  Widget build(BuildContext context) {
    final workoutController = Get.find<WorkoutController>();
    final homeController =
        Get.isRegistered<HomeController>() ? Get.find<HomeController>() : null;
    final bool isChallenge = challengeId != null && homeController != null;

    return Obx(() {
      // Get the detailed workout from controller (loaded via loadWorkoutDetail(id))
      final workout = workoutController.selectedWorkoutDetail.value;

      // Safety: if somehow null
      if (workout == null ||
          workout.exercises == null ||
          workout.exercises!.isEmpty) {
        return Scaffold(
          appBar: AppBar(
            leading: const BackButtonBox(),
            centerTitle: true,
            title: const Text("Workout"),
          ),
          body: const Center(
            child: Text(
              "No exercises found",
              style: TextStyle(color: AppColor.white),
            ),
          ),
        );
      }

      final activeChallenge = homeController?.activeChallenge.value;
      final titleText = isChallenge && activeChallenge != null
          ? activeChallenge.challengeTypeDisplay.toUpperCase()
          : workout.difficulty.toUpperCase();

      return Scaffold(
        appBar: AppBar(
          leading: const BackButtonBox(),
          centerTitle: true,
          title: Text(
            titleText,
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
                            ? Get.find<ProfileController>()
                                .activeCoachImagePath
                            : ImageAssets.img_12),
                    duration: workout.estimatedDuration,
                    calories: workout.estimatedCalories,
                    exercises: "${workout.exerciseCount} Exercises",
                    ontap: () {},
                  ),
                ),
              ),
              SizedBox(height: 20.h),

              // 2. Single Round Header
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 10.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Round 1",
                      style: AppTextStyles.poppinsBold.copyWith(
                        color: AppColor.white,
                        fontSize: 20.sp,
                      ),
                    ),
                    if (isChallenge &&
                        activeChallenge?.userProgress != null) ...[
                      Text(
                        "${activeChallenge!.userProgress!.completedExercises.length}/${workout.exercises!.length} Done",
                        style: AppTextStyles.poppinsMedium.copyWith(
                          color: AppColor.green16A34A,
                          fontSize: 14.sp,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // 3. All Exercises with isCompleted check
              ...workout.exercises!.asMap().entries.map((entry) {
                final int index = entry.key;
                final exercise = entry.value;
                final bool isCompleted = isChallenge &&
                    (homeController.isExerciseCompleted(index, exercise));

                return TrainingStepWidget(
                  step: exercise,
                  isCompleted: isCompleted,
                  onTap: () async {
                    if (isCompleted) {
                      toastification.show(
                        type: ToastificationType.info,
                        style: ToastificationStyle.fillColored,
                        primaryColor: AppColor.green16A34A,
                        foregroundColor: Colors.white,
                        title: Text(
                          "Already Completed",
                          style: AppTextStyles.poppinsBold.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        description: Text(
                          "You have already completed this exercise.",
                          style: AppTextStyles.poppinsRegular.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        alignment: Alignment.topRight,
                        autoCloseDuration: const Duration(seconds: 3),
                        borderRadius: BorderRadius.circular(12),
                        showProgressBar: true,
                      );
                      return;
                    }

                    await Get.to(
                      () => ExerciseDetailsScreen(
                        workutid: workout.id,
                        challengeId: challengeId,
                        exerciseIndex: index,
                        isChallenge: isChallenge,
                      ),
                      arguments: exercise,
                      transition: Transition.rightToLeft,
                    );

                    if (isChallenge && challengeId != null) {
                      await homeController.refreshActiveChallenge(challengeId!);
                    }
                  },
                );
              }),

              SizedBox(height: 50.h),
            ],
          ),
        ),
      );
    });
  }
}
