import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class NotificationsController extends GetxController {
  // Observables for managing the state of the switches
  var generalNotification = true.obs;
  var sound = true.obs;
  var doNotDisturbMode = false.obs;
  var vibrate = true.obs;
  var lockScreen = true.obs;
  var reminders = false.obs;

  // Toggle methods
  void toggleGeneralNotification(bool value) =>
      generalNotification.value = value;
  void toggleSound(bool value) => sound.value = value;
  void toggleDoNotDisturbMode(bool value) => doNotDisturbMode.value = value;
  void toggleVibrate(bool value) => vibrate.value = value;
  void toggleLockScreen(bool value) => lockScreen.value = value;
  void toggleReminders(bool value) => reminders.value = value;
}
