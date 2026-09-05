import 'dart:async';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:kenzeno/app/modules/home/views/navbar.dart';
import 'package:kenzeno/app/modules/onboard/views/onboard1.dart';

class OnboardController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    startTimer();
  }

  void startTimer() {
    Timer(const Duration(seconds: 5), routeUser);
  }

  void routeUser() {
    final token = GetStorage().read<String>('loginToken');
    if (token != null && token.isNotEmpty) {
      Get.offAll(Navbar(), transition: Transition.rightToLeft);
    } else {
      Get.off(() => Onboard1(), transition: Transition.rightToLeft);
    }
  }
}
