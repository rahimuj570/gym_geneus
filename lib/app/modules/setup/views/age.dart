import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:kenzeno/app/modules/setup/views/weight.dart';

import '../../../res/assets/asset.dart';
import '../../../res/colors/colors.dart';
import '../../../res/fonts/textstyle.dart';

import '../../../widgets/backbutton_widget.dart';
import '../../../widgets/custom_button.dart';
import '../controllers/setup_controller.dart';
import 'package:kenzeno/app/widgets/custom_snackbar.dart';

class AgeSelectionPage extends StatelessWidget {
  AgeSelectionPage({Key? key}) : super(key: key);

  final SetupController controller = Get.find<SetupController>();
  final FixedExtentScrollController _scrollController =
      FixedExtentScrollController();
  final int minAge = 16;
  final int maxAge = 100;

  @override
  Widget build(BuildContext context) {
    final RxBool hasScrolled = false.obs;

    // Initialize selected age and scroll position
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final age = controller.selectedAge.value > 0
          ? controller.selectedAge.value
          : 18;
      if (controller.selectedAge.value == 0) {
        controller.selectedAge.value = 18;
      }

      final initialIndex = age - minAge;
      _scrollController.jumpToItem(initialIndex);
    });

    return Scaffold(
      backgroundColor: AppColor.black111214,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButtonBox(),
      ),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 20.h),
            Text(
              'What is your age?',
              style: AppTextStyles.workSansSemiBold.copyWith(
                fontSize: 30.sp,
                color: AppColor.white,
              ),
            ),

            SizedBox(height: 20.h),

            // Age Picker
            Expanded(
              child: Stack(
                children: [
                  Center(
                    child: Container(
                      height: 80.h,
                      width: 200.w,
                      decoration: BoxDecoration(
                        color: AppColor.customPurple,
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: AppColor.purpleCCC2FF,
                          width: 3.w,
                        ),
                      ),
                    ),
                  ),

                  // Scrollable age wheel
                  NotificationListener<ScrollNotification>(
                    onNotification: (notification) {
                      if (notification is ScrollUpdateNotification ||
                          notification is ScrollEndNotification) {
                        hasScrolled.value = true;
                      }
                      return true;
                    },
                    child: Obx(() {
                      final selectedAge = controller.selectedAge.value;

                      return ListWheelScrollView.useDelegate(
                        controller: _scrollController,
                        itemExtent: 60.h,
                        diameterRatio: 1.9,
                        physics: const FixedExtentScrollPhysics(),
                        onSelectedItemChanged: (index) {
                          final newAge = minAge + index;
                          if (newAge >= minAge && newAge <= maxAge) {
                            controller.selectedAge.value = newAge;
                            hasScrolled.value = true;
                          }
                        },
                        childDelegate: ListWheelChildBuilderDelegate(
                          childCount: maxAge - minAge + 1,
                          builder: (context, index) {
                            final age = minAge + index;
                            final isSelected = age == selectedAge;
                            final distance = (age - selectedAge).abs();
                            final opacity = distance == 0
                                ? 1.0
                                : distance == 1
                                ? 0.5
                                : 0.3;

                            return GestureDetector(
                              onTap: () {
                                controller.selectedAge.value = age;
                                hasScrolled.value = true;
                                _scrollController.animateToItem(
                                  index,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              },
                              child: Container(
                                height: 60.h,
                                alignment: Alignment.center,
                                child: AnimatedOpacity(
                                  duration: const Duration(milliseconds: 150),
                                  opacity: opacity,
                                  child: Text(
                                    '$age',
                                    style: AppTextStyles.workSansBold.copyWith(
                                      fontSize: isSelected ? 50.sp : 30.sp,
                                      fontWeight: isSelected
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                      color: AppColor.white,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),

            // Continue Button
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
              child: CustomButton(
                onPress: () async {
                  if (controller.selectedAge.value <= 0) {
                    CustomSnackbar.showWarning(
                      'Please select your age to continue',
                      title: 'Selection Required',
                    );
                    return;
                  }
                  print(controller.selectedAge.value);
                  Get.to(
                    WeightInputPage(),
                    transition: Transition.rightToLeft,
                  );
                },
                title: "Continue",
                fontSize: 16.sp,
                height: 45.h,
                svgorimage: true,
                trailing: ImageAssets.svg3,
                fontFamily: 'WorkSans',
                radius: 20.r,

                fontWeight: FontWeight.bold,
                textColor: AppColor.white,
                borderColor: AppColor.customPurple,
                buttonColor: AppColor.white15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
