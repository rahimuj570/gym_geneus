import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kenzeno/app/modules/setup/views/bodyanalysis.dart';
import 'package:kenzeno/app/widgets/backbutton_widget.dart';

// Imports for supporting files
import '../../../res/assets/asset.dart';
import '../../../res/colors/colors.dart';
import '../../../res/fonts/textstyle.dart';
import '../../../widgets/custom_button.dart';
import '../controllers/setup_controller.dart';
import 'package:kenzeno/app/widgets/custom_snackbar.dart';

// Widget for the selectable activity level buttons
class ActivityLevelSelectionButton extends StatelessWidget {
  final String level;
  final SetupController controller;

  const ActivityLevelSelectionButton({
    Key? key,
    required this.level,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isSelected = controller.selectedActivityLevel.value == level;

      // Determine background color and border color based on selection state
      // The background color matches the border color for selected state
      final buttonColor = isSelected ? AppColor.customPurple : AppColor.white;
      final borderColor = isSelected ? AppColor.customPurple : AppColor.white15;
      final textColor = isSelected ? AppColor.white : AppColor.customPurple;

      return GestureDetector(
        onTap: () => controller.selectActivityLevel(level),
        child: Container(
          height: 50.h,
          margin: EdgeInsets.symmetric(vertical: 10.h),
          decoration: BoxDecoration(
            color: buttonColor,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: borderColor, width: 2.w),
          ),
          child: Center(
            child: Text(
              level,
              style: AppTextStyles.poppinsSemiBold.copyWith(
                fontSize: 16.sp,
                color: textColor,
              ),
            ),
          ),
        ),
      );
    });
  }
}

// Main page widget
class ActivityLevelPage extends StatelessWidget {
  // Initialize the controller
  final SetupController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    // Scaffold is wrapped in GetBuilder/Obx, so we use the context from GetMaterialApp
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButtonBox(),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 40.h),
              Text(
                'Physical Activity Level',
                style: AppTextStyles.poppinsBold.copyWith(fontSize: 25.sp),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10.h),
              // Description
              Text(
                'Select your daily activity level to help calculate your optimal workout and calorie recommendations.',
                style: AppTextStyles.poppinsRegular.copyWith(
                  color: AppColor.white30,
                  fontSize: 14.sp,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 50.h),

              // Level Selection Buttons
              ActivityLevelSelectionButton(
                level: 'Beginner',
                controller: controller,
              ),
              ActivityLevelSelectionButton(
                level: 'Intermediate',
                controller: controller,
              ),
              ActivityLevelSelectionButton(
                level: 'Advance',
                controller: controller,
              ),

              const Spacer(),

              // Continue Button
              Obx(
                () => CustomButton(
                  onPress: () async {
                    if (controller.selectedActivityLevel.value.isEmpty) {
                      CustomSnackbar.showWarning(
                        'Please select your activity level to continue',
                        title: 'Selection Required',
                      );
                      return;
                    } else {
                      print(controller.selectedActivityLevel.value);
                      Get.to(
                        Bodyanalysis(),
                        transition: Transition.rightToLeft,
                      );
                    }
                  },
                  title: "Continue",
                  fontSize: 16.sp,
                  height: 45.h, // Increased height for better visibility
                  svgorimage: true,
                  trailing: ImageAssets.svg3,
                  fontFamily: 'WorkSans',
                  radius: 20.r,
                  fontWeight: FontWeight.w700,
                  textColor: AppColor.white,
                  borderColor: controller.selectedActivityLevel.value.isEmpty
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
