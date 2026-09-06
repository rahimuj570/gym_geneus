// lib/app/modules/setup/views/height_input_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:kenzeno/app/modules/setup/views/schedule.dart';
import '../controllers/setup_controller.dart';
import '../../../res/assets/asset.dart';
import '../../../res/colors/colors.dart';
import '../../../res/fonts/textstyle.dart';
import '../../../widgets/backbutton_widget.dart';
import '../../../widgets/custom_button.dart';
import '../widgets/heightpicker.dart';

class HeightInputPage extends StatelessWidget {
  HeightInputPage({Key? key}) : super(key: key);

  final SetupController controller = Get.find<SetupController>();

  late final VerticalScrollController scrollController =
      VerticalScrollController(
    topValue: 250,
    bottomValue: 100,
    height: 300,
    itemGap: 20,
    initialValue: controller.height.value > 0 ? controller.height.value : 175,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: const BackButtonBox(),
        backgroundColor: Colors.transparent,
      ),
      extendBodyBehindAppBar: true,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            children: [
              SizedBox(height: 10.h),
              Text(
                "What Is Your Height?",
                textAlign: TextAlign.center,
                style: AppTextStyles.poppinsBold.copyWith(
                  fontSize: 25.sp,
                  color: AppColor.white,
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                "We’ll get into the deep and meaningful later.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColor.white.withOpacity(0.7),
                  fontSize: 12.sp,
                ),
              ),

              SizedBox(height: 15.h),

              // Unit Toggle
              _buildUnitToggle(),

              SizedBox(height: 20.h),

              // Big Height Display
              Obx(() {
                final display = controller.heightUnit.value == 'feet'
                    ? "${controller.heightInFeetInches.value} ft"
                    : "${controller.height.value.toStringAsFixed(0)} cm";

                return Text(
                  display,
                  style: AppTextStyles.poppinsBold.copyWith(
                    fontSize: 50.sp,
                    color: AppColor.white,
                    height: 1.0,
                  ),
                );
              }),

              SizedBox(height: 40.h),

              // Picker + Male/Female Image
              Expanded(
                child: Row(
                  children: [
                    // Scroll Picker
                    Expanded(
                      flex: 5,
                      child: Obx(
                        () => VerticalScrollPicker(
                          nKey: ValueKey('height_picker_${controller.heightUnit.value}'),
                          controller: scrollController,
                          height: 0.6.sh,
                          width: double.infinity,
                          bottomValue: scrollController.bottomValue,
                          topValue: scrollController.topValue,
                          interval: () => 5.0,
                          lineGap: 20,
                          style: VerticalScrollPickerStyle(
                            backgroundItemColor: AppColor.white.withOpacity(0.3),
                            foregroundItemColor: AppColor.customPurple,
                          ),
                          onChanged: (value) => controller.setHeight(value),
                          onPickedValueFormat: (value) {
                            if (controller.heightUnit.value == 'feet') {
                              final inches = value / 2.54;
                              final feet = inches ~/ 12;
                              final rem = (inches % 12).round();
                              return "$feet'$rem\"";
                            }
                            return "${value.toStringAsFixed(0)} cm";
                          },
                          onScaleValueFormat: (value) {
                            if (controller.heightUnit.value == 'feet') {
                              final inches = value / 2.54;
                              final feet = inches ~/ 12;
                              final rem = (inches % 12).round();
                              return "$feet'$rem\"";
                            }
                            return "${value.toInt()} cm";
                          },
                        ),
                      ),
                    ),

                    SizedBox(width: 20.w),

                    // Male / Female SVG
                    Expanded(
                      flex: 4,
                      child: Obx(
                        () => SvgPicture.asset(
                          controller.selectedGender.value == 'male'
                              ? ImageAssets
                                    .svg69 // Male SVG
                              : ImageAssets.svg70, // Female SVG
                          fit: BoxFit.contain,
                          color: AppColor.customPurple,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 30.h),

              // Continue Button
              Obx(
                () => CustomButton(
                  onPress: controller.hasScrolledHeight.value
                      ? () async {
                          Get.to(
                            () => ChooseSchedulePage(),
                            transition: Transition.rightToLeft,
                          );
                          print(controller.height.value);
                        }
                      : null,
                  title: "Continue",
                  fontSize: 16.sp,
                  height: 45.h,
                  svgorimage: true,
                  trailing: ImageAssets.svg3,
                  fontWeight: FontWeight.w700,
                  textColor: AppColor.white,
                  buttonColor: controller.hasScrolledHeight.value
                      ? AppColor.customPurple
                      : AppColor.white15,
                  borderColor: AppColor.white15,
                  radius: 30.r,
                ),
              ),

              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUnitToggle() {
    return Obx(() {
      final isCm = controller.heightUnit.value == 'cm';
      return Container(
        height: 50.h,
        padding: EdgeInsets.all(5.w),
        decoration: BoxDecoration(
          color: AppColor.gray1F2937,
          borderRadius: BorderRadius.circular(30.r),
        ),
        child: Row(
          children: [
            Expanded(
              child: _unitButton('Centimeters', isCm, () {
                controller.heightUnit.value = 'cm';
                scrollController.refresh();
              }),
            ),
            Expanded(
              child: _unitButton('Feet', !isCm, () {
                controller.heightUnit.value = 'feet';
                controller.updateFeetInchesDisplay();
                scrollController.refresh();
              }),
            ),
          ],
        ),
      );
    });
  }

  Widget _unitButton(String text, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: 200.milliseconds,
        decoration: BoxDecoration(
          color: isActive ? AppColor.customPurple : Colors.transparent,
          borderRadius: BorderRadius.circular(25.r),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: AppTextStyles.poppinsSemiBold.copyWith(
            color: isActive ? Colors.white : AppColor.white.withOpacity(0.6),
            fontSize: 14.sp,
          ),
        ),
      ),
    );
  }
}
