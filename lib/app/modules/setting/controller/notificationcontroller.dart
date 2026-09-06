import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toastification/toastification.dart';
import '../../../res/fonts/textstyle.dart';
import '../service/setting_service.dart';

class NotificationsController extends GetxController {
  final SettingService _service = SettingService();

  var isLoading = false.obs;

  // Observables for managing the state of the switches
  var generalNotification = true.obs;
  var sound = true.obs;
  var doNotDisturbMode = false.obs;
  var vibrate = true.obs;
  var lockScreen = true.obs;
  var reminders = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchNotificationSettings();
  }

  Future<void> fetchNotificationSettings() async {
    try {
      isLoading(true);
      final settings = await _service.fetchNotificationSettings();
      generalNotification.value = settings.generalNotifications;
      sound.value = settings.sound;
      doNotDisturbMode.value = settings.doNotDisturb;
      vibrate.value = settings.vibrate;
      lockScreen.value = settings.lockScreen;
    } catch (e) {
      debugPrint("Error fetching notification settings: $e");
    } finally {
      isLoading(false);
    }
  }

  Future<void> _updateSetting({
    bool? generalNotifications,
    bool? soundVal,
    bool? doNotDisturbVal,
    bool? vibrateVal,
    bool? lockScreenVal,
  }) async {
    try {
      final updated = await _service.updateNotificationSettings(
        generalNotifications: generalNotifications,
        sound: soundVal,
        doNotDisturb: doNotDisturbVal,
        vibrate: vibrateVal,
        lockScreen: lockScreenVal,
      );
      generalNotification.value = updated.generalNotifications;
      sound.value = updated.sound;
      doNotDisturbMode.value = updated.doNotDisturb;
      vibrate.value = updated.vibrate;
      lockScreen.value = updated.lockScreen;
    } catch (e) {
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
          "Failed to update notification setting",
          style: AppTextStyles.poppinsRegular.copyWith(color: Colors.white),
        ),
        alignment: Alignment.topRight,
        autoCloseDuration: const Duration(seconds: 3),
        borderRadius: BorderRadius.circular(12),
        showProgressBar: true,
      );
      // Re-fetch to ensure UI sync
      fetchNotificationSettings();
    }
  }

  // Toggle methods with optimistic UI and background API sync
  void toggleGeneralNotification(bool value) {
    generalNotification.value = value;
    _updateSetting(generalNotifications: value);
  }

  void toggleSound(bool value) {
    sound.value = value;
    _updateSetting(soundVal: value);
  }

  void toggleDoNotDisturbMode(bool value) {
    doNotDisturbMode.value = value;
    _updateSetting(doNotDisturbVal: value);
  }

  void toggleVibrate(bool value) {
    vibrate.value = value;
    _updateSetting(vibrateVal: value);
  }

  void toggleLockScreen(bool value) {
    lockScreen.value = value;
    _updateSetting(lockScreenVal: value);
  }

  void toggleReminders(bool value) {
    reminders.value = value;
  }
}
