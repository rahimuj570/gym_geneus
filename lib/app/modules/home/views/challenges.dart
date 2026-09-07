import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:kenzeno/app/modules/home/controllers/homecontroller.dart';
import 'package:kenzeno/app/modules/workout/controllers/workoutcontroller.dart';
import 'package:kenzeno/app/modules/workout/views/workoutdetails.dart';
import 'package:kenzeno/app/modules/workout/model/workoutmodel.dart';
import '../../../res/colors/colors.dart';
import '../../../res/fonts/textstyle.dart';
import '../../setting/widgets/trainnigstep.dart';

class ChallengesPage extends StatefulWidget {
  const ChallengesPage({super.key});

  @override
  State<ChallengesPage> createState() => _ChallengesPageState();
}

class _ChallengesPageState extends State<ChallengesPage> {
  final homeController = Get.find<HomeController>();
  final workoutController = Get.find<WorkoutController>();

  @override
  void initState() {
    super.initState();
    // Use Future.microtask to avoid calling fetchChallenges during the build phase,
    // which prevents the "setState() or markNeedsBuild() called during build" error.
    Future.microtask(() => homeController.fetchChallenges("WEEKLY"));
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => homeController.fetchChallenges("WEEKLY"),
      color: Colors.white,
      backgroundColor: AppColor.customPurple,
      child: SingleChildScrollView(
        // Ensure the scroll view is always scrollable to allow pull-to-refresh
        // even when the list is empty.
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 10.h),
              child: Text(
                'Weekly Challenges',
                style: AppTextStyles.poppinsBold.copyWith(
                  color: Colors.white,
                  fontSize: 22.sp,
                ),
              ),
            ),

            Obx(() {
              if (homeController.isLoading.value &&
                  homeController.weeklyChallenges.isEmpty) {
                return SizedBox(
                  height: 300.h,
                  child: const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                );
              }

              if (homeController.weeklyChallenges.isEmpty) {
                return SizedBox(
                  height: 300.h,
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Text(
                        'No active weekly challenges found',
                        style: AppTextStyles.poppinsMedium.copyWith(
                          color: Colors.white70,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                  ),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: homeController.weeklyChallenges.length,
                itemBuilder: (context, index) {
                  final challenge = homeController.weeklyChallenges[index];

                  return TrainingCardWidget(
                    title: challenge.name,
                    subtitle: challenge.description,
                    imagePath: '',
                    type: 'article',
                    isVideo: false,
                    duration: '${challenge.estimatedDuration} min',
                    calories: '${challenge.estimatedCalories} kcal',
                    exercises: '${challenge.exercises.length} exercises',
                    showFavorite: false,
                    onTap: () async {
                      Get.dialog(
                        const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                        barrierDismissible: false,
                      );
                      try {
                        final detailedChallenge = await homeController
                            .startChallengeAndLoad(challenge.id);
                        Get.back();

                        final workout = Workout(
                          id: detailedChallenge?.id ?? challenge.id,
                          name: detailedChallenge?.name ?? challenge.name,
                          description: detailedChallenge?.description ??
                              challenge.description,
                          estimatedDuration:
                              '${detailedChallenge?.estimatedDuration ?? challenge.estimatedDuration} min',
                          estimatedCalories:
                              '${detailedChallenge?.estimatedCalories ?? challenge.estimatedCalories} kcal',
                          exerciseCount: detailedChallenge?.exercises.length ??
                              challenge.exercises.length,
                          difficulty: detailedChallenge
                                  ?.difficultyDisplay.isNotEmpty ==
                              true
                              ? detailedChallenge!.difficultyDisplay
                              : challenge.difficultyDisplay,
                          image: '',
                          exercises: detailedChallenge?.exercises ??
                              challenge.exercises,
                        );

                        workoutController.selectedWorkoutDetail.value =
                            workout;

                        Get.to(
                          () => WorkoutDetailsScreen(
                            challengeId: detailedChallenge?.id ?? challenge.id,
                          ),
                          transition: Transition.rightToLeft,
                        );
                      } catch (e) {
                        Get.back();
                      }
                    },
                  );
                },
              );
            }),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }
}
