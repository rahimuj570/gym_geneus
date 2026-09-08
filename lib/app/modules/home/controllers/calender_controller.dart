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
  var comparisonData = Rxn<GalleryComparisonResponse>();
  var selectedComparisonType = 'front'.obs;
  var isLoadingComparison = false.obs;

  // Image Picker
  final ImagePicker _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    print('📦 [GalleryController] Initialized. Fetching gallery dashboard, images, and comparison...');
    fetchGalleryDashboard();
    fetchGalleryImages(); // Load current month
    fetchGalleryComparison();
  }

  /// Fetch FitTracker dashboard (calendar + photos + streak)
  Future<void> fetchGalleryDashboard({int? month, int? year, bool silent = false}) async {
    try {
      if (!silent) isLoading(true);
      final m = month ?? currentMonth.value.month;
      final y = year ?? currentMonth.value.year;
      print('🔄 [GalleryController] Fetching dashboard for month: $m, year: $y (silent: $silent)');

      final response = await _homeService.fetchGalleryDashboard(
        month: m,
        year: y,
      );

      dashboardData.value = response;
      currentMonth.value = DateTime(y, m);
      print('✅ [GalleryController] Dashboard loaded. Total images: ${response.totalImages}, streak: ${response.consecutiveDaysStreak}');
    } catch (e) {
      print('❌ [GalleryController] Error fetching dashboard: $e');
      if (!silent) {
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
      }
    } finally {
      if (!silent) isLoading(false);
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

      final uploadResult = await _homeService.uploadProgressPhoto(
        imageBytes: bytes, // ← just the raw bytes
      );

      if (uploadResult != null) {
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

        // Immediate fetch to render the newly uploaded photo right away
        await Future.wait([
          fetchGalleryDashboard(silent: true),
          fetchGalleryImages(silent: true),
          fetchGalleryComparison(silent: true),
        ]);

        // Background auto-refresh polling so AI detected pose/type updates without manual refresh
        _pollForAIClassification();
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

  /// Automatically polls in intervals after upload to fetch the AI-classified image type without screen flicker
  void _pollForAIClassification() {
    final intervals = [1000, 2500, 4500];
    for (final ms in intervals) {
      Future.delayed(Duration(milliseconds: ms), () async {
        try {
          await Future.wait([
            fetchGalleryDashboard(silent: true),
            fetchGalleryImages(silent: true),
            fetchGalleryComparison(silent: true),
          ]);
          print('🔄 [GalleryController] AI classification auto-update checked at ${ms}ms');
        } catch (e) {
          print('⚠️ [GalleryController] AI auto-update error at ${ms}ms: $e');
        }
      });
    }
  }

  Future<void> fetchGalleryComparison({bool silent = false}) async {
    try {
      if (!silent) isLoadingComparison(true);
      print('🔄 [GalleryController] Fetching gallery comparison (silent: $silent)...');
      final comp = await _homeService.fetchGalleryComparison();
      comparisonData.value = comp;
      print('✅ [GalleryController] Loaded gallery comparison successfully.');
    } catch (e) {
      print('❌ [GalleryController] Error fetching comparison: $e');
    } finally {
      if (!silent) isLoadingComparison(false);
    }
  }

  void selectComparisonType(String type) {
    selectedComparisonType.value = type.toLowerCase();
  }

  Future<void> fetchGalleryImages({bool silent = false}) async {
    try {
      if (!silent) isLoading(true);
      print('🔄 [GalleryController] Fetching all gallery images (silent: $silent)...');
      final images = await _homeService.fetchAllGalleryImages();
      // Sort newest first
      images.sort((a, b) => b.uploadedAt.compareTo(a.uploadedAt));
      galleryImages.assignAll(images);
      print('✅ [GalleryController] Loaded ${images.length} gallery images.');
    } catch (e) {
      print('❌ [GalleryController] Error fetching gallery images: $e');
      if (!silent) {
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
      }
    } finally {
      if (!silent) isLoading(false);
    }
  }

  /// Helper: Get progress types for a specific date
  Set<ProgressType> getProgressTypesForDate(DateTime date) {
    if (dashboardData.value == null) return {};

    final key = DateFormat('yyyy-MM-dd').format(date);
    final types = dashboardData.value!.dateImageTypes[key] ?? [];

    return types.map((typeStr) {
      final s = typeStr.toLowerCase().trim();
      if (s.contains('back') || s.contains('rear')) {
        return ProgressType.back;
      } else if (s.contains('side') || s.contains('lateral') || s.contains('left') || s.contains('right')) {
        return ProgressType.side;
      } else {
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
