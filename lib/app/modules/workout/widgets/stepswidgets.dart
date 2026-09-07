// lib/app/modules/setting/widgets/trainnigstep.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../res/colors/colors.dart';
import '../../../res/fonts/textstyle.dart';
import '../model/workoutmodel.dart'; // UserExercise model from API

class TrainingStepWidget extends StatelessWidget {
  final UserExercise step;
  final VoidCallback? onTap;
  final bool isCompleted;

  const TrainingStepWidget({
    super.key,
    required this.step,
    this.onTap,
    this.isCompleted = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
        child: Container(
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: isCompleted ? const Color(0xFFF0FDF4) : AppColor.white,
            borderRadius: BorderRadius.circular(30.r),
            border: isCompleted
                ? Border.all(
                    color: AppColor.green16A34A.withOpacity(0.6),
                    width: 1.5.w,
                  )
                : null,
            boxShadow: [
              BoxShadow(
                color: isCompleted
                    ? AppColor.green16A34A.withOpacity(0.15)
                    : AppColor.customPurple.withOpacity(0.1),
                blurRadius: 10.r,
                offset: Offset(0, 4.h),
              ),
            ],
          ),
          child: Row(
            children: [
              /// ▶ Play or ✔ Check icon
              Icon(
                isCompleted ? Icons.check_circle : Icons.play_circle_fill,
                color: isCompleted
                    ? AppColor.green16A34A
                    : AppColor.customPurple,
                size: 30.sp,
              ),
              SizedBox(width: 15.w),

              /// Exercise title + duration / status
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            step.exerciseName,
                            style: AppTextStyles.poppinsBold.copyWith(
                              color: AppColor.black111214,
                              fontSize: 12.sp,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isCompleted) ...[
                          SizedBox(width: 6.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColor.green16A34A,
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Text(
                              "COMPLETED",
                              style: AppTextStyles.poppinsBold.copyWith(
                                color: Colors.white,
                                fontSize: 8.sp,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: 4.h),

                    Row(
                      children: [
                        Icon(
                          isCompleted
                              ? Icons.done_all
                              : Icons.watch_later_outlined,
                          color: isCompleted
                              ? AppColor.green16A34A
                              : AppColor.customPurple,
                          size: 12.sp,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          isCompleted
                              ? "Completed"
                              : "${step.durationSeconds}s",
                          style: AppTextStyles.poppinsRegular.copyWith(
                            color: isCompleted
                                ? AppColor.green16A34A
                                : AppColor.customPurple,
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
                  color: isCompleted
                      ? AppColor.green16A34A
                      : AppColor.customPurple,
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
