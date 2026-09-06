import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../res/colors/colors.dart';
import '../../../res/fonts/textstyle.dart';
import '../../../widgets/backbutton_widget.dart';
import '../controller/notificationcontroller.dart';

class NotificationsSettingsScreen extends StatelessWidget {
  final NotificationsController controller =
      Get.isRegistered<NotificationsController>()
      ? Get.find<NotificationsController>()
      : Get.put(NotificationsController());

  NotificationsSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.black111214,
      appBar: AppBar(
        backgroundColor: AppColor.black111214,
        leading: const BackButtonBox(),
        title: Text(
          "Notifications Settings",
          style: AppTextStyles.poppinsSemiBold.copyWith(
            fontSize: 20.sp,
            color: Colors.white,
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColor.customPurple),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.fetchNotificationSettings,
          color: AppColor.customPurple,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
            child: Column(
              children: [
                // General Notification
                Obx(
                  () => _buildSwitchTile(
                    title: "General Notification",
                    value: controller.generalNotification.value,
                    onChanged: controller.toggleGeneralNotification,
                  ),
                ),

                // Sound
                Obx(
                  () => _buildSwitchTile(
                    title: "Sound",
                    value: controller.sound.value,
                    onChanged: controller.toggleSound,
                  ),
                ),

                // Don't Disturb Mode
                Obx(
                  () => _buildSwitchTile(
                    title: "Don't Disturb Mode",
                    value: controller.doNotDisturbMode.value,
                    onChanged: controller.toggleDoNotDisturbMode,
                  ),
                ),

                // Vibrate
                Obx(
                  () => _buildSwitchTile(
                    title: "Vibrate",
                    value: controller.vibrate.value,
                    onChanged: controller.toggleVibrate,
                  ),
                ),

                // Lock Screen
                Obx(
                  () => _buildSwitchTile(
                    title: "Lock Screen",
                    value: controller.lockScreen.value,
                    onChanged: controller.toggleLockScreen,
                  ),
                ),

                // Reminders
                // Obx(
                //   () => _buildSwitchTile(
                //     title: "Reminders",
                //     value: controller.reminders.value,
                //     onChanged: controller.toggleReminders,
                //   ),
                // ),
              ],
            ),
          ),
        );
      }),
    );
  }

  // Custom widget for each setting item using SwitchListTile logic
  Widget _buildSwitchTile({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 10.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: AppTextStyles.poppinsRegular.copyWith(
              color: Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColor.white,
            activeTrackColor: AppColor.customPurple,
            inactiveThumbColor: AppColor.white,
            inactiveTrackColor: AppColor.gray9CA3AF.withOpacity(0.3),
            trackOutlineColor: MaterialStateProperty.all(Colors.transparent),
          ),
        ],
      ),
    );
  }
}
