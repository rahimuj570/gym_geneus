import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../res/colors/colors.dart';
import '../../../res/fonts/textstyle.dart';

class InfoCard extends StatelessWidget {
  final String svgPath;
  final String title;
  final String subtitle;

  const InfoCard({
    Key? key,
    required this.svgPath,
    required this.title,
    required this.subtitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        color: AppColor.black50,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(svgPath, width: 32.w, height: 32.h),
          SizedBox(height: 10.h),
          Text(
            title,
            style: AppTextStyles.poppinsBold.copyWith(
              fontSize: 14.sp,
              color: AppColor.white, // or any color from AppColor
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 5.h),
          Text(
            subtitle,
            style: AppTextStyles.poppinsRegular.copyWith(
              fontSize: 11.sp,
              color: AppColor.gray9CA3AF, // your custom gray
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
