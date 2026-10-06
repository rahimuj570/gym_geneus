import 'package:flutter/material.dart';
import 'package:flutter_debug_logger/flutter_debug_logger.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:kenzeno/app/constants/appconstants.dart';
import 'package:kenzeno/app/services/api_client.dart';

import 'package:kenzeno/app/modules/home/controllers/homecontroller.dart';
import 'package:kenzeno/app/modules/home/controllers/searchcontroller.dart';
import 'package:kenzeno/app/modules/home/service/home_service.dart';
import 'package:kenzeno/app/modules/workout/controllers/workoutcontroller.dart';
import '../model/favourite_model.dart';
import 'package:toastification/toastification.dart';
import 'package:kenzeno/app/res/fonts/textstyle.dart';

class FavouriteController extends GetxController {
  final box = GetStorage();
  var isLoading = true.obs;
  var favorites = <FavoriteItem>[].obs;

  final selectedIndex = 0.obs;
  final categories = ['All', 'Workouts', 'Articles'];

  @override
  void onInit() {
    super.onInit();
    fetchFavorites();
  }

  Future<void> fetchFavorites() async {
    try {
      isLoading.value = true;
      final url = '${AppConstants.baseUrl}/utils/favorites/';
      final response = await ApiClient.get(
        Uri.parse(url),
        tag: 'Setting-Favorites',
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(utf8.decode(response.bodyBytes));
        favorites.assignAll(
          data.map((json) => FavoriteItem.fromJson(json)).toList(),
        );
      } else {
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
            "Failed to load favorites",
            style: AppTextStyles.poppinsRegular.copyWith(color: Colors.white),
          ),
          alignment: Alignment.topRight,
          autoCloseDuration: const Duration(seconds: 4),
          borderRadius: BorderRadius.circular(12),
          showProgressBar: true,
        );
      }
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
          "Network error",
          style: AppTextStyles.poppinsRegular.copyWith(color: Colors.white),
        ),
        alignment: Alignment.topRight,
        autoCloseDuration: const Duration(seconds: 4),
        borderRadius: BorderRadius.circular(12),
        showProgressBar: true,
      );
      print(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> removeFavorite(FavoriteItem item) async {
    final index = favorites.indexOf(item);
    if (index == -1) return;

    // 1. Optimistically remove from list immediately
    favorites.removeAt(index);
    favorites.refresh();

    // 2. Sync state in other active controllers
    _syncOtherControllers(item.type, item.object.id);

    try {
      final homeService = Get.isRegistered<HomeService>()
          ? Get.find<HomeService>()
          : Get.put(HomeService());

      final success = await homeService.toggleFavorite(
        contentType: item.type,
        objectId: item.object.id,
      );

      if (!success) {
        // Revert on failure
        favorites.insert(index, item);
        favorites.refresh();
        _syncOtherControllers(item.type, item.object.id);
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
            "Failed to remove from favorites",
            style: AppTextStyles.poppinsRegular.copyWith(color: Colors.white),
          ),
          alignment: Alignment.topRight,
          autoCloseDuration: const Duration(seconds: 3),
          borderRadius: BorderRadius.circular(12),
          showProgressBar: true,
        );
      }
    } catch (e) {
      // Revert on exception
      favorites.insert(index, item);
      favorites.refresh();
      _syncOtherControllers(item.type, item.object.id);
    }
  }

  void _syncOtherControllers(String type, int id) {
    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().applyFavoriteToggleLocally(
        contentType: type,
        id: id,
      );
    }
    if (Get.isRegistered<SearchController2>()) {
      Get.find<SearchController2>().applyFavoriteToggleLocally(
        contentType: type,
        id: id,
      );
    }
    if (type == 'userworkout' && Get.isRegistered<WorkoutController>()) {
      Get.find<WorkoutController>().applyLocalFavoriteToggle(id);
    }
  }

  void selectCategory(int index) {
    selectedIndex.value = index;
  }

  List<FavoriteItem> get filteredFavorites {
    final list = favorites;
    if (selectedIndex.value == 0) return list;

    if (selectedIndex.value == 1) {
      // Workouts
      return list.where((item) => item.type == "userworkout").toList();
    } else {
      // Articles
      return list.where((item) => item.type == "article").toList();
    }
  }
}
