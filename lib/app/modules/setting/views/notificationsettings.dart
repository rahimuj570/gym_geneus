import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../../res/colors/colors.dart';
import '../../../res/fonts/textstyle.dart';
import '../../../widgets/backbutton_widget.dart';
import '../controller/notificationcontroller.dart';

class NotificationsSettingsScreen extends StatelessWidget {
  // Initialize the controller
  final NotificationsController controller = Get.put(NotificationsController());

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
      body: SingleChildScrollView(
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
            Obx(
              () => _buildSwitchTile(
                title: "Reminders",
                value: controller.reminders.value,
                onChanged: controller.toggleReminders,
              ),
            ),
          ],
        ),
      ),
      // Assuming a bottom navigation bar is present based on the image
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
