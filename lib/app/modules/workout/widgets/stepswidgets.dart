// lib/app/modules/setting/widgets/trainnigstep.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../res/colors/colors.dart';
import '../../../res/fonts/textstyle.dart';
import '../model/workoutmodel.dart'; // UserExercise model from API

class TrainingStepWidget extends StatelessWidget {
  final UserExercise step;
  final VoidCallback? onTap;

  const TrainingStepWidget({super.key, required this.step, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
        child: Container(
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: AppColor.white,
            borderRadius: BorderRadius.circular(30.r),
            boxShadow: [
              BoxShadow(
                color: AppColor.customPurple.withOpacity(0.1),
                blurRadius: 10.r,
                offset: Offset(0, 4.h),
              ),
            ],
          ),
          child: Row(
            children: [
              /// ▶ Play icon
              Icon(
                Icons.play_circle_fill,
                color: AppColor.customPurple,
                size: 30.sp,
              ),
              SizedBox(width: 15.w),

              /// Exercise title + duration
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      step.exerciseName,
                      style: AppTextStyles.poppinsBold.copyWith(
                        color: AppColor.black111214,
                        fontSize: 12.sp,
                      ),
                    ),
                    SizedBox(height: 4.h),

                    Row(
                      children: [
                        Icon(
                          Icons.watch_later_outlined,
                          color: AppColor.customPurple,
                          size: 12.sp,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          "${step.durationSeconds}s",
                          style: AppTextStyles.poppinsRegular.copyWith(
                            color: AppColor.customPurple,
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              /// Sets × reps
              Text(
                "${step.sets} × ${step.reps}",
                style: AppTextStyles.poppinsSemiBold.copyWith(
                  color: AppColor.customPurple,
                  fontSize: 14.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
