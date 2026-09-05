// lib/app/services/setup_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
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
        body: jsonEncode({"coach_type": coachId}),
      );

      print("Update coach status: ${response.statusCode}, body: ${response.body}");

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
        print("Failed update coach: ${response.statusCode} ${response.body}");
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
    final token = box.read("loginToken");
    if (token == null) {
      CustomSnackbar.showError("Not logged in. Please log in first.");
      return false;
    }

    final controller = Get.find<SetupController>();
    final authcontroller = Get.find<Authcontroller>();
    final schedulecontroller = Get.find<ScheduleController>();

    var request = http.MultipartRequest(
      'PATCH',
      Uri.parse("${AppConstants.baseUrl}/accounts/profile/update/"),
    );

    request.headers["Authorization"] = "Bearer $token";

    // Add only non-empty fields to prevent backend validation errors
    final Map<String, String> fields = {};

    final email = authcontroller.emailController.text.trim();
    if (email.isNotEmpty) fields["email"] = email;

    if (controller.phonenumber.value.isNotEmpty) {
      fields["phone_number"] = controller.phonenumber.value;
    }
    if (controller.fullName.value.isNotEmpty) {
      fields["full_name"] = controller.fullName.value;
    }
    if (controller.selectedGender.value.isNotEmpty) {
      fields["gender"] = controller.selectedGender.value.toLowerCase();
    }
    if (controller.selectedAge.value > 0) {
      fields["age"] = controller.selectedAge.value.toString();
    }
    if (controller.height.value > 0) {
      fields["height_cm"] = controller.height.value.round().toString();
    }
    if (controller.weight.value > 0) {
      fields["weight_kg"] = controller.weightUnit.value == 'kg'
          ? controller.weight.value.round().toString()
          : (controller.weight.value / 2.20462).round().toString();
    }
    if (controller.selectedGoal.value.isNotEmpty) {
      fields["goal"] = controller.selectedGoal.value;
    }
    if (controller.selectedActivityLevel.value.isNotEmpty) {
      fields["activity_level"] = controller.selectedActivityLevel.value.toLowerCase();
    }
    if (controller.selectedCoachId.value != null && controller.selectedCoachId.value! > 0) {
      fields["coach_type"] = controller.selectedCoachId.value.toString();
    }
    if (schedulecontroller.preferredWorkoutTime.isNotEmpty) {
      fields["preferred_workout_time"] = schedulecontroller.preferredWorkoutTime;
    }

    request.fields.addAll(fields);

    // Send each day ID separately
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

    try {
      final response = await request.send();
      final resp = await http.Response.fromStream(response);

      if (response.statusCode == 200 || response.statusCode == 201) {
        CustomSnackbar.showSuccess("Coach updated successfully!");
        if (Get.key.currentState?.canPop() == true) {
          Get.back();
        } else {
          Get.offAll(() => Subscription());
        }
        return true;
      } else {
        print("Failed: ${response.statusCode} ${resp.body}");
        CustomSnackbar.showError("Failed to save profile. Please try again.");
        return false;
      }
    } catch (e) {
      print("Error: $e");
      CustomSnackbar.showError("Network error while saving profile.");
      return false;
    }
  }

  Future<List<Coach>> fetchCoaches() async {
    final token = box.read("loginToken");
    if (token == null) throw Exception("Not logged in");

    final response = await http.get(
      Uri.parse(
        "${AppConstants.baseUrl}/accounts/coaches/",
      ), // change if your endpoint is different
      headers: {"Authorization": "Bearer $token", "Accept": "application/json"},
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
