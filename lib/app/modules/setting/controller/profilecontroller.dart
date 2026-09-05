import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kenzeno/app/modules/home/controllers/homecontroller.dart';
import '../../setup/controllers/bottomsheetcontroller.dart';
import '../model/profile_model.dart';
import '../service/setting_service.dart';
import 'package:kenzeno/app/widgets/custom_snackbar.dart';

import 'package:get_storage/get_storage.dart';
import 'package:kenzeno/app/modules/setup/controllers/setup_controller.dart';
import 'package:kenzeno/app/res/assets/asset.dart';

class ProfileController extends GetxController {
  final SettingService _service = SettingService();
  final box = GetStorage();

  var profile = ProfileModel().obs;
  var isLoading = false.obs;

  int get activeCoachId {
    final localStoredId = box.read("userCoachId");
    if (localStoredId != null && localStoredId is int && localStoredId > 0) {
      return localStoredId;
    }
    if (profile.value?.coachType != null && profile.value!.coachType! > 0) {
      return profile.value!.coachType!;
    }
    if (Get.isRegistered<SetupController>()) {
      final setupId = Get.find<SetupController>().selectedCoachId.value;
      if (setupId != null && setupId > 0) return setupId;
    }
    return 2; // Default Selma
  }

  void setCoachId(int coachId) {
    box.write("userCoachId", coachId);
    if (profile.value != null) {
      profile.value!.coachType = coachId;
      profile.refresh();
    }
    update();
  }

  String get activeCoachName {
    switch (activeCoachId) {
      case 1:
        return "John";
      case 2:
        return "Selma";
      case 3:
        return "Jara";
      case 4:
        return "Chris";
      default:
        return "Selma";
    }
  }

  String get activeCoachImagePath {
    switch (activeCoachId) {
      case 1:
        return ImageAssets.img_11;
      case 2:
        return ImageAssets.img_12;
      case 3:
        return ImageAssets.img_13;
      case 4:
        return ImageAssets.img_14;
      default:
        return ImageAssets.img_12;
    }
  }

  // Editing Controllers
  late TextEditingController fullNameController;
  late TextEditingController dobController;
  late TextEditingController weightController;
  late TextEditingController heightController;
  late TextEditingController emailController;
  late TextEditingController mobileController;
  var selectedGender = RxnString();

  void _initControllers() {
    fullNameController = TextEditingController();
    dobController = TextEditingController();
    weightController = TextEditingController();
    heightController = TextEditingController();
    emailController = TextEditingController();
    mobileController = TextEditingController();
  }

  void _updateEditingControllers() {
    final p = profile.value;
    try {
      fullNameController.text = p.fullName ?? '';
    } catch (_) {
      _initControllers();
      fullNameController.text = p.fullName ?? '';
    }
    
    final todayStr = DateTime.now().toIso8601String().split('T').first;
    if (p.dateOfBirth != null && p.dateOfBirth!.isNotEmpty && p.dateOfBirth != todayStr) {
      dobController.text = p.dateOfBirth!;
    } else {
      dobController.text = '';
    }

    weightController.text =
        p.weightKg != null ? p.weightKg!.toStringAsFixed(1) : '';
    heightController.text =
        p.heightCm != null ? p.heightCm!.toStringAsFixed(1) : '';
    emailController.text = p.email ?? '';
    mobileController.text = p.phoneNumber ?? '';

    if (p.gender != null && p.gender!.isNotEmpty) {
      selectedGender.value = p.gender!.toLowerCase();
    } else {
      selectedGender.value = null;
    }
  }

  int get effectiveAge {
    final p = profile.value;
    if (p.age != null && p.age! > 0) {
      return p.age!;
    }
    final dobStr = dobController.text.trim().isNotEmpty ? dobController.text.trim() : p.dateOfBirth;
    if (dobStr != null && dobStr.isNotEmpty) {
      try {
        final dob = DateTime.parse(dobStr);
        final now = DateTime.now();
        int age = now.year - dob.year;
        if (now.month < dob.month || (now.month == dob.month && now.day < dob.day)) {
          age--;
        }
        if (age > 0) return age;
      } catch (_) {}
    }
    return 0;
  }

  @override
  void onInit() {
    super.onInit();
    _initControllers();
    fetchProfile();
  }

  @override
  void onReady() {
    super.onReady();
    fetchProfile();
  }

  void refreshProfile() {
    fetchProfile();
  }

  bool get isProfileComplete {
    final p = profile.value;
    if (p.missingProfileFields != null) {
      return p.missingProfileFields!.isEmpty;
    }
    return (p.fullName != null && p.fullName!.isNotEmpty) &&
        (p.heightCm != null && p.heightCm! > 0) &&
        (p.weightKg != null && p.weightKg! > 0) &&
        (p.gender != null && p.gender!.isNotEmpty) &&
        (p.goal != null && p.goal!.isNotEmpty);
  }

  void checkAndWarnIncompleteProfile() {
    if (!isProfileComplete) {
      CustomSnackbar.showWarning(
        'Please complete your height, weight, and fitness goal in Profile Settings to unlock personalized recommendations.',
        title: 'Profile Incomplete',
      );
    }
  }

  Future<void> fetchProfile() async {
    try {
      isLoading.value = true;
      final fetchedProfile = await _service.fetchProfile();
      profile.value = fetchedProfile;
      if (fetchedProfile.coachType != null && fetchedProfile.coachType! > 0) {
        box.write("userCoachId", fetchedProfile.coachType);
      }
      _updateEditingControllers();
      checkAndWarnIncompleteProfile();
    } catch (e) {
      print(e.toString());
      CustomSnackbar.showError(e.toString().replaceAll('Exception: ', ''));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateProfile({
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
    try {
      isLoading.value = true;

      // Calculate age if DOB provided but age not passed
      int? targetAge = age;
      if ((targetAge == null || targetAge == 0) && dateOfBirth != null && dateOfBirth.isNotEmpty) {
        try {
          final dob = DateTime.parse(dateOfBirth);
          final now = DateTime.now();
          int computedAge = now.year - dob.year;
          if (now.month < dob.month || (now.month == dob.month && now.day < dob.day)) {
            computedAge--;
          }
          if (computedAge > 0) targetAge = computedAge;
        } catch (_) {}
      }

      // Get the BottomSheetController instance
      final BottomSheetController bottomSheetController = Get.find<BottomSheetController>();

      // Use the picked image path from the BottomSheetController if available, otherwise use the passed avatar
      final String? finalAvatarPath = bottomSheetController.pickedImage.value?.path ?? avatar;

      print('🔄 [ProfileController] Updating profile with:');
      print('   -> Full Name: $fullName');
      print('   -> Phone Number: $phoneNumber');
      print('   -> DOB: $dateOfBirth (computed age: $targetAge)');
      print('   -> Gender: $gender');
      print('   -> Height: $heightCm cm');
      print('   -> Weight: $weightKg kg');
      print('   -> Avatar: $finalAvatarPath');

      final updatedProfile = await _service.updateProfile(
        fullName: fullName,
        phoneNumber: phoneNumber,
        dateOfBirth: dateOfBirth,
        age: targetAge,
        gender: gender,
        heightCm: heightCm,
        weightKg: weightKg,
        goal: goal,
        activityLevel: activityLevel,
        avatar: finalAvatarPath,
      );

      profile.value = updatedProfile;
      _updateEditingControllers();

      print('🎉 [ProfileController] Profile updated successfully! Updated profile model: ${updatedProfile.toJson()}');

      // Refetch articles if HomeController is registered
      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().fetchAllArticles();
      }

      // Clear the picked image after a successful update
      bottomSheetController.pickedImage.value = null;

      CustomSnackbar.showSuccess('Profile updated successfully!');
    } catch (e) {
      print('❌ [ProfileController] Error updating profile: $e');
      CustomSnackbar.showError(
        e.toString().replaceAll('Exception: ', ''),
        title: 'Update Failed',
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    try {
      fullNameController.dispose();
      dobController.dispose();
      weightController.dispose();
      heightController.dispose();
      emailController.dispose();
      mobileController.dispose();
    } catch (_) {}
    super.onClose();
  }
}
