import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kenzeno/app/modules/setup/views/level.dart';
import 'package:kenzeno/app/res/colors/colors.dart';
import 'package:kenzeno/app/widgets/backbutton_widget.dart';
import 'package:kenzeno/app/widgets/custom_button.dart';

import '../../../res/assets/asset.dart';
import '../../../res/fonts/textstyle.dart';
import '../controllers/setup_controller.dart';
import 'package:kenzeno/app/widgets/custom_snackbar.dart';

class _GoalSelectionButton extends StatelessWidget {
  final String goalKey;
  final String title;
  final String svg; // Using IconData as placeholder for SVG
  final SetupController controller;

  const _GoalSelectionButton({
    Key? key,
    required this.goalKey,
    required this.title,
    required this.svg,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isSelected = controller.selectedGoal.value == goalKey;

      // Visuals change based on selection
      final bgColor = isSelected ? AppColor.customPurple : AppColor.white;
      final borderColor = isSelected
          ? AppColor.customPurple
          : Colors.transparent; // Set border to transparent when unselected
      final iconColor = isSelected ? AppColor.white : AppColor.black232323;
      final checkColor = isSelected ? AppColor.white : Colors.transparent;
      final textcolor = isSelected ? AppColor.white : AppColor.black232323;

      return GestureDetector(
        onTap: () => controller.selectGoal(goalKey),
        child: Container(
          height: 60.h,
          margin: EdgeInsets.symmetric(vertical: 10.h),
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: borderColor, width: 2.w),
          ),
          child: Row(
            children: [
              // 1. Icon/SVG Placeholder
              Center(
                // Using Icon as a substitute for an SVG widget
                child: SvgPicture.asset(svg, color: iconColor, height: 24.w),
              ),

              SizedBox(width: 15.w),

              // 2. Title Text
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.poppinsSemiBold.copyWith(
                    fontSize: 14.sp,
                    color: textcolor,
                  ),
                ),
              ),

              // 3. Checkmark Box (Rounded Radio Button)
              Container(
                width: 24.w,
                height: 24.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected
                      ? AppColor.customPurple
                      : Colors.transparent, // Fill with purple when selected
                  border: Border.all(
                    color: isSelected ? AppColor.white : AppColor.white15,
                    width: 2.w,
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.circle, // Small inner circle for checked state
                    size: 10.w,
                    color: checkColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

// --- 4. MAIN PAGE WIDGET ---

class GoalSelectionPage extends StatelessWidget {
  final SetupController controller = Get.put(SetupController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButtonBox(),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                "What's your fitness goal/target?",
                style: AppTextStyles.poppinsBold.copyWith(fontSize: 25.sp),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 50.h),

              // Goal Selection Buttons
              _GoalSelectionButton(
                goalKey: 'weight_loss',
                title: 'I wanna lose weight',
                svg: ImageAssets.svg8,
                controller: controller,
              ),
              _GoalSelectionButton(
                goalKey: 'try_ai_coach',
                title: 'I wanna try AI Coach',
                svg: ImageAssets.svg9,
                controller: controller,
              ),
              _GoalSelectionButton(
                goalKey: 'gain_endurance',
                title: 'I wanna gain endurance',
                svg: ImageAssets.svg10,
                controller: controller,
              ),

              const Spacer(),

              // Continue Button
              Obx(
                () => CustomButton(
                  onPress: () async {
                    if (controller.selectedGoal.value.isEmpty) {
                      CustomSnackbar.showWarning(
                        'Please select your fitness goal to continue',
                        title: 'Selection Required',
                      );
                      return;
                    } else {
                      print(controller.selectedGoal.value);
                      Get.to(
                        () => ActivityLevelPage(),
                        transition: Transition.rightToLeft,
                      );
                    }
                  },
                  title: "Continue",
                  fontSize: 16.sp,
                  height: 45.h,
                  svgorimage: true,
                  trailing: ImageAssets.svg3,
                  fontFamily: 'WorkSans',
                  radius: 20.r,
                  fontWeight: FontWeight.w700,
                  textColor: AppColor.white,
                  borderColor: controller.selectedGoal.value.isEmpty
                      ? AppColor.white15
                      : AppColor.customPurple,
                  buttonColor: AppColor.white15,
                ),
              ),
              SizedBox(height: 30.h),
            ],
          ),
        ),
      ),
    );
  }
}
