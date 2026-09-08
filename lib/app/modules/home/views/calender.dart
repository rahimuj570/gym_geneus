// lib/app/modules/gallery/views/calender.dart (or wherever you have it)

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:kenzeno/app/modules/home/views/progressgallery.dart';
import 'package:kenzeno/app/modules/nutrition/controllers/nutri_controller.dart';
import 'package:kenzeno/app/modules/nutrition/views/mealoverall.dart';
import 'package:kenzeno/app/modules/setting/views/gallery_password_setting.dart';

import '../../../res/assets/asset.dart';
import '../../../res/colors/colors.dart';
import '../../../res/fonts/textstyle.dart';
import '../../nutrition/model/nutrion_home.dart';
import '../../setting/views/profile.dart';
import '../controllers/calender_controller.dart';
import 'package:toastification/toastification.dart';

import 'notification.dart';

enum ProgressType {
  front,
  side,
  back;

  String get label {
    switch (this) {
      case ProgressType.front:
        return 'Front';
      case ProgressType.side:
        return 'Side';
      case ProgressType.back:
        return 'Back';
    }
  }

  Color getColor(Map<String, Color> colorMap) {
    switch (this) {
      case ProgressType.front:
        return colorMap['customPurple'] ?? AppColor.customPurple;
      case ProgressType.side:
        return colorMap['green22C55E'] ?? AppColor.green22C55E;
      case ProgressType.back:
        return colorMap['cyan06B6D4'] ?? AppColor.cyan06B6D4;
    }
  }
}

class Meal {
  final String title;
  final String description;
  final String time;
  final int calories;
  final String image;

  Meal({
    required this.title,
    required this.description,
    required this.time,
    required this.calories,
    required this.image,
  });
}

// Color map used across the file
final Map<String, Color> colorMap = {
  'customPurple': AppColor.customPurple,
  'cyan06B6D4': AppColor.cyan06B6D4,
  'green22C55E': AppColor.green22C55E,
};

// ----------------------------------------------------------------------
// MAIN PAGE — Tab between FitTracker & NutriTrack
// ----------------------------------------------------------------------
class Calender extends StatelessWidget {
  const Calender({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: 1, // 0 = FitTracker, 1 = NutriTrack
      child: Scaffold(
        backgroundColor: AppColor.black111214,
        appBar: AppBar(
          backgroundColor: AppColor.black111214,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Text(
            'NutriTrack',
            style: AppTextStyles.poppinsBold.copyWith(
              color: AppColor.white,
              fontSize: 22.sp,
            ),
          ),
          actions: [
            GestureDetector(
              onTap: () => Get.to(
                () => NotificationScreen(),
                transition: Transition.fadeIn,
              ),
              child: Padding(
                padding: EdgeInsets.all(8.w),
                child: SvgPicture.asset(ImageAssets.svg38, height: 20.h),
              ),
            ),
            GestureDetector(
              onTap: () => Get.to(
                () => MyProfileEditScreen(),
                transition: Transition.rightToLeft,
              ),
              child: Padding(
                padding: EdgeInsets.all(8.w),
                child: SvgPicture.asset(ImageAssets.svg39, height: 20.h),
              ),
            ),
            SizedBox(width: 10.w),
          ],
        ),
        body: Column(
          children: [
            // --- Custom Tab Bar (FitTracker vs. NutriTrack) ---
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
              child: Container(
                height: 40.h,
                decoration: BoxDecoration(
                  color: AppColor.gray1F2937,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: TabBar(
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.r),
                    color: AppColor.customPurple,
                    border: Border.all(width: 2, color: Colors.white),
                  ),
                  labelColor: AppColor.white,
                  unselectedLabelColor: AppColor.white.withOpacity(0.7),
                  labelStyle: AppTextStyles.poppinsBold.copyWith(
                    fontSize: 14.sp,
                  ),
                  unselectedLabelStyle: AppTextStyles.poppinsMedium.copyWith(
                    fontSize: 14.sp,
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicatorPadding: EdgeInsets.zero,
                  indicatorWeight: 0,
                  dividerColor: Colors.transparent,
                  tabs: const [
                    Tab(text: 'FitTracker'),
                    Tab(text: 'NutriTrack'),
                  ],
                ),
              ),
            ),

            // --- Tab Views Content ---
            Expanded(
              child: TabBarView(
                children: [
                  // 1. FitTracker View (Your original code, slightly refactored)
                  const FitTrackerView(),

                  // 2. NutriTrack View (Based on previous request)
                  NutriTrackView(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FitTrackerView extends StatelessWidget {
  const FitTrackerView({super.key});

  // Helper widgets (stat card, chip, etc.) – defined at bottom
  Widget _buildStatCard(
    String title,
    String value,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: AppColor.gray9CA3AF.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20.sp),
                SizedBox(width: 8.w),
                Text(
                  title,
                  style: AppTextStyles.poppinsRegular.copyWith(
                    color: color,
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
            SizedBox(height: 5.h),
            Text(
              value,
              style: AppTextStyles.poppinsBold.copyWith(
                color: AppColor.white,
                fontSize: 32.sp,
              ),
            ),
            Text(
              subtitle,
              style: AppTextStyles.poppinsRegular.copyWith(
                color: color,
                fontSize: 12.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonCard() {
    final controller = Get.find<GalleryController>();

    return Obx(() {
      final compData = controller.comparisonData.value;
      final selectedType = controller.selectedComparisonType.value;
      final currentTypeComp = compData?.getForType(selectedType);

      final first = currentTypeComp?.first;
      final last = currentTypeComp?.last;

      String typeLabel = selectedType.isNotEmpty
          ? selectedType[0].toUpperCase() + selectedType.substring(1)
          : 'Front';

      return Container(
        margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        padding: EdgeInsets.all(20.r),
        decoration: BoxDecoration(
          color: AppColor.gray9CA3AF.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header + Angle Selector
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Side-by-Side Comparison',
                  style: AppTextStyles.poppinsBold.copyWith(
                    color: AppColor.white,
                    fontSize: 16.sp,
                  ),
                ),
                SvgPicture.asset(
                  ImageAssets.svg46,
                  height: 20.h,
                  color: AppColor.white,
                ),
              ],
            ),
            SizedBox(height: 12.h),

            // Angle Tabs: Front | Side | Back
            Row(
              children: ['front', 'side', 'back'].map((type) {
                final isSelected = selectedType.toLowerCase() == type;
                final label = type[0].toUpperCase() + type.substring(1);
                return Padding(
                  padding: EdgeInsets.only(right: 8.w),
                  child: GestureDetector(
                    onTap: () => controller.selectComparisonType(type),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColor.customPurple
                            : AppColor.gray1F2937,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: isSelected
                              ? AppColor.customPurple
                              : Colors.white12,
                        ),
                      ),
                      child: Text(
                        label,
                        style: AppTextStyles.poppinsMedium.copyWith(
                          color: isSelected ? Colors.white : AppColor.gray9CA3AF,
                          fontSize: 12.sp,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 16.h),

            // Loading state
            if (controller.isLoadingComparison.value)
              SizedBox(
                height: 180.h,
                child: const Center(
                  child: CircularProgressIndicator(color: AppColor.customPurple),
                ),
              )
            // Case 1: Both First & Last exist
            else if (first != null && last != null) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildComparisonImage(
                    'BEFORE',
                    DateFormat('MMM dd').format(first.uploadedAt),
                    first.image,
                  ),
                  _buildComparisonImage(
                    'AFTER',
                    DateFormat('MMM dd').format(last.uploadedAt),
                    last.image,
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Center(
                child: Column(
                  children: [
                    Text(
                      _calculateDaysDifference(first.uploadedAt, last.uploadedAt),
                      style: AppTextStyles.poppinsBold.copyWith(
                        color: AppColor.green22C55E,
                        fontSize: 16.sp,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      last.aiSummary != null && last.aiSummary!.isNotEmpty
                          ? last.aiSummary!
                          : 'Keep pushing forward!',
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.poppinsRegular.copyWith(
                        color: AppColor.gray9CA3AF,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ]
            // Case 2: Only 1 image (first != null && last == null)
            else if (first != null && last == null) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildComparisonImage(
                    'BEFORE',
                    DateFormat('MMM dd').format(first.uploadedAt),
                    first.image,
                  ),
                  _buildPendingComparisonSlot(typeLabel),
                ],
              ),
              SizedBox(height: 12.h),
              Center(
                child: Column(
                  children: [
                    Text(
                      '1 $typeLabel photo uploaded',
                      style: AppTextStyles.poppinsBold.copyWith(
                        color: AppColor.customPurple,
                        fontSize: 14.sp,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'Upload another $typeLabel photo to see your transformation comparison!',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.poppinsRegular.copyWith(
                        color: AppColor.gray9CA3AF,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ]
            // Case 3: 0 images for this angle
            else ...[
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 16.w),
                decoration: BoxDecoration(
                  color: AppColor.black111214.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: Colors.white12),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.compare_arrows_rounded,
                      size: 44.sp,
                      color: AppColor.gray9CA3AF,
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'No $typeLabel photos yet',
                      style: AppTextStyles.poppinsBold.copyWith(
                        color: Colors.white,
                        fontSize: 14.sp,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Take a $typeLabel progress photo to start tracking your transformation.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.poppinsRegular.copyWith(
                        color: AppColor.gray9CA3AF,
                        fontSize: 12.sp,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    GestureDetector(
                      onTap: () => _showPhotoSourceSheet(),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          color: AppColor.customPurple,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.camera_alt, color: Colors.white, size: 16.sp),
                            SizedBox(width: 6.w),
                            Text(
                              'Take Photo',
                              style: AppTextStyles.poppinsBold.copyWith(
                                color: Colors.white,
                                fontSize: 12.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      );
    });
  }

  String _calculateDaysDifference(DateTime first, DateTime last) {
    final diff = last.difference(first).inDays.abs();
    if (diff == 0) return 'Same day progress';
    if (diff == 1) return '1 day progress';
    return '$diff days progress';
  }

  Widget _buildPendingComparisonSlot(String typeLabel) {
    return GestureDetector(
      onTap: () => _showPhotoSourceSheet(),
      child: Column(
        children: [
          Container(
            width: 140.w,
            height: 180.h,
            decoration: BoxDecoration(
              color: AppColor.black111214.withOpacity(0.6),
              borderRadius: BorderRadius.circular(15.r),
              border: Border.all(
                color: AppColor.customPurple.withOpacity(0.5),
                width: 1.5,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_a_photo_outlined,
                  color: AppColor.customPurple,
                  size: 32.sp,
                ),
                SizedBox(height: 8.h),
                Text(
                  'Add AFTER',
                  style: AppTextStyles.poppinsBold.copyWith(
                    color: Colors.white,
                    fontSize: 12.sp,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Tap to upload',
                  style: AppTextStyles.poppinsRegular.copyWith(
                    color: AppColor.gray9CA3AF,
                    fontSize: 10.sp,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 5.h),
          Text(
            'Pending photo',
            style: AppTextStyles.poppinsRegular.copyWith(
              color: AppColor.gray9CA3AF,
              fontSize: 12.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonImage(String title, String date, String imageUrl) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(15.r),
          child: Container(
            width: 140.w,
            height: 180.h,
            color: Colors.black26,
            child: Stack(
              fit: StackFit.expand,
              children: [
                imageUrl.startsWith('http')
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Image.asset(
                          ImageAssets.img_21,
                          fit: BoxFit.cover,
                        ),
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return const Center(
                            child: CircularProgressIndicator(
                              color: AppColor.customPurple,
                              strokeWidth: 2,
                            ),
                          );
                        },
                      )
                    : Image.asset(imageUrl, fit: BoxFit.cover),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Container(
                    margin: EdgeInsets.all(8.r),
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: AppColor.black111214.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Text(
                      title,
                      style: AppTextStyles.poppinsBold.copyWith(
                        color: AppColor.white,
                        fontSize: 12.sp,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 5.h),
        Text(
          date,
          style: AppTextStyles.poppinsRegular.copyWith(
            color: AppColor.gray9CA3AF,
            fontSize: 12.sp,
          ),
        ),
      ],
    );
  }

  Widget _buildTakePhotoButton() {
    final controller = Get.find<GalleryController>();

    return Obx(
      () => Container(
        margin: EdgeInsets.symmetric(horizontal: 20.w),
        height: 56.h,
        decoration: BoxDecoration(
          color: AppColor.customPurple,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: TextButton.icon(
          onPressed: controller.isUploading.value
              ? null
              : () => _showPhotoSourceSheet(),
          icon: controller.isUploading.value
              ? SizedBox(
                  width: 24.w,
                  height: 24.w,
                  child: const CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : const Icon(Icons.camera_alt, color: Colors.white, size: 28),
          label: Text(
            controller.isUploading.value ? "Uploading..." : "Take Photo",
            style: AppTextStyles.poppinsBold.copyWith(
              color: Colors.white,
              fontSize: 18.sp,
            ),
          ),
        ),
      ),
    );
  }

  void _showPhotoSourceSheet() {
    final controller = Get.find<GalleryController>();

    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(24.w),
        decoration: const BoxDecoration(
          color: AppColor.gray1F2937,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Add Progress Photo",
              style: AppTextStyles.poppinsBold.copyWith(
                fontSize: 20.sp,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 30.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _photoOption(Icons.camera_alt, "Camera", () {
                  Get.back();
                  controller.takeAndUploadPhoto(fromGallery: false);
                }),
                _photoOption(Icons.photo_library, "Gallery", () {
                  Get.back();
                  controller.takeAndUploadPhoto(fromGallery: true);
                }),
              ],
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _photoOption(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: AppColor.customPurple.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 30.sp, color: AppColor.customPurple),
          ),
          SizedBox(height: 12.h),
          Text(
            label,
            style: AppTextStyles.poppinsSemiBold.copyWith(
              color: Colors.white,
              fontSize: 12.sp,
            ),
          ),
        ],
      ),
    );
  }

  void _showPasswordDialog(BuildContext context) {
    final ctrl = TextEditingController();
    final storage = GetStorage();

    Get.defaultDialog(
      backgroundColor: AppColor.gray1F2937,
      title: '',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.lock, color: AppColor.customPurple, size: 60),
          const SizedBox(height: 10),
          Text(
            'Enter Gallery PIN',
            style: AppTextStyles.poppinsBold.copyWith(
              color: AppColor.white,
              fontSize: 18.sp,
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: TextField(
              controller: ctrl,
              obscureText: true,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Enter 4-digit PIN',
                hintStyle: TextStyle(color: AppColor.gray9CA3AF),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColor.gray9CA3AF),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: AppColor.customPurple),
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.customPurple,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 10.h),
            ),
            onPressed: () {
              final entered = ctrl.text.trim();
              final currentSavedPin = storage.read<String>('gallery_password') ?? '1234';

              if (entered == currentSavedPin) {
                Get.back();
                Get.to(
                  () => ProgressGalleryPage(),
                  transition: Transition.rightToLeft,
                );
              } else {
                toastification.show(
                  type: ToastificationType.error,
                  style: ToastificationStyle.fillColored,
                  primaryColor: Colors.red,
                  foregroundColor: Colors.white,
                  title: Text(
                    'Error',
                    style: AppTextStyles.poppinsBold.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  description: Text(
                    'Incorrect PIN/password',
                    style: AppTextStyles.poppinsRegular.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  alignment: Alignment.topRight,
                  autoCloseDuration: const Duration(seconds: 4),
                  borderRadius: BorderRadius.circular(12),
                  showProgressBar: true,
                );
              }
            },
            child: Text(
              'Submit',
              style: AppTextStyles.poppinsBold.copyWith(color: AppColor.white),
            ),
          ),
          SizedBox(height: 12.h),
          GestureDetector(
            onTap: () {
              Get.back();
              Get.to(
                () => const GalleryPasswordSettingsScreen(),
                transition: Transition.rightToLeft,
              );
            },
            child: Text(
              'Change PIN in Settings',
              style: AppTextStyles.poppinsRegular.copyWith(
                color: AppColor.customPurple,
                fontSize: 12.sp,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Calendar Grid – Real dots from API
  Widget _buildCalendarGrid(
    DateTime month,
    Map<String, List<String>> dateTypes,
  ) {
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final firstDay = DateTime(month.year, month.month, 1);
    final startWeekday = firstDay.weekday % 7; // 0 = Sunday

    final prevMonth = DateTime(month.year, month.month, 0);
    final daysInPrev = prevMonth.day;

    List<DateTime> days = [];

    // Prev month
    for (int i = startWeekday; i > 0; i--) {
      days.add(DateTime(prevMonth.year, prevMonth.month, daysInPrev - i + 1));
    }
    // Current month
    for (int i = 1; i <= daysInMonth; i++)
      days.add(DateTime(month.year, month.month, i));
    // Next month (fill 6 rows)
    for (int i = 1; i <= (42 - days.length); i++) {
      days.add(DateTime(month.year, month.month + 1, i));
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 0.8,
      ),
      itemCount: days.length,
      itemBuilder: (_, index) {
        final day = days[index];
        final isCurrentMonth = day.month == month.month;
        final key = DateFormat('yyyy-MM-dd').format(day);
        final types = (dateTypes[key] ?? []).map((t) {
          final s = t.toLowerCase().trim();
          if (s.contains('back') || s.contains('rear')) {
            return ProgressType.back;
          } else if (s.contains('side') || s.contains('lateral') || s.contains('left') || s.contains('right')) {
            return ProgressType.side;
          } else {
            return ProgressType.front;
          }
        }).toSet();

        final isToday = day.isSameDate(DateTime.now());

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 32.w,
              height: 32.w,
              alignment: Alignment.center,
              decoration: isToday
                  ? BoxDecoration(
                      color: AppColor.customPurple,
                      borderRadius: BorderRadius.circular(10.r),
                    )
                  : null,
              child: Text(
                '${day.day}',
                style: AppTextStyles.poppinsSemiBold.copyWith(
                  fontSize: 14.sp,
                  color: isCurrentMonth
                      ? (isToday ? AppColor.white : AppColor.white)
                      : AppColor.gray9CA3AF.withOpacity(0.5),
                ),
              ),
            ),
            if (types.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(top: 4.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: types
                      .map(
                        (t) => Container(
                          margin: EdgeInsets.symmetric(horizontal: 1.5.w),
                          width: 6.w,
                          height: 6.w,
                          decoration: BoxDecoration(
                            color: t.getColor(colorMap),
                            shape: BoxShape.circle,
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildGalleryItem(
    String date,
    String type,
    String url,
    Color tagColor,
  ) {
    return Container(
      width: 160.w,
      height: 180.h,
      margin: EdgeInsets.only(right: 15.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        color: AppColor.gray9CA3AF.withOpacity(0.1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.r),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              url,
              fit: BoxFit.cover,
              loadingBuilder: (_, child, progress) => progress == null
                  ? child
                  : Container(color: AppColor.gray1F2937),
              errorBuilder: (_, __, ___) => Container(
                color: AppColor.gray1F2937,
                child: const Icon(Icons.error),
              ),
            ),

            /// 🔵 BLUR CENSOR EFFECT ADDED HERE
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12), // adjust blur
              child: Container(
                color: Colors.black.withOpacity(0),
              ), // transparent overlay
            ),

            Positioned(
              bottom: 10.h,
              left: 10.w,
              child: Text(
                date,
                style: AppTextStyles.poppinsSemiBold.copyWith(
                  color: AppColor.white,
                  fontSize: 12.sp,
                  shadows: [Shadow(blurRadius: 6, color: Colors.black)],
                ),
              ),
            ),

            Positioned(
              bottom: 10.h,
              right: 10.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: tagColor,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  type,
                  style: AppTextStyles.poppinsSemiBold.copyWith(
                    color: AppColor.white,
                    fontSize: 10.sp,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(GalleryController());

    return Obx(() {
      final data = controller.dashboardData.value;
      final loading = controller.isLoading.value;
      final month = controller.currentMonth.value;

      if (loading) {
        return const Center(
          child: CircularProgressIndicator(color: AppColor.customPurple),
        );
      }
      if (data == null) {
        return const Center(
          child: Text('No data', style: TextStyle(color: AppColor.white)),
        );
      }

      return RefreshIndicator(
        color: AppColor.customPurple,
        onRefresh: () async {
          await Future.wait([
            controller.fetchGalleryDashboard(),
            controller.fetchGalleryImages(),
            controller.fetchGalleryComparison(),
          ]);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Stats
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                child: Row(
                  children: [
                    _buildStatCard(
                      'Photos',
                      '${data.totalImages}',
                      '+${data.imagesLastWeek} this week',
                      Icons.camera_alt,
                      AppColor.green22C55E,
                    ),
                    SizedBox(width: 20.w),
                    _buildStatCard(
                      'Streak',
                      '${data.consecutiveDaysStreak}',
                      'Days active',
                      Icons.local_fire_department,
                      AppColor.customPurple,
                    ),
                  ],
                ),
              ),

              // Month Selector
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat('MMMM yyyy').format(month),
                      style: AppTextStyles.poppinsBold.copyWith(
                        color: AppColor.white,
                        fontSize: 20.sp,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios,
                            size: 18,
                            color: AppColor.white,
                          ),
                          onPressed: () => controller.changeMonth(-1),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_forward_ios,
                            size: 18,
                            color: AppColor.white,
                          ),
                          onPressed: () => controller.changeMonth(1),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Weekdays
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Row(
                  children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                      .map(
                        (d) => Expanded(
                          child: Center(
                            child: Text(
                              d,
                              style: AppTextStyles.poppinsSemiBold.copyWith(
                                color: AppColor.gray9CA3AF,
                                fontSize: 14.sp,
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),

              // Calendar Grid
              _buildCalendarGrid(month, data.dateImageTypes),

              // Legend
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: ProgressType.values
                      .map(
                        (t) => Row(
                          children: [
                            Container(
                              width: 10.w,
                              height: 10.w,
                              decoration: BoxDecoration(
                                color: t.getColor(colorMap),
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              t.label,
                              style: AppTextStyles.poppinsRegular.copyWith(
                                color: AppColor.white,
                                fontSize: 12.sp,
                              ),
                            ),
                          ],
                        ),
                      )
                      .toList(),
                ),
              ),

              // Gallery
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 10.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Progress Gallery',
                      style: AppTextStyles.poppinsBold.copyWith(
                        color: AppColor.white,
                        fontSize: 18.sp,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _showPasswordDialog(context),
                      child: Text(
                        'View All',
                        style: AppTextStyles.poppinsSemiBold.copyWith(
                          color: AppColor.green22C55E,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Row(
                  children: data.latestImages
                      .map(
                        (img) => _buildGalleryItem(
                          DateFormat('MMM dd').format(img.uploadedAt),
                          img.progressType.label,
                          img.imageUrl,
                          img.progressType.getColor(colorMap),
                        ),
                      )
                      .toList(),
                ),
              ),

              SizedBox(height: 20.h),
              _buildComparisonCard(),
              _buildTakePhotoButton(),
              SizedBox(height: 40.h),
            ],
          ),
        ),
      );
    });
  }
}

class NutriTrackView extends StatelessWidget {
  NutriTrackView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<NutritionController>(
      init: NutritionController(),
      builder: (controller) {
        final data = controller.nutritionData.value;

        if (controller.isLoading.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: AppColor.customPurple),
                SizedBox(height: 16.h),
                Text(
                  'Loading nutrition data...',
                  style: AppTextStyles.poppinsMedium.copyWith(
                    color: AppColor.gray9CA3AF,
                  ),
                ),
              ],
            ),
          );
        }

        if (data == null) {
          return _buildEmptyState(controller);
        }

        return RefreshIndicator(
          color: AppColor.customPurple,
          onRefresh: () => controller.fetchNutritionData(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMetricsSection(data),
                SizedBox(height: 20.h),
                _buildTodayProgressCard(data),
                SizedBox(height: 20.h),
                _buildTodaysMealsSection(data),
                SizedBox(height: 30.h),
                _buildNutritionBreakdown(data),
                SizedBox(height: 30.h),
                Container(
                  width: double.infinity,
                  height: 54.h,
                  decoration: BoxDecoration(
                    color: AppColor.customPurple,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: TextButton.icon(
                    onPressed: () => Get.to(
                      () => MealIdeasPage(),
                      transition: Transition.rightToLeft,
                    ),
                    icon: const Icon(Icons.camera_alt, color: Colors.white, size: 24),
                    label: Text(
                      "Scan Another Meal",
                      style: AppTextStyles.poppinsBold.copyWith(
                        color: Colors.white,
                        fontSize: 16.sp,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 40.h),
              ],
            ),
          ),
        );
      },
    );
  }

  /// EMPTY STATE
  Widget _buildEmptyState(NutritionController controller) {
    return RefreshIndicator(
      color: AppColor.customPurple,
      onRefresh: () => controller.fetchNutritionData(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: 120.h),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.restaurant_menu,
                  size: 64.sp,
                  color: AppColor.gray9CA3AF,
                ),
                SizedBox(height: 16.h),
                Text(
                  'No nutrition data yet',
                  style: AppTextStyles.poppinsMedium.copyWith(
                    color: AppColor.white,
                    fontSize: 18.sp,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Scan your first meal to get started!',
                  style: AppTextStyles.poppinsRegular.copyWith(
                    color: AppColor.gray9CA3AF,
                    fontSize: 13.sp,
                  ),
                ),
                SizedBox(height: 24.h),
                ElevatedButton.icon(
                  onPressed: () => Get.to(
                    () => MealIdeasPage(),
                    transition: Transition.rightToLeft,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.customPurple,
                    padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                  ),
                  icon: const Icon(Icons.camera_alt, color: Colors.white),
                  label: Text(
                    'Scan Meal',
                    style: AppTextStyles.poppinsBold.copyWith(
                      color: Colors.white,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// METRICS SECTION
  Widget _buildMetricsSection(NutritionHomeResponse data) {
    return Row(
      children: [
        _buildMetricCard(
          title: 'Meals Logged',
          value: '${data.totalMeals}',
          subtitle: '+1 this week',
          icon: Icons.restaurant_menu,
          color: AppColor.green22C55E,
        ),
        SizedBox(width: 20.w),
        _buildMetricCard(
          title: 'Streak',
          value: '${data.streak}',
          subtitle: 'days active',
          icon: Icons.local_fire_department,
          color: AppColor.orangeF97316,
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: AppColor.gray9CA3AF.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20.sp),
                SizedBox(width: 5.w),
                Text(
                  title,
                  style: AppTextStyles.poppinsRegular.copyWith(
                    color: AppColor.gray9CA3AF,
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
            SizedBox(height: 5.h),
            Text(
              value,
              style: AppTextStyles.poppinsBold.copyWith(
                color: AppColor.white,
                fontSize: 32.sp,
              ),
            ),
            Text(
              subtitle,
              style: AppTextStyles.poppinsRegular.copyWith(
                color: color,
                fontSize: 12.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// TODAY PROGRESS CARD
  Widget _buildTodayProgressCard(NutritionHomeResponse data) {
    final double progress = data.caloriesTarget > 0
        ? (data.caloriesGain / data.caloriesTarget).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF580C88), Color(0xFF896CFE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Today's Progress",
                style: AppTextStyles.poppinsMedium.copyWith(
                  fontSize: 16.sp,
                  color: AppColor.white.withOpacity(0.8),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 8.w),
                decoration: BoxDecoration(
                  color: AppColor.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20.w),
                ),
                child: SvgPicture.asset(
                  ImageAssets.svg57,
                  color: Colors.white,
                  height: 20.h,
                ),
              ),
            ],
          ),
          SizedBox(height: 5.h),
          Text(
            DateFormat('MMMM dd, yyyy').format(DateTime.now()),
            style: AppTextStyles.poppinsRegular.copyWith(
              fontSize: 12.sp,
              color: AppColor.white.withOpacity(0.6),
            ),
          ),
          SizedBox(height: 15.h),
          Text.rich(
            TextSpan(
              text: '${data.caloriesGain}',
              style: AppTextStyles.poppinsBold.copyWith(
                fontSize: 28.sp,
                color: AppColor.white,
              ),
              children: [
                TextSpan(
                  text: ' / ${data.caloriesTarget} cal',
                  style: AppTextStyles.poppinsMedium.copyWith(
                    fontSize: 22.sp,
                    color: AppColor.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10.h,
              backgroundColor: AppColor.gray1F2937,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColor.white),
            ),
          ),
        ],
      ),
    );
  }

  /// TODAY'S MEALS SECTION
  /// TODAY'S MEALS SECTION (clickable cards)
  Widget _buildTodaysMealsSection(NutritionHomeResponse data) {
    if (data.todaysMeals.isEmpty) {
      return Center(
        child: Text(
          'No meals logged today',
          style: AppTextStyles.poppinsRegular.copyWith(
            color: AppColor.gray9CA3AF,
            fontSize: 14.sp,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Today's Meals",
          style: AppTextStyles.poppinsBold.copyWith(
            fontSize: 18.sp,
            color: AppColor.white,
          ),
        ),
        SizedBox(height: 15.h),
        ...data.todaysMeals.map((meal) => _buildMealCard(meal)),
      ],
    );
  }

  /// Meal card with clickable popup
  Widget _buildMealCard(TodayMeal meal) {
    return GestureDetector(
      onTap: () => _showMealDetailsPopup(meal),
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.r),
          color: AppColor.gray1F2937.withOpacity(0.3),
        ),
        child: Row(
          children: [
            _buildMealImage(meal),
            SizedBox(width: 15.w),
            Expanded(child: _buildMealSummary(meal)),
            SizedBox(width: 5.w),
            Text(
              '${meal.estimatedCalories} cal',
              style: AppTextStyles.poppinsBold.copyWith(
                fontSize: 12.sp,
                color: AppColor.green22C55E,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Meal image
  Widget _buildMealImage(TodayMeal meal) {
    return Container(
      width: 60.w,
      height: 60.w,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.r),
        color: AppColor.gray1F2937,
        image: meal.imageUrl.isNotEmpty
            ? DecorationImage(
                image: NetworkImage(meal.imageUrl),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: meal.imageUrl.isEmpty
          ? Icon(Icons.restaurant, color: AppColor.white, size: 30)
          : null,
    );
  }

  /// Meal summary (for the card)
  Widget _buildMealSummary(TodayMeal meal) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          meal.mealName.isNotEmpty ? meal.mealName : 'Meal',
          style: AppTextStyles.poppinsBold.copyWith(
            fontSize: 16.sp,
            color: AppColor.white,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          meal.aiAnalysis.isNotEmpty
              ? (meal.aiAnalysis.length > 40
                    ? '${meal.aiAnalysis.substring(0, 40)}...'
                    : meal.aiAnalysis)
              : 'No analysis available',
          style: AppTextStyles.poppinsRegular.copyWith(
            fontSize: 14.sp,
            color: AppColor.white.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  void _showMealDetailsPopup(TodayMeal meal) {
    Get.dialog(
      Dialog(
        backgroundColor: AppColor.gray1F2937,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Meal image
              Container(
                width: double.infinity,
                height: 180.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15.r),
                  image: meal.imageUrl.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(meal.imageUrl),
                          fit: BoxFit.cover,
                        )
                      : null,
                  color: AppColor.gray1F2937,
                ),
                child: meal.imageUrl.isEmpty
                    ? Icon(Icons.restaurant, color: AppColor.white, size: 40)
                    : null,
              ),
              SizedBox(height: 15.h),

              /// Meal name
              Text(
                meal.mealName.isNotEmpty ? meal.mealName : 'Meal',
                style: AppTextStyles.poppinsBold.copyWith(
                  fontSize: 20.sp,
                  color: AppColor.white,
                ),
              ),
              SizedBox(height: 8.h),

              /// AI analysis
              Text(
                meal.aiAnalysis.isNotEmpty
                    ? meal.aiAnalysis
                    : 'No analysis available',
                style: AppTextStyles.poppinsRegular.copyWith(
                  fontSize: 14.sp,
                  color: AppColor.white.withOpacity(0.7),
                ),
              ),
              SizedBox(height: 12.h),

              /// Calories
              Row(
                children: [
                  Icon(
                    Icons.local_fire_department,
                    color: AppColor.green22C55E,
                    size: 20.sp,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    '${meal.estimatedCalories} cal',
                    style: AppTextStyles.poppinsBold.copyWith(
                      fontSize: 14.sp,
                      color: AppColor.green22C55E,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),

              /// Tip (if any)
              if (meal.improvements.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tips',
                      style: AppTextStyles.poppinsBold.copyWith(
                        fontSize: 16.sp,
                        color: AppColor.white,
                      ),
                    ),
                    SizedBox(height: 5.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColor.green22C55E.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Text(
                        meal.improvements, // use string directly
                        style: AppTextStyles.poppinsRegular.copyWith(
                          fontSize: 12.sp,
                          color: AppColor.green22C55E,
                        ),
                      ),
                    ),
                  ],
                ),
              SizedBox(height: 15.h),

              /// Close button
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Get.back(),
                  child: Text(
                    'Close',
                    style: AppTextStyles.poppinsMedium.copyWith(
                      fontSize: 14.sp,
                      color: AppColor.green22C55E,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// NUTRITION BREAKDOWN - Grouped Macro & Micro (No "Macro"/"Micro" in containers)
  Widget _buildNutritionBreakdown(NutritionHomeResponse data) {
    final macros = data.nutritionBreakdown
        .where(
          (n) => ['carbs', 'protein', 'fat'].contains(n.name.toLowerCase()),
        )
        .toList();
    final micros = data.nutritionBreakdown
        .where(
          (n) => !['carbs', 'protein', 'fat'].contains(n.name.toLowerCase()),
        )
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // SECTION HEADER
        Text(
          "Nutrition Breakdown",
          style: AppTextStyles.poppinsBold.copyWith(
            fontSize: 18.sp,
            color: AppColor.white,
          ),
        ),
        SizedBox(height: 15.h),

        // MACRO SECTION
        if (macros.isNotEmpty) ...[
          Text(
            "Macro",
            style: AppTextStyles.poppinsBold.copyWith(
              fontSize: 16.sp,
              color: AppColor.white,
            ),
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              for (var n in macros) Expanded(child: _buildMacroCardDynamic(n)),
            ],
          ),
          SizedBox(height: 20.h),
        ],

        // MICRO SECTION LABEL
        if (micros.isNotEmpty) ...[
          Text(
            "Micro",
            style: AppTextStyles.poppinsBold.copyWith(
              fontSize: 16.sp,
              color: AppColor.white,
            ),
          ),
          SizedBox(height: 10.h),

          // MICRONUTRIENTS ROW / WRAP
          Wrap(
            spacing: 12.w,
            runSpacing: 12.h,
            children: micros.map((n) => _buildMicroCard(n)).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildMacroCardDynamic(NutrientBreakdown n) {
    final gradient = _getNutrientGradient(n.name);
    final icon = _getNutrientIcon(n.name);

    return Container(
      height: 120.h,
      margin: EdgeInsets.symmetric(horizontal: 5.w),
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(15.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 28.sp, color: Colors.white),
          SizedBox(height: 8.h),
          Text(
            n.name,
            style: AppTextStyles.poppinsMedium.copyWith(
              fontSize: 12.sp,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            '${n.amount}${n.unit}',
            style: AppTextStyles.poppinsBold.copyWith(
              fontSize: 16.sp,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMicroCard(NutrientBreakdown n) {
    final gradient = _getNutrientGradient(n.name);
    final icon = _getNutrientIcon(n.name);

    return Container(
      width: 100.w,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(15.r),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 20.sp, color: Colors.white),
          SizedBox(height: 4.h),
          Text(
            n.name,
            style: AppTextStyles.poppinsMedium.copyWith(
              fontSize: 12.sp,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4.h),
          Text(
            '${n.amount}${n.unit}',
            style: AppTextStyles.poppinsBold.copyWith(
              fontSize: 14.sp,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  LinearGradient _getNutrientGradient(String name) {
    switch (name.toLowerCase()) {
      case 'carbs':
        return const LinearGradient(
          colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
        );
      case 'protein':
        return const LinearGradient(
          colors: [Color(0xFF11998E), Color(0xFF38EF7D)],
        );
      case 'fat':
        return const LinearGradient(
          colors: [Color(0xFFF7971E), Color(0xFFFFD200)],
        );
      case 'iron':
        return const LinearGradient(
          colors: [Color(0xFFDC2626), Color(0xFFF87171)],
        );
      case 'calcium':
        return const LinearGradient(
          colors: [Color(0xFF10B981), Color(0xFF6EE7B7)],
        );
      case 'vitaminc':
        return const LinearGradient(
          colors: [Color(0xFFF97316), Color(0xFFFFB347)],
        );
      default:
        return const LinearGradient(
          colors: [Color(0xFF7C3AED), Color(0xFF8B5CF6)],
        );
    }
  }

  IconData _getNutrientIcon(String name) {
    switch (name.toLowerCase()) {
      case 'carbs':
        return Icons.bubble_chart;
      case 'protein':
        return Icons.fitness_center;
      case 'fat':
        return Icons.oil_barrel;
      case 'iron':
        return Icons.bloodtype;
      case 'calcium':
        return Icons.local_hospital;
      case 'vitaminc':
        return Icons.local_florist;
      default:
        return Icons.star;
    }
  }
}

// Extension for firstWhereOrNull (if you don't have collection package)
extension IterableExtension<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T element) test) {
    try {
      return firstWhere(test);
    } catch (e) {
      return null;
    }
  }
}

// Helper extension for date comparison
extension DateOnlyCompare on DateTime {
  bool isSameDate(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }
}
