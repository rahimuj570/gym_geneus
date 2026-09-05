// lib/widgets/custom_button.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../res/assets/asset.dart';
import '../res/colors/colors.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    Key? key,
    required this.onPress,
    required this.title,
    this.buttonColor = AppColor.vividAmber,
    this.textColor = AppColor.background,
    this.subtextColor = AppColor.background,
    this.borderColor = AppColor.vividAmber,
    this.borderShadowColor = const Color(0x1E000000),
    this.arrowicon = false,
    this.trailing = ImageAssets.svg1,
    this.svgorimage = false,
    this.height = 50,
    this.imageHeight = 25,
    this.imageWidth = 25,
    this.width = 390,
    this.loading = false,
    this.center = true,
    this.icon = false,
    this.leadingSvg = false,
    this.leadingSvgPath = '',
    this.image = ImageAssets.fb,
    this.fontSize = 14,
    this.fontWeight = FontWeight.w500,
    this.fontFamily = 'WorkSans',
    this.radius = 8,
    this.subtitle = '',
    this.subfontSize = 14,
    this.subfontWeight = FontWeight.w400,
    this.subfontFamily = 'WorkSans',
    this.gradient,
    this.textGradient,
  }) : super(key: key);

  // ─────────────────── parameters
  final Future<void> Function()? onPress;

  final Gradient? textGradient; // new optional parameter

  final Color buttonColor,
      textColor,
      subtextColor,
      borderColor,
      borderShadowColor;
  final Gradient? gradient;

  // sizing / layout
  final double height,
      width,
      radius,
      imageHeight,
      imageWidth,
      fontSize,
      subfontSize;

  // states
  final bool loading,
      center,
      icon,
      arrowicon,
      svgorimage,
      leadingSvg;

  // leading / trailing assets
  final String image, trailing, leadingSvgPath;

  // text
  final String title,
      subtitle,
      fontFamily,
      subfontFamily;
  final FontWeight fontWeight, subfontWeight;

  // ─────────────────── build
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (onPress != null && !loading) ? () => onPress!() : null,
      child: Container(
        height: height,
        width: width.w,
        decoration: BoxDecoration(
          color: gradient == null ? buttonColor : null,
          gradient: gradient,
          borderRadius: BorderRadius.circular(radius.r),
          border: Border.all(color: borderColor,width: 2.w),
          boxShadow: [
            BoxShadow(
              color: borderShadowColor,
              blurRadius: 4.r,
              offset: Offset(0, 2.h),
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: loading
            ? Center(child: CircularProgressIndicator(color: textColor))
            : center
            ? _buildCenteredContent()
            : _buildRowContent(),
      ),
    );
  }

  // ─────────────────── centered layout
  Widget _buildCenteredContent() {
    if (subtitle.isEmpty) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon) _leadingWidget(),
          if (icon) SizedBox(width: 8.w),
          Text(
            title,
            style: textGradient != null
                ? TextStyle(
              fontSize: fontSize.sp,
              fontWeight: fontWeight,
              fontFamily: fontFamily,
              foreground: Paint()
                ..shader =
                (textGradient as LinearGradient).createShader(
                  Rect.fromLTRB(
                    0,
                    0,
                    width.w.clamp(0, 300.w),
                    height.h.clamp(0, 60.h),
                  ),
                ),
            )
                : TextStyle(
              fontSize: fontSize.sp,
              fontWeight: fontWeight,
              fontFamily: fontFamily,
              color: textColor,
            ),
          ),
          if (arrowicon) ...[
            SizedBox(width: 10.w),
            Icon(Icons.arrow_forward_ios,
                color: textColor, size: 18.sp),
          ],
          if (svgorimage) ...[
            SizedBox(width: 10.w),
            SvgPicture.asset(
              trailing,
              color: textColor,
              width: 18.w,
              height: 18.h,
            ),
          ],
        ],
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon) _leadingWidget(),
          if (icon) SizedBox(height: 6.h),
          Text(
            title,
            style: TextStyle(
              color: textColor,
              fontSize: fontSize.sp,
              fontWeight: fontWeight,
              fontFamily: fontFamily,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            subtitle,
            style: TextStyle(
              color: subtextColor,
              fontSize: subfontSize.sp,
              fontWeight: subfontWeight,
              fontFamily: subfontFamily,
            ),
          ),
        ],
      );
    }
  }

  // ─────────────────── left-aligned layout
  Widget _buildRowContent() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (icon) _leadingWidget(),
        if (icon) SizedBox(width: 12.w),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: textColor,
                  fontSize: fontSize.sp,
                  fontWeight: fontWeight,
                  fontFamily: fontFamily,
                ),
              ),
              if (subtitle.isNotEmpty)
                Text(
                  subtitle,
                  style: TextStyle(
                    color: subtextColor,
                    fontSize: subfontSize.sp,
                    fontWeight: subfontWeight,
                    fontFamily: subfontFamily,
                  ),
                ),
            ],
          ),
        ),
        if (arrowicon)
          Icon(Icons.arrow_forward_ios,
              size: 18.sp, color: textColor),
      ],
    );
  }

  // ─────────────────── leading image/svg widget
  Widget _leadingWidget() {
    return leadingSvg
        ? SvgPicture.asset(
      leadingSvgPath,
      width: imageWidth.w,
      height: imageHeight.h,
      color: textColor,
    )
        : Image.asset(
      image,
      width: imageWidth.w,
      height: imageHeight.h,
    );
  }
}
