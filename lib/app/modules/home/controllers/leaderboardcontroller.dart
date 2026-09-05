// lib/app/modules/gamification/controllers/leaderboard_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kenzeno/app/res/colors/colors.dart';

import '../models/leaderboard_model.dart';
import '../service/home_service.dart';
import 'package:toastification/toastification.dart';
import 'package:kenzeno/app/res/fonts/textstyle.dart';

class LeaderboardController extends GetxController {
  final HomeService _service = Get.find();

  var isLoading = true.obs;
  var leaderboard = Rxn<LeaderboardResponse>();

  @override
  void onInit() {
    super.onInit();
    fetchLeaderboard();
  }

  Future<void> fetchLeaderboard({int limit = 50}) async {
    try {
      isLoading(true);
      final response = await _service.fetchLeaderboard(limit: limit);
      leaderboard.value = response;
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
          "Could not load leaderboard",
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
}
