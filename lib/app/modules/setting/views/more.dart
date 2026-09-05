// more.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:kenzeno/app/modules/auth/views/login.dart';
import 'package:kenzeno/app/modules/setting/views/favourite.dart';
import 'package:kenzeno/app/modules/setting/views/helpandfaq.dart';
import 'package:kenzeno/app/modules/setting/views/privacy_policy.dart';
import 'package:kenzeno/app/modules/setting/views/profile.dart';
import 'package:kenzeno/app/modules/setting/views/settings.dart';

import 'package:kenzeno/app/res/assets/asset.dart';
import '../../../res/colors/colors.dart';
import '../../../res/fonts/textstyle.dart';
import '../../subscription/views/subscription.dart';
import '../../setup/views/coach.dart';
import '../controller/profilecontroller.dart'; // ← ADD THIS
import '../model/profile_model.dart';
import 'package:toastification/toastification.dart';
import 'package:kenzeno/app/res/fonts/textstyle.dart';
import 'package:kenzeno/app/res/colors/colors.dart';
import 'package:kenzeno/app/modules/auth/controllers/authcontroller.dart';
// ← ADD THIS

class More extends StatelessWidget {
  More({super.key});

  // Rank SVG mapping
  final Map<String, String> rankIcons = {
    'BRONZE': ImageAssets.svg64,
    'SILVER': ImageAssets.svg65,
    'GOLD': ImageAssets.svg66,
    'PLATINUM': ImageAssets.svg67,
    'DIAMOND': ImageAssets.svg68,
  };

  Color _colorFromHex(String? hexColor) {
    if (hexColor == null) return const Color(0xFFCD7F32);
    hexColor = hexColor.replaceAll("#", "");
    return Color(int.parse("0xFF$hexColor"));
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProfileController>();

    // Fetch profile on screen open
    controller.fetchProfile();

    return Scaffold(
      backgroundColor: AppColor.black111214,
      body: SafeArea(
        child: Obx(() {
          final profile = controller.profile.value;

          // Loading state
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: AppColor.customPurple),
            );
          }

          // Real data
          final rankName = (profile.rank?.name ?? 'BRONZE').toUpperCase();
          final rankLevel = profile.rank?.level ?? 1;
          final rankColor = _colorFromHex(profile.rank?.colorCode);
          final rankSvg = rankIcons[rankName] ?? ImageAssets.svg64;

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // PROFILE SECTION
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 45.r,
                        backgroundImage:
                            profile.avatar != null && profile.avatar!.isNotEmpty
                            ? NetworkImage(profile.avatar!) as ImageProvider
                            : const AssetImage(ImageAssets.img_3),
                        backgroundColor: AppColor.gray9CA3AF,
                      ),
                      SizedBox(height: 12.h),

                      // Full Name
                      Text(
                        profile.fullName ?? "Your Name",
                        style: AppTextStyles.poppinsSemiBold.copyWith(
                          color: Colors.white,
                          fontSize: 18.sp,
                        ),
                      ),

                      // Email
                      Text(
                        profile.email ?? "your@email.com",
                        style: AppTextStyles.poppinsRegular.copyWith(
                          color: AppColor.white30,
                          fontSize: 14.sp,
                        ),
                      ),

                      // Birthday
                      Text(
                        profile.dateOfBirth == null
                            ? "Birthday: Not set"
                            : "Birthday: ${_formatBirthday(profile.dateOfBirth!)}",
                        style: AppTextStyles.poppinsRegular.copyWith(
                          color: AppColor.purpleCCC2FF,
                          fontSize: 14.sp,
                        ),
                      ),

                      SizedBox(height: 12.h),

                      // RANK BADGE
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 14.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              rankColor.withOpacity(0.35),
                              rankColor.withOpacity(0.15),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(30.r),
                          border: Border.all(color: rankColor, width: 1.4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SvgPicture.asset(
                              rankSvg,
                              width: 20.w,
                              height: 20.h,
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              "$rankName • Level $rankLevel",
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.bold,
                                color: rankColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 20.h),

                // STATS BOX
                Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 12.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColor.customPurple,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildSingleStat(
                          profile.weightKg?.toStringAsFixed(1) ?? '--',
                          "Weight",
                          suffix: " Kg",
                        ),
                        _buildVerticalDivider(),
                        _buildSingleStat("${controller.effectiveAge}", "Years Old"),
                        _buildVerticalDivider(),
                        _buildSingleStat(
                          profile.heightCm?.toStringAsFixed(1) ?? '--',
                          "Height",
                          suffix: " CM",
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 30.h),

                // MENU ITEMS
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      _buildMenuItem(
                        ImageAssets.svg71,
                        "Subscription",
                        () => Get.to(
                          () => Subscription(),
                          transition: Transition.rightToLeft,
                        ),
                      ),

                      _buildMenuItem(
                        ImageAssets.svg24,
                        "Profile",
                        () => Get.to(
                          () => MyProfileEditScreen(),
                          transition: Transition.rightToLeft,
                        ),
                      ),
                      _buildMenuItem(
                        Icons.sports_rounded,
                        "Change Coach",
                        () => Get.to(
                          () => CoachPage(isFromSettings: true),
                          transition: Transition.rightToLeft,
                        ),
                      ),
                      _buildMenuItem(
                        ImageAssets.svg25,
                        "Favorite",
                        () => Get.to(
                          () => Favourite(),
                          transition: Transition.rightToLeft,
                        ),
                      ),
                      _buildMenuItem(
                        ImageAssets.svg26,
                        "Privacy Policy",
                        () => Get.to(
                          () => PrivacyPolicyScreen(),
                          transition: Transition.rightToLeft,
                        ),
                      ),
                      _buildMenuItem(
                        ImageAssets.svg27,
                        "Settings",
                        () => Get.to(
                          () => const SettingsScreen(),
                          transition: Transition.rightToLeft,
                        ),
                      ),
                      _buildMenuItem(
                        ImageAssets.svg28,
                        "Help",
                        () => Get.to(
                          () => const HelpAndFaqsPage(),
                          transition: Transition.rightToLeft,
                        ),
                      ),
                      _buildMenuItem(
                        ImageAssets.svg29,
                        "Logout",
                        () => _showLogoutBottomSheet(context),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  // Updated stat with optional suffix
  Widget _buildSingleStat(String value, String label, {String suffix = ""}) {
    return Column(
      children: [
        Text(
          "$value$suffix",
          style: AppTextStyles.poppinsSemiBold.copyWith(
            color: Colors.white,
            fontSize: 14.sp,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: AppTextStyles.poppinsRegular.copyWith(
            color: Colors.white,
            fontSize: 12.sp,
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      width: 1.w,
      height: 40.h,
      color: Colors.white.withOpacity(0.3),
      margin: EdgeInsets.symmetric(horizontal: 12.w),
    );
  }

  Widget _buildMenuItem(dynamic iconOrSvg, String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 6.h),
        child: Row(
          children: [
            if (iconOrSvg is IconData)
              SizedBox(
                width: 30.sp,
                height: 35.sp,
                child: Center(
                  child: Icon(
                    iconOrSvg,
                    color: AppColor.customPurple,
                    size: 24.sp,
                  ),
                ),
              )
            else
              SvgPicture.asset(iconOrSvg as String, height: 35.sp, width: 30.sp),
            SizedBox(width: 16.w),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.poppinsRegular.copyWith(
                  color: Colors.white,
                  fontSize: 16.sp,
                ),
              ),
            ),
            SvgPicture.asset(ImageAssets.svg23, height: 10.h),
          ],
        ),
      ),
    );
  }

  void _showLogoutBottomSheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.symmetric(vertical: 25.h, horizontal: 20.w),
        decoration: BoxDecoration(
          color: AppColor.black111214,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25.r),
            topRight: Radius.circular(25.r),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(ImageAssets.svg29, height: 45.sp, width: 45.sp),
            SizedBox(height: 15.h),
            Text(
              "Logout?",
              style: AppTextStyles.poppinsSemiBold.copyWith(
                fontSize: 18.sp,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              "Are you sure you want to log out from your account?",
              textAlign: TextAlign.center,
              style: AppTextStyles.poppinsRegular.copyWith(
                fontSize: 14.sp,
                color: Colors.white70,
              ),
            ),
            SizedBox(height: 25.h),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      height: 45.h,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColor.white30,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        "Cancel",
                        style: AppTextStyles.poppinsMedium.copyWith(
                          color: Colors.white,
                          fontSize: 15.sp,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Get.find<Authcontroller>().logout();
                      Get.back();
                      Get.offAll(
                        () => Login(),
                        transition: Transition.rightToLeft,
                      );
                      toastification.show(
                        type: ToastificationType.info,
                        style: ToastificationStyle.fillColored,
                        primaryColor: AppColor.green16A34A,
                        foregroundColor: Colors.white,
                        title: Text(
                          "Logged Out",
                          style: AppTextStyles.poppinsBold.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        description: Text(
                          "You have been logged out successfully.",
                          style: AppTextStyles.poppinsRegular.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        alignment: Alignment.topRight,
                        autoCloseDuration: const Duration(seconds: 4),
                        borderRadius: BorderRadius.circular(12),
                        showProgressBar: true,
                      );
                    },
                    child: Container(
                      height: 45.h,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        "Logout",
                        style: AppTextStyles.poppinsMedium.copyWith(
                          color: Colors.white,
                          fontSize: 15.sp,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: true,
    );
  }

  String _formatBirthday(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      final day = date.day;
      final suffix = day >= 11 && day <= 13
          ? 'th'
          : {1: 'st', 2: 'nd', 3: 'rd'}[day % 10] ?? 'th';
      return "${DateFormat('MMMM').format(date)} $day$suffix";
    } catch (e) {
      return isoDate;
    }
  }
}
