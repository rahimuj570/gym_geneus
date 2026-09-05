import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kenzeno/app/modules/home/service/home_service.dart';
import '../../workout/model/workoutmodel.dart';
import '../models/article.dart';

class SearchController2 extends GetxController
    with GetSingleTickerProviderStateMixin {
  late TabController tabController;
  final searchController = TextEditingController();
  final HomeService _homeService = Get.find<HomeService>();

  final List<String> categories = ['All', 'Workout', 'Articles'];

  var selectedIndex = 0.obs;
  var isLoading = false.obs;
  var workoutResults = <Workout>[].obs;
  var articleResults = <Article>[].obs;
  var errorMessage = ''.obs;
  var searchBarText = ''.obs; // Added for Obx in search field

  Timer? _debounce;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: categories.length, vsync: this);
    tabController.addListener(() {
      selectedIndex.value = tabController.index;
    });

    // Initial fetch (top searches)
    performSearch("");

    searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    searchBarText.value = searchController.text; // Update Rx variable
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    
    // Trigger immediately if empty or very short, otherwise short debounce
    if (searchController.text.isEmpty) {
      performSearch("");
    } else {
      _debounce = Timer(const Duration(milliseconds: 100), () {
        performSearch(searchController.text);
      });
    }
  }

  Future<void> performSearch(String query) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final results = await _homeService.search(query);
      
      workoutResults.assignAll(results['workouts'] as List<Workout>);
      articleResults.assignAll(results['articles'] as List<Article>);
      
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleFavorite({
    required String contentType,
    required int id,
  }) async {
    try {
      final success = await _homeService.toggleFavorite(
        contentType: contentType,
        objectId: id,
      );
print(success);
      if (success) {
        if (contentType == 'article') {
          final index = articleResults.indexWhere((a) => a.id == id);
          if (index != -1) {
            final article = articleResults[index];
            articleResults[index] = Article(
              id: article.id,
              title: article.title,
              content: article.content,
              mediaUrl: article.mediaUrl,
              category: article.category,
              createdBy: article.createdBy,
              createdAt: article.createdAt,
              isFavorite: !article.isFavorite,
            );
          }
        } else if (contentType == 'workout') {
          final index = workoutResults.indexWhere((w) => w.id == id);
          if (index != -1) {
            final workout = workoutResults[index];
            workoutResults[index] = Workout(
              id: workout.id,
              name: workout.name,
              description: workout.description,
              image: workout.image,
              estimatedDuration: workout.estimatedDuration,
              estimatedCalories: workout.estimatedCalories,
              exerciseCount: workout.exerciseCount,
              difficulty: workout.difficulty,
              isFavorite: !workout.isFavorite,
              exercises: workout.exercises,
            );
          }
        }
      }
    } catch (e) {
      print("Toggle favorite error: $e");
    }
  }

  @override
  void onClose() {
    _debounce?.cancel();
    tabController.dispose();
    searchController.dispose();
    super.onClose();
  }
}
