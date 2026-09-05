import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_debug_logger/flutter_debug_logger.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:kenzeno/app/constants/appconstants.dart';

import '../model/favourite_model.dart';
import 'package:toastification/toastification.dart';
import 'package:kenzeno/app/res/fonts/textstyle.dart';
import 'package:kenzeno/app/res/colors/colors.dart';

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
      final token = box.read("loginToken");
      if (token == null) throw "No token";

      final url = '${AppConstants.baseUrl}/utils/favorites/';
      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      FlutterDebugLogger.printJsonResponse(
        url: url,
        method: Method.GET,
        tag: 'Setting-Favorites',
        statusCode: response.statusCode,
        responseBody: response.body,
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
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
