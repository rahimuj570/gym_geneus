import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:kenzeno/app/modules/home/models/trackprogress.dart';
import 'package:kenzeno/app/res/assets/asset.dart';

import '../../workout/model/workoutmodel.dart';
import '../models/activity_model.dart';
import '../models/article.dart';
import '../models/challenge_model.dart';
import '../models/workout_model.dart';
import '../service/home_service.dart';
import 'package:toastification/toastification.dart';
import 'package:kenzeno/app/res/colors/colors.dart';
import 'package:kenzeno/app/res/fonts/textstyle.dart';

class HomeController extends GetxController {
  final HomeService _service = Get.put(HomeService());

  // Keep your existing variables
  final selectedDay = 15.obs;
  RxBool isLoading = false.obs;
  var selectedArticle = Rxn<Article>();
  RxBool isLoadingArticle = false.obs;
  RxList<Article> articles = <Article>[].obs;

  // Your existing lists
  RxList<WorkoutVideo> workoutVideos = <WorkoutVideo>[].obs;
  RxBool isLoadingWorkoutVideos = false.obs;
  var activities = <WorkoutActivity>[].obs;
  var challenges = <Challenge>[].obs;
  var weeklyChallenges = <Challenge>[].obs;
  var errorMessage = ''.obs;

  // PROGRESS TRACKING — UPDATED & FIXED
  var progress = Rxn<TrackProgress>();
  var recommendedWorkouts = <Workout>[].obs;
  var selectedDate = DateTime.now().obs;
  var isProgressLoading = true.obs; // ← Separate loading state for progress

  // HOME OVERVIEW API DATA
  var dailyWorkoutSession = Rxn<Workout>();
  var dailyChallenge = Rxn<Challenge>();
  RxBool isLoadingHomeOverview = false.obs;

  // ACTIVE GAMIFICATION CHALLENGE STATE
  var activeChallenge = Rxn<Challenge>();
  var isStartingChallenge = false.obs;
  var isClaimingReward = false.obs;

  @override
  void onInit() {
    fetchHomeOverview();
    fetchAllArticles();
    fetchWorkoutVideos();
    fetchActivities();
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    loadProgress(date: today);
    fetchRecommendedWorkouts();
    super.onInit();
  }

  Future<void> fetchHomeOverview() async {
    try {
      isLoadingHomeOverview.value = true;
      final result = await _service.fetchHomeOverview();
      dailyWorkoutSession.value = result['daily_workout_session'] as Workout?;
      dailyChallenge.value = result['daily_challenge'] as Challenge?;
    } catch (e) {
      print("Error fetching home overview: $e");
    } finally {
      isLoadingHomeOverview.value = false;
    }
  }

  // FIXED: Now uses separate loading state + safe int conversion
  Future<void> loadProgress({String? date}) async {
    try {
      isProgressLoading(true);
      final formattedDate =
          date ?? DateFormat('yyyy-MM-dd').format(selectedDate.value);
      final result = await _service.fetchDailyProgress(date: formattedDate);
      progress.value = result;
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
      progress.value = TrackProgress(
        progressPercentage: 0,
        caloriesBurned: 0,
        totalTrainingTime: 0,
      );
    } finally {
      isProgressLoading(false);
    }
  }

  // FIXED: Renamed to fetchDailyProgress + proper date formatting
  Future<void> fetchDailyProgress({String? date}) async {
    await loadProgress(date: date);
  }

  // Date selection — now updates progress correctly
  void selectDate(DateTime date) {
    selectedDate.value = date;
    final formatted = DateFormat('yyyy-MM-dd').format(date);
    loadProgress(date: formatted);
  }

  // Your existing methods — 100% untouched
  Future<void> fetchAllArticles() async {
    try {
      isLoading(true);
      final fetchedArticles = await _service.fetchArticles();
      articles.assignAll(fetchedArticles);
    } catch (e) {
      print("Error fetching articles: $e");
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchArticleDetail(int id) async {
    try {
      isLoadingArticle(true);
      final article = await _service.fetchArticleById(id);
      selectedArticle.value = article;
    } catch (e) {
      selectedArticle.value = null;
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
          "Article not found or failed to load",
          style: AppTextStyles.poppinsRegular.copyWith(color: Colors.white),
        ),
        alignment: Alignment.topRight,
        autoCloseDuration: const Duration(seconds: 4),
        borderRadius: BorderRadius.circular(12),
        showProgressBar: true,
      );
    } finally {
      isLoadingArticle(false);
    }
  }

  void clearSelectedArticle() => selectedArticle.value = null;

  Future<void> fetchWorkoutVideos() async {
    try {
      isLoadingWorkoutVideos(true);
      final videos = await _service.fetchWorkoutVideos();
      workoutVideos.assignAll(videos);
    } catch (e) {
      print("Error loading workout videos: $e");
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
          "Failed to load workout videos",
          style: AppTextStyles.poppinsRegular.copyWith(color: Colors.white),
        ),
        alignment: Alignment.topRight,
        autoCloseDuration: const Duration(seconds: 4),
        borderRadius: BorderRadius.circular(12),
        showProgressBar: true,
      );
    } finally {
      isLoadingWorkoutVideos(false);
    }
  }

  Future<void> fetchActivities() async {
    try {
      isLoading.value = true;
      final list = await _service.fetchTodayActivities();
      activities.assignAll(list);
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
          "Failed to load activities",
          style: AppTextStyles.poppinsRegular.copyWith(color: Colors.white),
        ),
        alignment: Alignment.topRight,
        autoCloseDuration: const Duration(seconds: 4),
        borderRadius: BorderRadius.circular(12),
        showProgressBar: true,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchChallenges(String type) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final list = await _service.fetchChallenges(
        challengeType: type,
        availableOnly: true,
      );

      if (type == "WEEKLY") {
        weeklyChallenges.assignAll(list);
      } else {
        challenges.assignAll(list);
      }
    } catch (e) {
      errorMessage.value = e.toString();
      toastification.show(
        type: ToastificationType.error,
        style: ToastificationStyle.fillColored,
        primaryColor: Colors.red,
        foregroundColor: Colors.white,
        title: Text(
          'Error',
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
      isLoading.value = false;
    }
  }

  /// Start Challenge (POST) and fetch complete details + user_progress (GET)
  Future<Challenge?> startChallengeAndLoad(int challengeId) async {
    try {
      isStartingChallenge.value = true;
      // 1. Try to start the challenge
      try {
        await _service.startChallenge(challengeId);
      } catch (e) {
        // If already started or active, backend may return a note, continue to fetch
        print("Note on starting challenge: $e");
      }

      // 2. Fetch latest challenge progress & detail
      final challenge = await _service.fetchChallengeDetail(challengeId);
      activeChallenge.value = challenge;
      return challenge;
    } catch (e) {
      rethrow;
    } finally {
      isStartingChallenge.value = false;
    }
  }

  /// Check progress of the challenge by calling GET /api/gamification/challenges/{id}/
  Future<void> refreshActiveChallenge(int challengeId) async {
    try {
      final challenge = await _service.fetchChallengeDetail(challengeId);
      activeChallenge.value = challenge;

      final progress = challenge.userProgress;
      if (progress != null && progress.isCompleted && !progress.pointsClaimed) {
        // Auto-claim reward if challenge is completed
        await claimChallengeReward(
          progressId: progress.id,
          points: challenge.completionPoints,
        );
      }
    } catch (e) {
      print('Error refreshing challenge progress: $e');
    }
  }

  /// Complete Exercise in Challenge: POST /api/gamification/challenges/complete-exercise/
  Future<bool> completeChallengeExercise({
    required int challengeId,
    required int exerciseIndex,
  }) async {
    try {
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(color: AppColor.customPurple),
        ),
        barrierDismissible: false,
      );

      await _service.completeChallengeExercise(
        challengeId: challengeId,
        exerciseIndex: exerciseIndex,
      );

      Get.back(); // dismiss loading dialog

      toastification.show(
        type: ToastificationType.success,
        style: ToastificationStyle.fillColored,
        primaryColor: AppColor.green16A34A,
        foregroundColor: Colors.white,
        title: Text(
          "Exercise Completed!",
          style: AppTextStyles.poppinsBold.copyWith(color: Colors.white),
        ),
        description: Text(
          "Great job! Exercise has been marked as complete.",
          style: AppTextStyles.poppinsRegular.copyWith(color: Colors.white),
        ),
        alignment: Alignment.topRight,
        autoCloseDuration: const Duration(seconds: 3),
        borderRadius: BorderRadius.circular(12),
        showProgressBar: true,
      );

      // Re-fetch challenge details to get updated user_progress
      await refreshActiveChallenge(challengeId);
      return true;
    } catch (e) {
      Get.back(); // dismiss loading dialog
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
      return false;
    }
  }

  /// Claim Reward when Challenge is Complete: POST /api/gamification/challenges/claim-reward/
  Future<void> claimChallengeReward({
    required int progressId,
    required int points,
  }) async {
    try {
      isClaimingReward.value = true;
      await _service.claimChallengeReward(progressId);

      // Refresh Home overview & Daily challenge
      fetchHomeOverview();

      toastification.show(
        type: ToastificationType.success,
        style: ToastificationStyle.fillColored,
        primaryColor: AppColor.green16A34A,
        foregroundColor: Colors.white,
        title: Text(
          "🎉 Challenge Completed!",
          style: AppTextStyles.poppinsBold.copyWith(color: Colors.white),
        ),
        description: Text(
          "Congratulations! You've claimed +$points points!",
          style: AppTextStyles.poppinsRegular.copyWith(color: Colors.white),
        ),
        alignment: Alignment.topRight,
        autoCloseDuration: const Duration(seconds: 5),
        borderRadius: BorderRadius.circular(12),
        showProgressBar: true,
      );
    } catch (e) {
      print('Error claiming challenge reward: $e');
    } finally {
      isClaimingReward.value = false;
    }
  }

  /// Check if a specific exercise is already completed in active challenge
  bool isExerciseCompleted(int index, UserExercise exercise) {
    final progress = activeChallenge.value?.userProgress;
    if (progress == null) return false;
    final completed = progress.completedExercises;

    return completed.contains(index) ||
        completed.contains(index.toString()) ||
        completed.contains(exercise.id) ||
        completed.contains(exercise.id.toString()) ||
        completed.contains(exercise.order);
  }

  Future<void> fetchRecommendedWorkouts() async {
    try {
      isLoading(true);
      final workouts = await _service.fetchRecommendedWorkouts();
      recommendedWorkouts.assignAll(workouts);
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
          "Failed to load workouts",
          style: AppTextStyles.poppinsRegular.copyWith(color: Colors.white),
        ),
        alignment: Alignment.topRight,
        autoCloseDuration: const Duration(seconds: 4),
        borderRadius: BorderRadius.circular(12),
        showProgressBar: true,
      );
      print("Workout fetch error: $e");
    } finally {
      isLoading(false);
    }
  }

  Future<void> toggleFavorite({
    required String contentType,
    required int id,
  }) async {
    // 1. Optimistically toggle state immediately before API completes
    applyFavoriteToggleLocally(contentType: contentType, id: id);

    try {
      final success = await _service.toggleFavorite(
        contentType: contentType,
        objectId: id,
      );

      // 2. If API fails, revert the state back and show error notification
      if (!success) {
        applyFavoriteToggleLocally(contentType: contentType, id: id);
        _showFavoriteErrorToast();
      }
    } catch (e) {
      print("Toggle favorite error: $e");
      // Revert state back on exception
      applyFavoriteToggleLocally(contentType: contentType, id: id);
      _showFavoriteErrorToast();
    }
  }

  void applyFavoriteToggleLocally({
    required String contentType,
    required int id,
  }) {
    if (contentType == 'article') {
      final index = articles.indexWhere((a) => a.id == id);
      if (index != -1) {
        final article = articles[index];
        articles[index] = article.copyWith(isFavorite: !article.isFavorite);
        articles.refresh();
      }
      if (selectedArticle.value != null && selectedArticle.value!.id == id) {
        selectedArticle.value = selectedArticle.value!.copyWith(
          isFavorite: !selectedArticle.value!.isFavorite,
        );
      }
    } else if (contentType == 'workout' || contentType == 'userworkout') {
      final index = recommendedWorkouts.indexWhere((w) => w.id == id);
      if (index != -1) {
        final workout = recommendedWorkouts[index];
        recommendedWorkouts[index] =
            workout.copyWith(isFavorite: !workout.isFavorite);
        recommendedWorkouts.refresh();
      }
    } else if (contentType == 'workoutvideo') {
      final wIndex = recommendedWorkouts.indexWhere((w) => w.id == id);
      if (wIndex != -1) {
        final workout = recommendedWorkouts[wIndex];
        recommendedWorkouts[wIndex] =
            workout.copyWith(isFavorite: !workout.isFavorite);
        recommendedWorkouts.refresh();
      }
      final vIndex = workoutVideos.indexWhere((v) => v.id == id);
      if (vIndex != -1) {
        final video = workoutVideos[vIndex];
        workoutVideos[vIndex] = video.copyWith(isFavorite: !video.isFavorite);
        workoutVideos.refresh();
      }
    }
  }

  void _showFavoriteErrorToast() {
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
        "Failed to update favorite status",
        style: AppTextStyles.poppinsRegular.copyWith(color: Colors.white),
      ),
      alignment: Alignment.topRight,
      autoCloseDuration: const Duration(seconds: 3),
      borderRadius: BorderRadius.circular(12),
      showProgressBar: true,
    );
  }

  // Your dummy data — unchanged
  final weekDays = [
    {'day': 'TODAY', 'date': 15, 'hasActivity': false},
    {'day': 'T', 'date': 16, 'hasActivity': true},
    {'day': 'W', 'date': 17, 'hasActivity': true},
    {'day': 'T', 'date': 18, 'hasActivity': false},
    {'day': 'F', 'date': 19, 'hasActivity': false},
    {'day': 'S', 'date': 20, 'hasActivity': true},
    {'day': 'S', 'date': 21, 'hasActivity': true},
  ];

  final List<String> workoutImages = [
    ImageAssets.img_4,
    ImageAssets.img_5,
    ImageAssets.img_3,
    ImageAssets.img_2,
  ];

  var selectedWorkoutTab = 0.obs;

  final List<Map<String, dynamic>> workoutTabDetails = [
    {
      'title': 'Special for Kenz',
      'duration': '53 min',
      'subtitle': 'Chest, Shoulders, Core',
      'images': [
        ImageAssets.img_4,
        ImageAssets.img_5,
        ImageAssets.img_3,
        ImageAssets.img_2,
      ],
    },
    {
      'title': 'Gym',
      'duration': '45 min',
      'subtitle': 'Full Body, Strength Training',
      'images': [
        ImageAssets.img_12,
        ImageAssets.img_3,
        ImageAssets.img_4,
        ImageAssets.img_5,
      ],
    },
  ];


  RxList<Map<String, String>> articless = <Map<String, String>>[
    {'imagePath': ImageAssets.img_3, 'title': 'First Article'},
    {'imagePath': ImageAssets.img_12, 'title': 'Second Article'},
    {'imagePath': ImageAssets.img_3, 'title': 'Third Article'},
    {'imagePath': ImageAssets.img_12, 'title': 'Fourth Article'},
  ].obs;

  RxList<bool> isFilled = <bool>[false, false, false, false].obs;
  void toggleFilled(int index) => isFilled[index] = !isFilled[index];

  final List<Map<String, String>> recommendations = [
    {
      'title': 'Squat Exercise',
      'duration': '12 Minutes',
      'exercises': '120 Kcal',
      'imagePath': ImageAssets.img_12,
    },
    {
      'title': 'Full Body Stretching',
      'duration': '12 Minutes',
      'exercises': '120 Kcal',
      'imagePath': ImageAssets.img_12,
    },
  ];
}
