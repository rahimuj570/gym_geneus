// lib/app/services/setup_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:kenzeno/app/services/api_client.dart';
import 'package:get_storage/get_storage.dart';
import 'package:kenzeno/app/modules/auth/controllers/authcontroller.dart';
import 'package:kenzeno/app/modules/setup/controllers/schedule_controller.dart';
import '../../../constants/appconstants.dart';

import '../../subscription/views/subscription.dart';
import '../controllers/setup_controller.dart';
import '../models/coach_model.dart';
import 'package:kenzeno/app/modules/setting/controller/profilecontroller.dart';
import 'package:kenzeno/app/widgets/custom_snackbar.dart';

class SetupService extends GetxService {
  final box = GetStorage();

  /// Dedicated lightweight method for updating ONLY the coach from Settings/More
  Future<bool> updateCoach(int coachId) async {
    box.write("userCoachId", coachId);
    if (Get.isRegistered<ProfileController>()) {
      Get.find<ProfileController>().setCoachId(coachId);
    }
    if (Get.isRegistered<SetupController>()) {
      Get.find<SetupController>().selectedCoachId.value = coachId;
    }

    try {
      // Using ApiClient so token auto-refreshes on 401
      final response = await ApiClient.patch(
        Uri.parse("${AppConstants.baseUrl}/accounts/profile/update/"),
        body: {"coach_type": coachId},
        tag: 'Setup-UpdateCoach',
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        CustomSnackbar.showSuccess("Coach updated successfully!");
        if (Get.isRegistered<ProfileController>()) {
          Get.find<ProfileController>().fetchProfile();
        }
        if (Get.key.currentState?.canPop() == true) {
          Get.back();
        }
        return true;
      } else {
        CustomSnackbar.showError("Failed to update coach. Please try again.");
        return false;
      }
    } catch (e) {
      print("Error updating coach: $e");
      CustomSnackbar.showError("Network error while updating coach.");
      return false;
    }
  }

  Future<bool> completeSetup() async {
    final controller = Get.find<SetupController>();
    final schedulecontroller = Get.find<ScheduleController>();

    // ⭐️ Validation: Ensure no required onboarding field is missing
    if (controller.selectedGender.value.trim().isEmpty) {
      CustomSnackbar.showWarning(
        "Please select your gender.",
        title: "Missing Gender",
      );
      return false;
    }
    if (controller.selectedGoal.value.trim().isEmpty) {
      CustomSnackbar.showWarning(
        "Please select your fitness goal.",
        title: "Missing Goal",
      );
      return false;
    }
    if (controller.selectedActivityLevel.value.trim().isEmpty) {
      CustomSnackbar.showWarning(
        "Please select your activity level.",
        title: "Missing Activity Level",
      );
      return false;
    }
    if (schedulecontroller.preferredWorkoutTime.trim().isEmpty) {
      CustomSnackbar.showWarning(
        "Please choose your preferred workout time.",
        title: "Missing Schedule Time",
      );
      return false;
    }
    if (controller.selectedCoachId.value == null ||
        controller.selectedCoachId.value! <= 0) {
      CustomSnackbar.showWarning(
        "Please select a coach.",
        title: "Missing Coach",
      );
      return false;
    }

    final url = "${AppConstants.baseUrl}/accounts/profile/update/";

    try {
      final response = await ApiClient.sendMultipartRequest(
        Uri.parse(url),
        method: 'PATCH',
        tag: 'Setup-CompleteSetup',
        buildRequest: (token) async {
          final request = http.MultipartRequest('PATCH', Uri.parse(url));

          if (token != null) {
            request.headers["Authorization"] = "Bearer $token";
          }

          final Map<String, String> fields = {};

          if (Get.isRegistered<Authcontroller>()) {
            final email = Get.find<Authcontroller>().emailController.text.trim();
            if (email.isNotEmpty) fields["email"] = email;
          }

          if (controller.fullName.value.trim().isNotEmpty) {
            fields["full_name"] = controller.fullName.value.trim();
          }
          if (controller.phonenumber.value.trim().isNotEmpty) {
            fields["phone_number"] = controller.phonenumber.value.trim();
          }

          fields["gender"] = controller.selectedGender.value.trim().toLowerCase();

          if (controller.selectedAge.value > 0) {
            fields["age"] = controller.selectedAge.value.toString();
            final birthYear = DateTime.now().year - controller.selectedAge.value;
            fields["date_of_birth"] = "$birthYear-01-01";
          }

          if (controller.height.value > 0) {
            fields["height_cm"] = controller.height.value.round().toString();
          }

          if (controller.weight.value > 0) {
            final weightKg = controller.weightUnit.value == 'kg'
                ? controller.weight.value.round().toString()
                : (controller.weight.value / 2.20462).round().toString();
            fields["weight_kg"] = weightKg;
          }

          // Goal and Activity Level
          fields["goal"] = controller.selectedGoal.value.trim();
          fields["activity_level"] =
              controller.selectedActivityLevel.value.trim().toLowerCase();

          // Coach
          fields["coach_type"] = controller.selectedCoachId.value.toString();

          // Schedule
          fields["preferred_workout_time"] =
              schedulecontroller.preferredWorkoutTime;

          request.fields.addAll(fields);

          // Preferred workout days
          for (final dayId in schedulecontroller.preferredWorkoutDayIds) {
            request.fields['preferred_workout_day_ids'] = dayId.toString();
          }

          // Avatar
          if (controller.profileImagePath.value.isNotEmpty) {
            final imageFile = File(controller.profileImagePath.value);
            if (await imageFile.exists()) {
              request.files.add(
                await http.MultipartFile.fromPath(
                  'avatar',
                  imageFile.path,
                  filename: 'profile.jpg',
                ),
              );
            }
          }
          return request;
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        box.write("userCoachId", controller.selectedCoachId.value);
        if (Get.isRegistered<ProfileController>()) {
          Get.find<ProfileController>().setCoachId(controller.selectedCoachId.value!);
          Get.find<ProfileController>().fetchProfile();
        }
        CustomSnackbar.showSuccess("Profile completed successfully!");
        Get.offAll(() => Subscription());
        return true;
      } else {
        CustomSnackbar.showError("Failed to save profile: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("❌ Setup Error: $e");
      CustomSnackbar.showError("Network error while saving profile.");
      return false;
    }
  }

  Future<List<Coach>> fetchCoaches() async {
    final url = "${AppConstants.baseUrl}/accounts/coaches/";
    final response = await ApiClient.get(
      Uri.parse(url),
      tag: 'Setup-FetchCoaches',
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(
        utf8.decode(response.bodyBytes),
      );
      return jsonList.map((json) => Coach.fromJson(json)).toList();
    } else {
      throw Exception("Failed to load coaches: ${response.statusCode}");
    }
  }
}
