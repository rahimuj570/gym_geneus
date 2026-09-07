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
    // 1. Optimistically toggle state immediately
    _applyFavoriteToggle(contentType: contentType, id: id);

    try {
      final success = await _homeService.toggleFavorite(
        contentType: contentType,
        objectId: id,
      );

      // 2. If API fails, revert the state back
      if (!success) {
        _applyFavoriteToggle(contentType: contentType, id: id);
      }
    } catch (e) {
      print("Toggle favorite error: $e");
      // Revert state back on exception
      _applyFavoriteToggle(contentType: contentType, id: id);
    }
  }

  void _applyFavoriteToggle({required String contentType, required int id}) {
    if (contentType == 'article') {
      final index = articleResults.indexWhere((a) => a.id == id);
      if (index != -1) {
        final article = articleResults[index];
        articleResults[index] = article.copyWith(isFavorite: !article.isFavorite);
      }
    } else if (contentType == 'workout' ||
        contentType == 'userworkout' ||
        contentType == 'workoutvideo') {
      final index = workoutResults.indexWhere((w) => w.id == id);
      if (index != -1) {
        final workout = workoutResults[index];
        workoutResults[index] = workout.copyWith(isFavorite: !workout.isFavorite);
      }
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
