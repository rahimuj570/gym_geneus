// nutrition_controller.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../model/meal_result_analysis.dart';
import '../model/nutrion_home.dart';
import '../service/nutri_service.dart';

import '../views/scannedmealdetails.dart';
import 'package:toastification/toastification.dart';
import 'package:kenzeno/app/res/fonts/textstyle.dart';
import 'package:kenzeno/app/res/colors/colors.dart';

class NutritionController extends GetxController {
  final NutritionService _service = NutritionService();

  var isAnalyzing = false.obs;
  var isSaving = false.obs;
  var isLoading = true.obs;
  var nutritionData = Rxn<NutritionHomeResponse>();

  @override
  void onInit() {
    super.onInit();
    print('📦 [NutritionController] Initialized. Fetching nutrition data...');
    fetchNutritionData();
  }

  Future<void> fetchNutritionData() async {
    try {
      isLoading(true);
      update();
      print('🔄 [NutritionController] Calling fetchNutritionHome()...');
      final data = await _service.fetchNutritionHome();
      nutritionData.value = data;
      print('✅ [NutritionController] Nutrition data loaded successfully. Total meals: ${data.totalMeals}, Streak: ${data.streak}');
    } catch (e) {
      print("❌ [NutritionController] Fetch nutrition error: $e");
      nutritionData.value = null;
    } finally {
      isLoading(false);
      update();
    }
  }

  MealAnalysisResult? currentAnalysisResult;

  Future<void> analyzeMeal(File imageFile) async {
    try {
      isAnalyzing(true);
      print('🔄 [NutritionController] Starting analyzeMeal with image: ${imageFile.path}');
      final result = await _service.uploadMealImage(imageFile);
      currentAnalysisResult = result;
      print("✅ [NutritionController] Meal analyzed successfully: tempUploadId = ${currentAnalysisResult?.tempUploadId}, mealName = ${currentAnalysisResult?.mealName}");

      Get.to(
        () => RedesignedScannedMealPage(
          imageFile: imageFile,
          analysisResult: result,
        ),
      );
    } catch (e) {
      print('❌ [NutritionController] Error analyzing meal: $e');
      rethrow; // Let the page handle error + close dialog
    } finally {
      isAnalyzing(false);
    }
  }

  Future<bool> saveCurrentMeal() async {
    if (currentAnalysisResult == null) {
      print('⚠️ [NutritionController] No meal to save (currentAnalysisResult is null)');
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
          'No meal to save',
          style: AppTextStyles.poppinsRegular.copyWith(color: Colors.white),
        ),
        alignment: Alignment.topRight,
        autoCloseDuration: const Duration(seconds: 4),
        borderRadius: BorderRadius.circular(12),
        showProgressBar: true,
      );
      return false;
    }

    try {
      isSaving(true);
      print('🔄 [NutritionController] Saving meal with tempUploadId: ${currentAnalysisResult!.tempUploadId}');
      await _service.saveMealUpload(currentAnalysisResult!.tempUploadId);
      print('✅ [NutritionController] Meal saved successfully. Refreshing nutrition data...');
      fetchNutritionData();
      toastification.show(
        type: ToastificationType.success,
        style: ToastificationStyle.fillColored,
        primaryColor: AppColor.green16A34A,
        foregroundColor: Colors.white,
        title: Text(
          'Success',
          style: AppTextStyles.poppinsBold.copyWith(color: Colors.white),
        ),
        description: Text(
          'Meal saved to your log!',
          style: AppTextStyles.poppinsRegular.copyWith(color: Colors.white),
        ),
        alignment: Alignment.topRight,
        autoCloseDuration: const Duration(seconds: 4),
        borderRadius: BorderRadius.circular(12),
        showProgressBar: true,
      );
      return true;
    } catch (e) {
      print('❌ [NutritionController] Error saving meal: $e');
      toastification.show(
        type: ToastificationType.error,
        style: ToastificationStyle.fillColored,
        primaryColor: Colors.red,
        foregroundColor: Colors.white,
        title: Text(
          'Failed',
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
      return false;
    } finally {
      isSaving(false);
    }
  }
}

