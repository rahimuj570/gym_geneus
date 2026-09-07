// lib/controllers/workout_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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

  @override
  void onInit() {
    super.onInit();
    loadAllWorkouts();
  }

  void selectTab(String tab) {
    selectedTab.value = tab;
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
        final updated =
            list[index].copyWith(isFavorite: !list[index].isFavorite);
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

  // Load full workout detail (with exercises) when user taps
  Future<void> loadWorkoutDetail(int workoutId) async {
    try {
      Get.dialog(
        Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );
      final detail = await _service.fetchWorkoutDetail(workoutId);
      selectedWorkoutDetail.value = detail;
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

  Future<void> trackWorkoutProgress({
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

      await _service.trackProgress(
        userWorkoutId: userWorkoutId,
        userExerciseId: userExerciseId,
      );

      Get.back(); // Dismiss the loading dialog

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

      // Optional: refresh data or update UI state
      // loadAllWorkouts();
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
}
