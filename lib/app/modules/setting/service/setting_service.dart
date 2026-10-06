// setting_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:kenzeno/app/services/api_client.dart';
import '../../../constants/appconstants.dart';
import '../model/faq_model.dart';
import '../model/profile_model.dart';
import '../model/notification_settings_model.dart';
import 'package:toastification/toastification.dart';
import 'package:kenzeno/app/res/fonts/textstyle.dart';
import 'package:kenzeno/app/res/colors/colors.dart';

class SettingService {
  final box = GetStorage();

  // GET: Fetch current profile
  Future<ProfileModel> fetchProfile() async {
    final url = '${AppConstants.baseUrl}/accounts/profile/';
    final response = await ApiClient.get(
      Uri.parse(url),
      tag: 'Setting-FetchProfile',
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
    String? phoneNumber,
    String? dateOfBirth,
    int? age,
    String? gender,
    double? heightCm,
    double? weightKg,
    String? goal,
    String? activityLevel,
    String? avatar,
  }) async {
    final url = '${AppConstants.baseUrl}/accounts/profile/update/';

    final response = await ApiClient.sendMultipartRequest(
      Uri.parse(url),
      method: 'PATCH',
      tag: 'Setting-UpdateProfile',
      buildRequest: (token) async {
        final request = http.MultipartRequest('PATCH', Uri.parse(url));

        if (token != null) {
          request.headers["Authorization"] = "Bearer $token";
        }

        if (fullName != null && fullName.trim().isNotEmpty) {
          request.fields['full_name'] = fullName.trim();
        }
        if (phoneNumber != null && phoneNumber.trim().isNotEmpty) {
          request.fields['phone_number'] = phoneNumber.trim();
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
        return request;
      },
    );

    final responseBody = utf8.decode(response.bodyBytes);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(responseBody);
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
            errorBody['message'] ??
            errorBody['error'] ??
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

  // DELETE: /api/accounts/delete-account/
  Future<bool> deleteAccount() async {
    final url = '${AppConstants.baseUrl}/accounts/delete-account/';

    http.Response response;
    try {
      response = await ApiClient.delete(
        Uri.parse(url),
        tag: 'Setting-DeleteAccount',
      );
    } catch (e) {
      throw Exception('Network error: $e');
    }

    if (response.statusCode == 200 ||
        response.statusCode == 204 ||
        response.statusCode == 202) {
      return true;
    } else if (response.statusCode == 405) {
      // Fallback to POST if server expects POST
      try {
        final postResponse = await ApiClient.post(
          Uri.parse(url),
          tag: 'Setting-DeleteAccount-Fallback',
        );

        if (postResponse.statusCode == 200 ||
            postResponse.statusCode == 204 ||
            postResponse.statusCode == 202) {
          return true;
        }
        final error = _parseError(postResponse);
        throw Exception(error ?? 'Failed to delete account');
      } catch (e) {
        if (e is Exception) rethrow;
        throw Exception('Failed to delete account');
      }
    } else {
      final error = _parseError(response);
      throw Exception(error ?? 'Failed to delete account');
    }
  }

  Future<List<FAQ>> fetchFAQs({
    String? search,
    String? type, // general, account, service
  }) async {
    final params = <String, String>{};
    if (search != null && search.isNotEmpty) params['search'] = search;
    if (type != null && type.isNotEmpty) params['type'] = type;

    final uri = Uri.parse(
      '${AppConstants.baseUrl}/utils/faqs/',
    ).replace(queryParameters: params);

    try {
      final response = await ApiClient.get(
        uri,
        tag: 'Setting-FetchFAQs',
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(utf8.decode(response.bodyBytes));
        return data.map((json) => FAQ.fromJson(json)).toList();
      } else {
        throw Exception("Failed to load FAQs (${response.statusCode})");
      }
    } catch (e) {
      debugPrint("FAQService Error: $e");
      rethrow;
    }
  }

  Future<List<ContactOption>> fetchContactOptions() async {
    final url = '${AppConstants.baseUrl}/utils/contact-options/';
    final response = await ApiClient.get(
      Uri.parse(url),
      tag: 'Setting-ContactOptions',
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(utf8.decode(response.bodyBytes));
      return data.map((json) => ContactOption.fromJson(json)).toList();
    } else {
      throw Exception("Failed to load contact options");
    }
  }

  Future<Map<String, dynamic>> fetchPrivacyPolicyContent() async {
    final url = "${AppConstants.baseUrl}/utils/privacy-policy/";
    final response = await ApiClient.get(
      Uri.parse(url),
      tag: 'Setting-PrivacyPolicy',
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
    final payload = {
      "old_password": oldPassword,
      "new_password": newPassword,
      "confirm_password": confirmPassword,
    };

    final url = "${AppConstants.baseUrl}/accounts/change-password/";
    try {
      final response = await ApiClient.post(
        Uri.parse(url),
        body: payload,
        tag: 'Setting-ChangePassword',
      );

      final Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));

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

  // GET: /api/utils/notification-settings/
  Future<NotificationSettingsModel> fetchNotificationSettings() async {
    final url = '${AppConstants.baseUrl}/utils/notification-settings/';
    final response = await ApiClient.get(
      Uri.parse(url),
      tag: 'Setting-FetchNotificationSettings',
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      return NotificationSettingsModel.fromJson(data);
    } else {
      throw Exception('Failed to load notification settings');
    }
  }

  // PATCH: /api/utils/notification-settings/
  Future<NotificationSettingsModel> updateNotificationSettings({
    bool? generalNotifications,
    bool? sound,
    bool? doNotDisturb,
    bool? vibrate,
    bool? lockScreen,
  }) async {
    final url = '${AppConstants.baseUrl}/utils/notification-settings/';
    final body = <String, dynamic>{};
    if (generalNotifications != null) {
      body['general_notifications'] = generalNotifications;
    }
    if (sound != null) {
      body['sound'] = sound;
    }
    if (doNotDisturb != null) {
      body['do_not_disturb'] = doNotDisturb;
    }
    if (vibrate != null) {
      body['vibrate'] = vibrate;
    }
    if (lockScreen != null) {
      body['lock_screen'] = lockScreen;
    }

    final response = await ApiClient.patch(
      Uri.parse(url),
      body: body,
      tag: 'Setting-UpdateNotificationSettings',
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      return NotificationSettingsModel.fromJson(data);
    } else {
      throw Exception('Failed to update notification settings');
    }
  }
}
