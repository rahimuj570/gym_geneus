import 'dart:async';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:kenzeno/app/constants/tester_track_config.dart';
import 'package:kenzeno/app/modules/home/views/navbar.dart';
import 'package:kenzeno/app/modules/onboard/views/onboard1.dart';
import 'package:kenzeno/app/modules/setup/views/setup.dart';
import 'package:kenzeno/app/modules/setting/service/setting_service.dart';
import 'package:tester_track/tester_track.dart';

class OnboardController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    startTimer();
  }

  void startTimer() {
    Timer(const Duration(seconds: 3), routeUser);
  }

  Future<void> routeUser() async {
    final token = GetStorage().read<String>('loginToken');
    if (token != null && token.isNotEmpty) {
      final profile = await SettingService().fetchProfile();
      try {
        if (profile.hasMissingProfileFields) {
          Get.offAll(() => Setup(), transition: Transition.rightToLeft);
          return;
        }
      } catch (e) {
        print("Error checking profile on startup: $e");
      }
      await TesterTrack.initialize(
        firebaseOptions: testerTrackOptions,
        testerId: profile.email,
      );
      Get.offAll(() => Navbar(), transition: Transition.rightToLeft);
    } else {
      Get.off(() => Onboard1(), transition: Transition.rightToLeft);
    }
  }
}
