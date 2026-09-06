import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kenzeno/app/constants/push_notification.dart';
import 'package:kenzeno/app/modules/auth/views/login.dart';
import 'package:kenzeno/app/modules/setting/service/setting_service.dart';
import 'package:kenzeno/app/modules/setting/views/notificationsettings.dart';
import 'package:kenzeno/app/modules/setting/views/passwordsettting.dart';
import 'package:kenzeno/app/widgets/backbutton_widget.dart';
import '../../../res/colors/colors.dart';
import '../../../res/fonts/textstyle.dart';
import '../../../res/assets/asset.dart';
import 'package:toastification/toastification.dart';

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
    bool isDeleting = false;

    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
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
                        onTap: isDeleting ? null : () => Get.back(),
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
                        onTap: isDeleting
                            ? null
                            : () async {
                                setModalState(() {
                                  isDeleting = true;
                                });
                                try {
                                  await SettingService().deleteAccount();

                                  // Cleanup FCM & Google sign in if active
                                  try {
                                    await unregisterFCM().timeout(
                                      const Duration(seconds: 3),
                                    );
                                  } catch (_) {}

                                  try {
                                    await GoogleSignIn().signOut();
                                  } catch (_) {}

                                  // Clear storage tokens
                                  final box = GetStorage();
                                  box.remove('loginToken');
                                  box.remove('refreshToken');
                                  box.remove('actionToken');
                                  box.remove('email');
                                  box.remove('password');

                                  Get.back(); // Close bottom sheet

                                  toastification.show(
                                    type: ToastificationType.success,
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

                                  Get.offAll(
                                    () => Login(),
                                    transition: Transition.rightToLeft,
                                  );
                                } catch (e) {
                                  setModalState(() {
                                    isDeleting = false;
                                  });
                                  toastification.show(
                                    type: ToastificationType.error,
                                    style: ToastificationStyle.fillColored,
                                    primaryColor: Colors.red,
                                    foregroundColor: Colors.white,
                                    title: Text(
                                      "Delete Account Failed",
                                      style: AppTextStyles.poppinsBold.copyWith(
                                        color: Colors.white,
                                      ),
                                    ),
                                    description: Text(
                                      e.toString().replaceAll("Exception: ", ""),
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
                        child: Container(
                          height: 45.h,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: isDeleting
                              ? SizedBox(
                                  height: 20.h,
                                  width: 20.h,
                                  child: const CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
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
          );
        },
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: true,
    );
  }
}
