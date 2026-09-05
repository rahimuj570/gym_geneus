// lib/app/modules/setup/controllers/schedule_controller.dart

import 'package:flutter/cupertino.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class ScheduleController extends GetxController {
  final RxSet<int> selectedDayIds = <int>{}.obs;

  var selectedHour = 7.obs;
  var selectedMinute = 30.obs;
  var selectedAmPm = 'AM'.obs;

  final List<String> dayNames = ['S', 'M', 'T', 'W', 'Th', 'F', 'Sa'];
  final hours = List.generate(12, (i) => i + 1);
  final minutes = List.generate(60, (i) => i); // ← fixed: was 0
  final amPmOptions = ['AM', 'PM'];

  late FixedExtentScrollController hourController;
  late FixedExtentScrollController minuteController;
  late FixedExtentScrollController amPmController;

  @override
  void onInit() {
    super.onInit();
    hourController = FixedExtentScrollController(initialItem: 6);
    minuteController = FixedExtentScrollController(initialItem: 30);
    amPmController = FixedExtentScrollController(initialItem: 0);
  }

  void toggleDay(int dayIndex) {
    selectedDayIds.contains(dayIndex)
        ? selectedDayIds.remove(dayIndex)
        : selectedDayIds.add(dayIndex);
  }

  bool isDaySelected(int index) => selectedDayIds.contains(index);

  void updateHour(int hour) => selectedHour.value = hour;
  void updateMinute(int minute) => selectedMinute.value = minute;
  void updateAmPm(String amPm) => selectedAmPm.value = amPm;

  // FIXED: Backend wants "HH:MM" (24-hour format), NOT ISO string
  String get preferredWorkoutTime {
    final hour24 = selectedAmPm.value == 'AM'
        ? (selectedHour.value == 12 ? 0 : selectedHour.value)
        : (selectedHour.value == 12 ? 12 : selectedHour.value + 12);

    return "${hour24.toString().padLeft(2, '0')}:${selectedMinute.value.toString().padLeft(2, '0')}";
  }

  // FIXED: Send 1-based IDs (1..7) for database compatibility
  List<int> get preferredWorkoutDayIds =>
      selectedDayIds.map((id) => id + 1).toList()..sort();

  bool get canContinue => selectedDayIds.isNotEmpty;

  @override
  void onClose() {
    hourController.dispose();
    minuteController.dispose();
    amPmController.dispose();
    super.onClose();
  }
}
