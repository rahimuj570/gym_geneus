// lib/controllers/workout_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kenzeno/app/modules/home/controllers/homecontroller.dart';
import 'package:kenzeno/app/modules/workout/views/workoutdetails.dart';
import 'package:kenzeno/app/res/colors/colors.dart';

import 'package:kenzeno/app/modules/home/service/home_service.dart';
import '../model/workoutmodel.dart';
import '../services/workout_services.dart';
import 'package:toastification/toastification.dart';
import 'package:kenzeno/app/res/fonts/textstyle.dart';

class WorkoutController extends GetxController {
  final WorkoutService _service = Get.find<WorkoutService>();
  final HomeService _homeService = Get.isRegistered<HomeService>()
      ? Get.find<HomeService>()
      : Get.put(HomeService());

  // Tabs
  var selectedTab = 'Beginner'.obs;
  final List<String> tabs = ['Beginner', 'Intermediate', 'Advanced'];

  // API Data
  var workoutsByDifficulty = <String, List<Workout>>{}.obs;
  var isLoading = true.obs;
  var selectedWorkoutDetail = Rxn<Workout>();
  var completedExerciseIds = <dynamic>[].obs;
  var workoutProgress = Rxn<WorkoutProgressResponse>();

  @override
  void onInit() {
    super.onInit();
    loadAllWorkouts();
  }

  void selectTab(String tab) {
    selectedTab.value = tab;
  }

  bool isExerciseCompleted(int index, UserExercise exercise) {
    if (completedExerciseIds.contains(exercise.id) ||
        completedExerciseIds.contains(exercise.id.toString()) ||
        completedExerciseIds.contains(index) ||
        completedExerciseIds.contains(exercise.order)) {
      return true;
    }
    return false;
  }

  Future<void> toggleFavorite(int workoutId) async {
    applyLocalFavoriteToggle(workoutId);

    try {
      final success = await _homeService.toggleFavorite(
        contentType: 'userworkout',
        objectId: workoutId,
      );

      if (!success) {
        applyLocalFavoriteToggle(workoutId);
      }
    } catch (e) {
      applyLocalFavoriteToggle(workoutId);
    }
  }

  void applyLocalFavoriteToggle(int workoutId) {
    workoutsByDifficulty.forEach((difficulty, list) {
      final index = list.indexWhere((w) => w.id == workoutId);
      if (index != -1) {
        final updated = list[index].copyWith(
          isFavorite: !list[index].isFavorite,
        );
        final newList = List<Workout>.from(list);
        newList[index] = updated;
        workoutsByDifficulty[difficulty] = newList;
      }
    });
    workoutsByDifficulty.refresh();
  }

  // Load all workouts grouped by difficulty
  Future<void> loadAllWorkouts() async {
    try {
      isLoading(true);

      final beginner = await _service.fetchWorkouts(difficulty: "Beginner");
      final intermediate = await _service.fetchWorkouts(
        difficulty: "Intermediate",
      );
      final advanced = await _service.fetchWorkouts(difficulty: "Advanced");

      workoutsByDifficulty.assignAll({
        'Beginner': beginner,
        'Intermediate': intermediate,
        'Advanced': advanced,
      });
    } catch (e) {
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
          e.toString(),
          style: AppTextStyles.poppinsRegular.copyWith(color: Colors.white),
        ),
        alignment: Alignment.topRight,
        autoCloseDuration: const Duration(seconds: 4),
        borderRadius: BorderRadius.circular(12),
        showProgressBar: true,
      );
    } finally {
      isLoading(false);
    }
  }

  // Get main featured workout (first one)
  Workout? get mainCardWorkout {
    final list = workoutsByDifficulty[selectedTab.value] ?? [];
    return list.isNotEmpty ? list.first : null;
  }

  // Get remaining workouts as "cards"
  List<Workout> get sectionWorkouts {
    final list = workoutsByDifficulty[selectedTab.value] ?? [];
    if (list.isEmpty) return [];
    return list.length > 1 ? list.sublist(1) : [];
  }

  Future<void> fetchWorkoutProgress(int userWorkoutId) async {
    try {
      final progressResult = await _service.getWorkoutProgress(
        userWorkoutId: userWorkoutId,
      );
      if (progressResult != null) {
        workoutProgress.value = progressResult;
        if (progressResult.workoutProgress?.completedExercises != null) {
          completedExerciseIds.assignAll(
            progressResult.workoutProgress!.completedExercises,
          );
        }
      }
    } catch (e) {
      print("Error fetching workout progress: $e");
    }
  }

  // Load full workout detail (with exercises) when user taps
  Future<void> loadWorkoutDetail(int workoutId) async {
    try {
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(color: AppColor.customPurple),
        ),
        barrierDismissible: false,
      );
      completedExerciseIds.clear();
      workoutProgress.value = null;

      final detail = await _service.fetchWorkoutDetail(workoutId);
      selectedWorkoutDetail.value = detail;

      // Fetch latest workout progress from API
      await fetchWorkoutProgress(workoutId);

      if (completedExerciseIds.isEmpty && detail.progress?.completedExercises != null) {
        completedExerciseIds.assignAll(detail.progress!.completedExercises);
      }

      print(detail);
      Get.back(); // Dismiss the loading dialog
      Get.to(() => const WorkoutDetailsScreen());
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
          e.toString(),
          style: AppTextStyles.poppinsRegular.copyWith(color: Colors.white),
        ),
        alignment: Alignment.topRight,
        autoCloseDuration: const Duration(seconds: 4),
        borderRadius: BorderRadius.circular(12),
        showProgressBar: true,
      );
    }
  }

  Future<WorkoutProgressResponse?> trackWorkoutProgress({
    required int userWorkoutId,
    int? userExerciseId,
  }) async {
    try {
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(color: AppColor.customPurple),
        ),
        barrierDismissible: false,
      );

      final result = await _service.trackProgress(
        userWorkoutId: userWorkoutId,
        userExerciseId: userExerciseId,
      );

      Get.back(); // Dismiss the loading dialog

      if (result != null) {
        workoutProgress.value = result;
        if (result.workoutProgress?.completedExercises != null) {
          completedExerciseIds.assignAll(
            result.workoutProgress!.completedExercises,
          );
        }
      } else if (userExerciseId != null) {
        if (!completedExerciseIds.contains(userExerciseId)) {
          completedExerciseIds.add(userExerciseId);
        }
      }

      // Refresh Home progress if registered
      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().loadProgress();
      }

      toastification.show(
        type: ToastificationType.success,
        style: ToastificationStyle.fillColored,
        primaryColor: AppColor.green16A34A,
        foregroundColor: Colors.white,
        title: Text(
          "Success",
          style: AppTextStyles.poppinsBold.copyWith(color: Colors.white),
        ),
        description: Text(
          "Workout progress saved!",
          style: AppTextStyles.poppinsRegular.copyWith(color: Colors.white),
        ),
        alignment: Alignment.topRight,
        autoCloseDuration: const Duration(seconds: 4),
        borderRadius: BorderRadius.circular(12),
        showProgressBar: true,
      );

      return result;
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
          e.toString(),
          style: AppTextStyles.poppinsRegular.copyWith(color: Colors.white),
        ),
        alignment: Alignment.topRight,
        autoCloseDuration: const Duration(seconds: 4),
        borderRadius: BorderRadius.circular(12),
        showProgressBar: true,
      );
      return null;
    }
  }
}
