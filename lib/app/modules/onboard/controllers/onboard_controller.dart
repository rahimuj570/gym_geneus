import 'dart:async';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:kenzeno/app/modules/home/views/navbar.dart';
import 'package:kenzeno/app/modules/onboard/views/onboard1.dart';
import 'package:kenzeno/app/modules/setup/views/setup.dart';
import 'package:kenzeno/app/modules/setting/service/setting_service.dart';

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
      try {
        final profile = await SettingService().fetchProfile();
        if (profile.hasMissingProfileFields) {
          Get.offAll(() => Setup(), transition: Transition.rightToLeft);
          return;
        }
      } catch (e) {
        print("Error checking profile on startup: $e");
      }
      Get.offAll(() => Navbar(), transition: Transition.rightToLeft);
    } else {
      Get.off(() => Onboard1(), transition: Transition.rightToLeft);
    }
  }
}
