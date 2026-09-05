import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:kenzeno/app/modules/setting/views/notificationsettings.dart';
import 'package:kenzeno/app/modules/setting/views/passwordsettting.dart';
import 'package:kenzeno/app/widgets/backbutton_widget.dart';
import '../../../res/colors/colors.dart';
import '../../../res/fonts/textstyle.dart';
import '../../../res/assets/asset.dart';
import 'package:toastification/toastification.dart';
import 'package:kenzeno/app/res/fonts/textstyle.dart';
import 'package:kenzeno/app/res/colors/colors.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.black111214,
      appBar: AppBar(
        backgroundColor: AppColor.black111214,
        leading: const BackButtonBox(),
        title: Text(
          "Settings",
          style: AppTextStyles.poppinsSemiBold.copyWith(
            fontSize: 20.sp,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 20.w),
        child: Column(
          children: [
            SizedBox(height: 30.h),
            _buildSettingTile(
              context,
              title: "Notification Setting",
              svgPath: ImageAssets.svg35,
              onTap: () {
                Get.to(
                  NotificationsSettingsScreen(),
                  transition: Transition.rightToLeft,
                );
              },
            ),
            SizedBox(height: 10.h),
            _buildSettingTile(
              context,
              title: "Password Setting",
              svgPath: ImageAssets.svg36,
              onTap: () {
                Get.to(
                  PasswordSettingsScreen(),
                  transition: Transition.rightToLeft,
                );
              },
            ),
            SizedBox(height: 10.h),
            _buildSettingTile(
              context,
              title: "Delete Account",
              svgPath: ImageAssets.svg37,
              onTap: () {
                _showDeleteBottomSheet(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  // -----------------------------
  // 🔹 Setting Tile Widget
  // -----------------------------
  Widget _buildSettingTile(
    BuildContext context, {
    required String title,
    required String svgPath,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40.h,
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(15.r)),
        child: Row(
          children: [
            // Icon
            Center(
              child: SvgPicture.asset(svgPath, height: 30.sp, width: 30.sp),
            ),
            SizedBox(width: 20.w),
            // Title
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.poppinsRegular.copyWith(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            // Arrow
            SvgPicture.asset(ImageAssets.svg23, height: 15.sp, width: 15.sp),
          ],
        ),
      ),
    );
  }

  // -----------------------------
  // 🔻 Bottom Sheet Confirmation
  // -----------------------------
  void _showDeleteBottomSheet(BuildContext context) {
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
            SvgPicture.asset(ImageAssets.svg37, height: 45.sp, width: 45.sp),
            SizedBox(height: 15.h),
            Text(
              "Delete Account?",
              style: AppTextStyles.poppinsSemiBold.copyWith(
                fontSize: 18.sp,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              "Are you sure you want to permanently delete your account?",
              textAlign: TextAlign.center,
              style: AppTextStyles.poppinsRegular.copyWith(
                fontSize: 14.sp,
                color: Colors.white70,
              ),
            ),
            SizedBox(height: 25.h),
            Row(
              children: [
                // Cancel button
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
                // Delete button
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Get.back();
                      // TODO: Implement delete account API or logic here
                      toastification.show(
                        type: ToastificationType.info,
                        style: ToastificationStyle.fillColored,
                        primaryColor: AppColor.green16A34A,
                        foregroundColor: Colors.white,
                        title: Text(
                          "Account Deleted",
                          style: AppTextStyles.poppinsBold.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        description: Text(
                          "Your account has been deleted successfully.",
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
                        "Delete",
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
      enableDrag: true, // Allows swipe down to dismiss
    );
  }
}
