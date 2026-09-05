// setting_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import '../../../constants/appconstants.dart';
import '../model/faq_model.dart';
import '../model/profile_model.dart';
import 'package:toastification/toastification.dart';
import 'package:kenzeno/app/res/fonts/textstyle.dart';
import 'package:kenzeno/app/res/colors/colors.dart';

class SettingService {
  final box = GetStorage();

  // GET: Fetch full profile
  // GET: Fetch current profile
  Future<ProfileModel> fetchProfile() async {
    final token = box.read('loginToken');
    if (token == null) throw Exception('Authentication required');

    final response = await http.get(
      Uri.parse('${AppConstants.baseUrl}/accounts/profile/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(
        utf8.decode(response.bodyBytes),
      ); // Proper UTF-8 handling
      return ProfileModel.fromJson(data);
    } else {
      final error = _parseError(response);
      throw Exception(error ?? 'Failed to load profile');
    }
  }

  // PATCH: Update profile - only sends non-null fields
  Future<ProfileModel> updateProfile({
    String? fullName,
    String? dateOfBirth,
    int? age,
    String? gender,
    double? heightCm,
    double? weightKg,
    String? goal,
    String? activityLevel,
    String? avatar,
  }) async {
    final token = box.read('loginToken');
    if (token == null) throw Exception('Authentication required');

    var request = http.MultipartRequest(
      'PATCH',
      Uri.parse('${AppConstants.baseUrl}/accounts/profile/update/'),
    );

    request.headers["Authorization"] = "Bearer $token";

    if (fullName != null && fullName.trim().isNotEmpty) {
      request.fields['full_name'] = fullName.trim();
    }
    if (dateOfBirth != null && dateOfBirth.trim().isNotEmpty) {
      request.fields['date_of_birth'] = dateOfBirth.trim();
    }
    if (age != null && age > 0) {
      request.fields['age'] = age.toString();
    }
    if (gender != null && gender.trim().isNotEmpty) {
      request.fields['gender'] = gender.trim().toLowerCase();
    }
    if (heightCm != null && heightCm > 0) {
      request.fields['height_cm'] = heightCm.toString();
    }
    if (weightKg != null && weightKg > 0) {
      request.fields['weight_kg'] = weightKg.toString();
    }
    if (goal != null && goal.trim().isNotEmpty) {
      request.fields['goal'] = goal.trim();
    }
    if (activityLevel != null && activityLevel.trim().isNotEmpty) {
      request.fields['activity_level'] = activityLevel.trim();
    }

    // Handle avatar as a file upload if it's a local path
    if (avatar != null && avatar.isNotEmpty && !avatar.startsWith('http')) {
      final file = File(avatar);
      if (await file.exists()) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'avatar',
            file.path,
            filename: 'avatar.jpg',
          ),
        );
      }
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      return ProfileModel.fromJson(data);
    } else {
      final error = _parseError(response);
      throw Exception(error ?? 'Failed to update profile');
    }
  }

  // Helper: Extract error message from API
  String? _parseError(http.Response response) {
    try {
      final errorBody = jsonDecode(utf8.decode(response.bodyBytes));
      if (errorBody is Map) {
        return errorBody['detail'] ??
            errorBody['full_name']?.first ??
            errorBody['date_of_birth']?.first ??
            errorBody['non_field_errors']?.first ??
            errorBody.toString();
      }
      return errorBody.toString();
    } catch (_) {
      return response.body.isNotEmpty ? response.body : null;
    }
  }

  Future<List<FAQ>> fetchFAQs({
    String? search,
    String? type, // general, account, service
  }) async {
    final token = box.read("loginToken");
    if (token == null) throw Exception("Login required");

    final params = <String, String>{};
    if (search != null && search.isNotEmpty) params['search'] = search;
    if (type != null && type.isNotEmpty) params['type'] = type;

    final uri = Uri.parse(
      '${AppConstants.baseUrl}/utils/faqs/',
    ).replace(queryParameters: params);

    try {
      final response = await http.get(
        uri,
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(utf8.decode(response.bodyBytes));
        return data.map((json) => FAQ.fromJson(json)).toList();
      } else {
        throw Exception("Failed to load FAQs (${response.statusCode})");
      }
    } catch (e) {
      print("FAQService Error: $e");
      rethrow;
    }
  }

  Future<List<ContactOption>> fetchContactOptions() async {
    final token = box.read("loginToken");
    if (token == null) throw Exception("Login required");

    final response = await http.get(
      Uri.parse('${AppConstants.baseUrl}/utils/contact-options/'),
      headers: {"Authorization": "Bearer $token", "Accept": "application/json"},
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(utf8.decode(response.bodyBytes));
      return data.map((json) => ContactOption.fromJson(json)).toList();
    } else {
      throw Exception("Failed to load contact options");
    }
  }

  // Example: lib/services/utils_service.dart  or  setting_service.dart

  Future<Map<String, dynamic>> fetchPrivacyPolicyContent() async {
    final token = GetStorage().read("loginToken");

    final response = await http.get(
      Uri.parse("${AppConstants.baseUrl}/utils/privacy-policy/"),
      headers: {"Authorization": "Bearer $token", "Accept": "application/json"},
    );

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception("Failed to load privacy policy (${response.statusCode})");
    }
  }

  Future<String?> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final token = box.read("loginToken");
    if (token == null) {
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
          "You are not logged in",
          style: AppTextStyles.poppinsRegular.copyWith(color: Colors.white),
        ),
        alignment: Alignment.topRight,
        autoCloseDuration: const Duration(seconds: 4),
        borderRadius: BorderRadius.circular(12),
        showProgressBar: true,
      );
      return null;
    }

    final payload = {
      "old_password": oldPassword,
      "new_password": newPassword,
      "confirm_password": confirmPassword,
    };

    try {
      final response = await http.post(
        Uri.parse("${AppConstants.baseUrl}/accounts/change-password/"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode(payload),
      );

      final Map<String, dynamic> data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Success
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
            data["message"] ?? "Password changed successfully",
            style: AppTextStyles.poppinsRegular.copyWith(color: Colors.white),
          ),
          alignment: Alignment.topRight,
          autoCloseDuration: const Duration(seconds: 4),
          borderRadius: BorderRadius.circular(12),
          showProgressBar: true,
        );
        return "success";
      }

      // Handle errors
      if (data.containsKey("non_field_errors")) {
        toastification.show(
          type: ToastificationType.error,
          style: ToastificationStyle.fillColored,
          primaryColor: Colors.red,
          foregroundColor: Colors.white,
          title: Text(
            "Oops",
            style: AppTextStyles.poppinsBold.copyWith(color: Colors.white),
          ),
          description: Text(
            data["non_field_errors"][0],
            style: AppTextStyles.poppinsRegular.copyWith(color: Colors.white),
          ),
          alignment: Alignment.topRight,
          autoCloseDuration: const Duration(seconds: 4),
          borderRadius: BorderRadius.circular(12),
          showProgressBar: true,
        );
      } else if (data.containsKey("error")) {
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
            data["error"],
            style: AppTextStyles.poppinsRegular.copyWith(color: Colors.white),
          ),
          alignment: Alignment.topRight,
          autoCloseDuration: const Duration(seconds: 4),
          borderRadius: BorderRadius.circular(12),
          showProgressBar: true,
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
            "Something went wrong. Please try again.",
            style: AppTextStyles.poppinsRegular.copyWith(color: Colors.white),
          ),
          alignment: Alignment.topRight,
          autoCloseDuration: const Duration(seconds: 4),
          borderRadius: BorderRadius.circular(12),
          showProgressBar: true,
        );
      }

      return null;
    } catch (e) {
      toastification.show(
        type: ToastificationType.error,
        style: ToastificationStyle.fillColored,
        primaryColor: Colors.red,
        foregroundColor: Colors.white,
        title: Text(
          "Network Error",
          style: AppTextStyles.poppinsBold.copyWith(color: Colors.white),
        ),
        description: Text(
          "Please check your connection",
          style: AppTextStyles.poppinsRegular.copyWith(color: Colors.white),
        ),
        alignment: Alignment.topRight,
        autoCloseDuration: const Duration(seconds: 4),
        borderRadius: BorderRadius.circular(12),
        showProgressBar: true,
      );
      return null;
    }
  }
}
