// lib/pages/weight_input_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

// Assuming your actual import path for the controller
// You should use the correct path relative to your project structure
import 'package:kenzeno/app/modules/setup/controllers/setup_controller.dart';
import 'package:kenzeno/app/modules/setup/views/height.dart';

// Assuming these imports lead to your provided files
import '../../../res/assets/asset.dart';
import '../../../res/colors/colors.dart';
import '../../../res/fonts/textstyle.dart'; // Renamed AppTextStyles to textstyle.dart
import '../../../widgets/backbutton_widget.dart'; // Renamed BackButtonBox to backbutton_widget.dart
import '../../../widgets/custom_button.dart';

class WeightInputPage extends StatelessWidget {
  WeightInputPage({Key? key}) : super(key: key);

  // ⭐️ CRITICAL FIX: Ensure the controller is available (Get.find() is correct)
  final SetupController controller = Get.find<SetupController>();

  // Define the range for the weight selector (e.g., 40 to 200)
  final double minWeight = 40;
  final double maxWeight = 200;

  late final int itemCount = (maxWeight - minWeight).toInt() * 10;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: BackButtonBox()),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: IntrinsicHeight(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 30.h),

              // 'What is your weight?' text
              Center(
                child: Text(
                  'What is your weight?',
                  style: AppTextStyles.poppinsBold.copyWith(
                    fontSize: 28.sp,
                    color: AppColor.white,
                  ),
                ),
              ),

              SizedBox(height: 40.h),

              _buildUnitToggle(),

              SizedBox(height: 60.h),

              _buildWeightSelector(context),

              SizedBox(height: 100),

              // Continue Button
              Obx(
                () => CustomButton(
                  onPress: controller.hasScrolledWeight.value
                      ? () async {
                          Get.to(
                            HeightInputPage(),
                            transition: Transition.rightToLeft,
                          );
                          print(
                            'Weight selected: ${controller.weight.value} ${controller.weightUnit.value}',
                          );
                        }
                      : null,
                  title: "Continue",
                  fontSize: 16.sp,
                  height: 45.h,
                  svgorimage: true,
                  trailing: ImageAssets.svg3,
                  fontFamily: 'WorkSans',
                  radius: 20.r,
                  fontWeight: FontWeight.bold,
                  textColor: AppColor.white,
                  // ⭐️ CONTROLLER FIX: Use hasScrolledWeight to change border color
                  borderColor: controller.hasScrolledWeight.value
                      ? AppColor.customPurple
                      : AppColor.white15,
                  buttonColor: AppColor.white15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUnitToggle() {
    return Obx(() {
      // ⭐️ CONTROLLER FIX: Use weightUnit
      final isKg = controller.weightUnit.value == 'kg';
      return Container(
        height: 40.h,
        padding: EdgeInsets.all(5.w),
        decoration: BoxDecoration(
          color: AppColor.white9,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // KG Button
            // ⭐️ CONTROLLER FIX: Use toggleWeightUnit
            Expanded(
              child: _unitButton(
                'kg',
                isKg,
                () => controller.toggleWeightUnit(),
              ),
            ),
            // LBS Button
            // ⭐️ CONTROLLER FIX: Use toggleWeightUnit
            Expanded(
              child: _unitButton(
                'lbs',
                !isKg,
                () => controller.toggleWeightUnit(),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _unitButton(String unit, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        decoration: BoxDecoration(
          color: isSelected ? AppColor.customPurple : Colors.transparent,
          borderRadius: BorderRadius.circular(20.r),
        ),
        alignment: Alignment.center,
        // ⭐️ Assuming AppTextStyles is the class name
        child: Text(
          unit.toUpperCase(),
          style: AppTextStyles.workSansMedium.copyWith(
            color: isSelected ? AppColor.white : AppColor.white30,
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildWeightSelector(BuildContext context) {
    int initialPage = ((controller.weight.value - minWeight) * 10).toInt();

    final double rulerWidth = MediaQuery.of(context).size.width - (20.w * 2);

    const double tickPixelWidth = 20;

    return Column(
      children: [
        // Current Weight Display
        Obx(
          () => Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                // ⭐️ CONTROLLER FIX: Use controller.weight
                controller.weight.value.toStringAsFixed(0),
                // ⭐️ Assuming AppTextStyles is the class name
                style: AppTextStyles.workSansBold.copyWith(
                  fontSize: 60.sp,
                  color: AppColor.white,
                  height: 1.0,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 10.w, bottom: 5.h),
                child: Text(
                  // ⭐️ CONTROLLER FIX: Use controller.weightUnit
                  controller.weightUnit.value,
                  // ⭐️ Assuming AppTextStyles is the class name
                  style: AppTextStyles.workSansSemiBold.copyWith(
                    fontSize: 40.sp,
                    color: AppColor.white,
                    height: 1.0,
                  ),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 60.h),

        // Ruler and Indicator Stack
        SizedBox(
          height: 120.h,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Ruler (PageView)
              NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  if (notification is ScrollUpdateNotification) {
                    // ⭐️ CONTROLLER FIX: Use hasScrolledWeight
                    controller.hasScrolledWeight.value = true;
                  }
                  return false;
                },
                child: SizedBox(
                  height: 30.h,
                  child: PageView.builder(
                    controller: PageController(
                      // FIX: viewportFraction not changed as requested
                      viewportFraction: (tickPixelWidth * 0.6.w) / rulerWidth,
                      initialPage: initialPage,
                    ),
                    itemCount: itemCount,
                    onPageChanged: (index) {
                      double newWeight = minWeight + (index / 10);
                      // ⭐️ CONTROLLER FIX: Use setWeight
                      controller.setWeight(newWeight);
                    },
                    physics: const BouncingScrollPhysics(),
                    // Ruler Ticks
                    itemBuilder: (context, index) {
                      final isMajor = index % 10 == 0;
                      final isMinor = index % 5 == 0;

                      // The logic for heights is swapped here:
                      // isMajor now gets 25.h (was 40.h)
                      // isMinor now gets 40.h (was 25.h)
                      double tickHeight;
                      if (isMajor) {
                        tickHeight =
                            25.h; // SWAPPED: Major tick is now medium (25.h)
                      } else if (isMinor) {
                        tickHeight =
                            40.h; // SWAPPED: Minor tick is now big (40.h)
                      } else {
                        tickHeight = 15.h; // Smallest tick remains the same
                      }

                      return SizedBox(
                        // ⭐️ FIX: Use the standardized tickPixelWidth
                        width: tickPixelWidth.w,
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            width: isMajor ? 3.w : 2.w,
                            height: tickHeight, // Use the swapped height
                            decoration: BoxDecoration(
                              color: AppColor.white,
                              borderRadius: BorderRadius.circular(1.r),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Center Indicator (The purple bar) - No controller dependencies here
              Container(
                width: 10.w,
                height: 100.h,
                decoration: BoxDecoration(
                  color: AppColor.customPurple,
                  borderRadius: BorderRadius.circular(5.r),
                  boxShadow: [
                    BoxShadow(
                      color: AppColor.customPurple.withOpacity(0.6),
                      blurRadius: 15.r,
                      spreadRadius: 3.r,
                    ),
                  ],
                ),
              ),

              // Static Weight Labels (127, 129, etc.)
              Positioned(
                top: 100.h,
                child: Obx(() {
                  // ⭐️ CONTROLLER FIX: Use controller.weight
                  final currentWeight = controller.weight.value.round();
                  // ⭐️ Assuming AppTextStyles is the class name
                  final style = AppTextStyles.workSansRegular.copyWith(
                    fontSize: 14.sp,
                    color: AppColor.white,
                  );

                  // Spacing based on 10 ticks * 20.w per tick = 200.w
                  const double spacingPerUnit = tickPixelWidth * 11;

                  return Row(
                    children: [
                      // Previous Integer
                      Text('${currentWeight - 1}', style: style),

                      SizedBox(width: spacingPerUnit.w),

                      // Next Integer
                      Text('${currentWeight + 1}', style: style),
                    ],
                  );
                }),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
