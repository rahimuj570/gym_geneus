// lib/app/modules/setup/views/choose_schedule_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:kenzeno/app/modules/setup/views/goal.dart';
import 'package:kenzeno/app/widgets/custom_snackbar.dart';
import '../../../res/assets/asset.dart';
import '../../../res/colors/colors.dart';
import '../../../res/fonts/textstyle.dart';
import '../../../widgets/backbutton_widget.dart';
import '../../../widgets/custom_button.dart';
import '../controllers/schedule_controller.dart';

class ChooseSchedulePage extends StatelessWidget {
  const ChooseSchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ScheduleController>();

    return Scaffold(
      appBar: AppBar(
        leading: const BackButtonBox(),
        title: Text(
          'Choose Your Schedule',
          style: AppTextStyles.poppinsBold.copyWith(
            color: Colors.white,
            fontSize: 20.sp,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          SizedBox(height: 30.h),

          // Schedule Workout Days
          Text(
            'Schedule workout',
            style: AppTextStyles.poppinsSemiBold.copyWith(
              color: Colors.white,
              fontSize: 18.sp,
            ),
          ),
          SizedBox(height: 20.h),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Obx(
              () => Row(
                children: List.generate(7, (index) {
                  final day = controller.dayNames[index];
                  final isSelected = controller.isDaySelected(index);
                  return GestureDetector(
                    onTap: () => controller.toggleDay(index),
                    child: Container(
                      width: 50.r,
                      height: 50.r,
                      margin: EdgeInsets.only(right: 12.w),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected
                            ? AppColor.customPurple
                            : Colors.transparent,
                        border: Border.all(
                          color: isSelected
                              ? AppColor.customPurple
                              : AppColor.gray9CA3AF,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          day,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : AppColor.gray9CA3AF,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),

          SizedBox(height: 50.h),

          // Preferred Time
          Text(
            'Preferred time',
            style: AppTextStyles.poppinsSemiBold.copyWith(
              color: Colors.white,
              fontSize: 18.sp,
            ),
          ),
          SizedBox(height: 20.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Hour
              _timePicker(
                items: controller.hours.map((e) => e.toString()).toList(),
                selectedValue: controller.selectedHour.value.toString(),
                scrollController: controller.hourController,
                onChanged: (index) =>
                    controller.updateHour(controller.hours[index]),
              ),

              SizedBox(width: 16.w),
              Text(
                ':',
                style: TextStyle(color: Colors.white, fontSize: 32.sp),
              ),
              SizedBox(width: 16.w),

              // Minute
              _timePicker(
                items: controller.minutes
                    .map((e) => e.toString().padLeft(2, '0'))
                    .toList(),
                selectedValue: controller.selectedMinute.value
                    .toString()
                    .padLeft(2, '0'),
                scrollController: controller.minuteController,
                onChanged: (index) =>
                    controller.updateMinute(controller.minutes[index]),
              ),

              SizedBox(width: 16.w),

              // AM/PM ← Fixed this one!
              _timePicker(
                items: controller.amPmOptions,
                selectedValue: controller.selectedAmPm.value,
                scrollController: controller.amPmController,
                onChanged: (index) => controller.updateAmPm(
                  controller.amPmOptions[index],
                ), // Now passes String
              ),
            ],
          ),

          const Spacer(),

          // Continue Button
          Obx(
            () => Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: CustomButton(
                onPress: () async {
                  if (!controller.canContinue) {
                    CustomSnackbar.showWarning(
                      'Please select at least one workout day to continue',
                      title: 'Schedule Required',
                    );
                    return;
                  }
                  print("Time: ${controller.preferredWorkoutTime}");
                  print("Days: ${controller.preferredWorkoutDayIds}");
                  Get.to(
                    () => GoalSelectionPage(),
                    transition: Transition.rightToLeft,
                  );
                },
                title: "Continue",
                fontSize: 16.sp,
                height: 45.h,
                svgorimage: true,
                trailing: ImageAssets.svg3,
                radius: 26.r,
                fontWeight: FontWeight.w700,
                textColor: Colors.white,
                buttonColor: controller.canContinue
                    ? AppColor.customPurple
                    : AppColor.white15,
                borderColor: controller.canContinue
                    ? AppColor.customPurple
                    : AppColor.white15,
              ),
            ),
          ),

          SizedBox(height: 30.h),
        ],
      ),
    );
  }

  Widget _timePicker({
    required List<String> items,
    required String selectedValue,
    required FixedExtentScrollController scrollController,
    required void Function(int) onChanged, // ← keep int
  }) {
    return Container(
      width: 80.w,
      height: 160.h,
      decoration: BoxDecoration(
        color: AppColor.black111214,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            height: 50.h,
            decoration: BoxDecoration(
              color: AppColor.customPurple,
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
          ListWheelScrollView.useDelegate(
            controller: scrollController,
            itemExtent: 50.h,
            physics: const FixedExtentScrollPhysics(),
            onSelectedItemChanged: onChanged, // ← now works for all
            childDelegate: ListWheelChildBuilderDelegate(
              childCount: items.length,
              builder: (_, i) {
                final isSelected = items[i] == selectedValue;
                return Center(
                  child: Text(
                    items[i],
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppColor.white,
                      fontSize: isSelected ? 28.sp : 20.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
