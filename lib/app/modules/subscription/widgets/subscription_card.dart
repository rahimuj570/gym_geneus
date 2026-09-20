import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kenzeno/app/res/colors/colors.dart';

class SubscriptionCard extends StatelessWidget {
  final String duration;
  final String price;
  final String monthlyPrice;
  final List<String> features;
  final bool isBestValue;
  final bool isSelected;
  final VoidCallback onPressed;
  final String? trialText;

  const SubscriptionCard({
    super.key,
    required this.duration,
    required this.price,
    required this.monthlyPrice,
    required this.features,
    this.isBestValue = false,
    this.isSelected = false,
    required this.onPressed,
    this.trialText,
  });

  @override
  Widget build(BuildContext context) {
    final Color bgColor = isBestValue
        ? AppColor.customPurple
        : AppColor.gray374151;
    final Color textColor = Colors.white;
    final Color buttonColor = isBestValue
        ? Colors.white
        : AppColor.customPurple;
    final Color buttonTextColor = isBestValue
        ? AppColor.customPurple
        : Colors.white;

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 300.w,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected
                ? (isBestValue ? Colors.white : AppColor.customPurple)
                : Colors.transparent,
            width: 2.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              offset: const Offset(0, 4),
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // BEST VALUE + Star badge / Free Trial badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (isBestValue)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      'BEST VALUE',
                      style: TextStyle(
                        color: AppColor.customPurple,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                else
                  const SizedBox.shrink(),

                if (trialText != null && trialText!.isNotEmpty)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      trialText!,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),

            SizedBox(height: 8.h),

            Text(
              duration,
              style: TextStyle(
                color: textColor,
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
              ),
            ),

            SizedBox(height: 4.h),

            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: price.startsWith('\$') ? price : '\$$price',
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w900,
                      color: textColor,
                    ),
                  ),
                  TextSpan(
                    text: ' total',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: textColor.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 2.h),

            Text(
              monthlyPrice.startsWith('\$')
                  ? '$monthlyPrice / month'
                  : '\$$monthlyPrice / month',
              style: TextStyle(
                color: textColor.withValues(alpha: 0.7),
                fontSize: 11.sp,
              ),
            ),

            SizedBox(height: 12.h),

            Expanded(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Column(
                  children: features.map(
                    (f) => Padding(
                      padding: EdgeInsets.only(bottom: 6.h),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle_rounded,
                            color: isBestValue
                                ? Colors.white
                                : AppColor.green16A34A,
                            size: 15.sp,
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              f,
                              style: TextStyle(
                                color: textColor.withValues(alpha: 0.95),
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).toList(),
                ),
              ),
            ),

            SizedBox(height: 8.h),

            Center(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 10.h,
                    ),
                  ),
                  child: Text(
                    'Choose $duration Plan',
                    style: TextStyle(
                      color: buttonTextColor,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
