// lib/app/modules/gallery/controllers/gallery_controller.dart

import 'dart:convert';
import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../res/colors/colors.dart';
import '../../home/service/home_service.dart';
import '../models/fittracker_model.dart';
import '../models/progresstype.dart';
import 'package:toastification/toastification.dart';
import 'package:kenzeno/app/res/fonts/textstyle.dart';
import 'package:kenzeno/app/res/colors/colors.dart';

class GalleryController extends GetxController {
  // Services
  HomeService get _homeService => Get.isRegistered<HomeService>()
      ? Get.find<HomeService>()
      : Get.put(HomeService());

  // Reactive State
  var isLoading = true.obs;
  var isUploading = false.obs;
  var dashboardData = Rxn<GalleryDashboardResponse>();
  var currentMonth = DateTime.now().obs;
  var galleryImages = <GalleryImage>[].obs;

  // Image Picker
  final ImagePicker _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    print('📦 [GalleryController] Initialized. Fetching gallery dashboard and images...');
    fetchGalleryDashboard();
    fetchGalleryImages(); // Load current month
  }

  /// Fetch FitTracker dashboard (calendar + photos + streak)
  Future<void> fetchGalleryDashboard({int? month, int? year}) async {
    try {
      isLoading(true);
      final m = month ?? DateTime.now().month;
      final y = year ?? DateTime.now().year;
      print('🔄 [GalleryController] Fetching dashboard for month: $m, year: $y');

      final response = await _homeService.fetchGalleryDashboard(
        month: m,
        year: y,
      );

      dashboardData.value = response;
      currentMonth.value = DateTime(y, m);
      print('✅ [GalleryController] Dashboard loaded. Total images: ${response.totalImages}, streak: ${response.consecutiveDaysStreak}');
    } catch (e) {
      print('❌ [GalleryController] Error fetching dashboard: $e');
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
          e.toString(),
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

  /// Navigate to previous/next month
  void changeMonth(int offset) {
    final newDate = DateTime(
      currentMonth.value.year,
      currentMonth.value.month + offset,
    );
    fetchGalleryDashboard(month: newDate.month, year: newDate.year);
  }

  /// Take photo from camera or gallery and upload
  Future<void> takeAndUploadPhoto({bool fromGallery = false}) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: fromGallery ? ImageSource.gallery : ImageSource.camera,
        maxWidth: 1600,
        imageQuality: 85,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (pickedFile == null) {
        toastification.show(
          type: ToastificationType.warning,
          style: ToastificationStyle.fillColored,
          primaryColor: Colors.orange,
          foregroundColor: Colors.white,
          title: Text(
            "Cancelled",
            style: AppTextStyles.poppinsBold.copyWith(color: Colors.white),
          ),
          description: Text(
            "No photo selected",
            style: AppTextStyles.poppinsRegular.copyWith(color: Colors.white),
          ),
          alignment: Alignment.topRight,
          autoCloseDuration: const Duration(seconds: 4),
          borderRadius: BorderRadius.circular(12),
          showProgressBar: true,
        );
        return;
      }

      isUploading(true);
      final bytes = await pickedFile.readAsBytes();
      print('🔄 [GalleryController] Uploading progress photo (${bytes.length} bytes)...');

      final success = await _homeService.uploadProgressPhoto(
        imageBytes: bytes, // ← just the raw bytes
      );

      if (success) {
        print('✅ [GalleryController] Photo uploaded successfully.');
        toastification.show(
          type: ToastificationType.info,
          style: ToastificationStyle.fillColored,
          primaryColor: AppColor.green16A34A,
          foregroundColor: Colors.white,
          title: Text(
            "Uploaded!",
            style: AppTextStyles.poppinsBold.copyWith(color: Colors.white),
          ),
          description: Text(
            "Your progress photo was saved successfully",
            style: AppTextStyles.poppinsRegular.copyWith(color: Colors.white),
          ),
          alignment: Alignment.topRight,
          autoCloseDuration: const Duration(seconds: 4),
          borderRadius: BorderRadius.circular(12),
          showProgressBar: true,
        );

        await fetchGalleryDashboard();
        await fetchGalleryImages();
      } else {
        throw Exception("Upload failed – server rejected");
      }
    } catch (e) {
      print("❌ [GalleryController] Photo upload error: $e");
      toastification.show(
        type: ToastificationType.error,
        style: ToastificationStyle.fillColored,
        primaryColor: Colors.red,
        foregroundColor: Colors.white,
        title: Text(
          "Upload Failed",
          style: AppTextStyles.poppinsBold.copyWith(color: Colors.white),
        ),
        description: Text(
          "Please try again",
          style: AppTextStyles.poppinsRegular.copyWith(color: Colors.white),
        ),
        alignment: Alignment.topRight,
        autoCloseDuration: const Duration(seconds: 4),
        borderRadius: BorderRadius.circular(12),
        showProgressBar: true,
      );
    } finally {
      isUploading(false);
    }
  }

  Future<void> fetchGalleryImages() async {
    try {
      isLoading(true);
      print('🔄 [GalleryController] Fetching all gallery images...');
      final images = await _homeService.fetchAllGalleryImages();
      // Sort newest first
      images.sort((a, b) => b.uploadedAt.compareTo(a.uploadedAt));
      galleryImages.assignAll(images);
      print('✅ [GalleryController] Loaded ${images.length} gallery images.');
    } catch (e) {
      print('❌ [GalleryController] Error fetching gallery images: $e');
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
          "Failed to load gallery",
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

  /// Helper: Get progress types for a specific date
  Set<ProgressType> getProgressTypesForDate(DateTime date) {
    if (dashboardData.value == null) return {};

    final key = DateFormat('yyyy-MM-dd').format(date);
    final types = dashboardData.value!.dateImageTypes[key] ?? [];

    return types.map((typeStr) {
      switch (typeStr.toLowerCase()) {
        case 'front':
          return ProgressType.front;
        case 'side':
          return ProgressType.side;
        case 'back':
          return ProgressType.back;
        default:
          return ProgressType.front;
      }
    }).toSet();
  }

  /// Helper: Get color from ProgressType
  Color getColorForType(ProgressType type) {
    switch (type) {
      case ProgressType.front:
        return AppColor.customPurple;
      case ProgressType.side:
        return AppColor.green22C55E;
      case ProgressType.back:
        return AppColor.cyan06B6D4;
    }
  }
}
