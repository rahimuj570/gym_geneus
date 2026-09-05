import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kenzeno/app/widgets/backbutton_widget.dart';

import '../../../res/colors/colors.dart';
import '../../../res/fonts/textstyle.dart';

class ContentSplash extends StatelessWidget {
  final String imageUrl;
  final String icon;
  final String title;
  final String buttonText;
  final String? description;
  final VoidCallback? onTap; // <-- Added callback

  const ContentSplash({
    required this.imageUrl,
    required this.icon,
    required this.title,
    required this.buttonText,
    this.description,
    this.onTap, // optional
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. Background Image with Dark Overlay
        Container(
          decoration: const BoxDecoration(color: AppColor.black111214),
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.5),
                  Colors.black.withOpacity(0.6),
                  Colors.black.withOpacity(0.7),
                ],
              ),
            ),
            child: Opacity(
              opacity: 0.8,
              child: Image.asset(
                imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (context, error, stackTrace) =>
                    Container(color: Colors.black, alignment: Alignment.center),
              ),
            ),
          ),
        ),

        // 2. Main Content Area (Centered)
        Align(
          alignment: Alignment.center,
          child: Container(
            height: 150.h,
            padding: EdgeInsets.all(12.w),
            color: AppColor.black50,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Custom Icon + Title
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      icon,
                      height: 30.h,
                      color: AppColor.customPurple,
                    ),
                    SizedBox(width: 5.h),
                    Text(
                      title,
                      style: AppTextStyles.poppinsBold.copyWith(
                        fontSize: 20.sp,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 15.h),

                // Description
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40.w),
                  child: Text(
                    description ??
                        'Push your limits today! Complete your daily workout challenge to build consistency, stay fit, and unlock your potential.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.poppinsRegular.copyWith(
                      fontSize: 12.sp,
                      color: Colors.white70,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // 3. Bottom Button with onTap
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: EdgeInsets.only(bottom: 50.h, left: 20.w, right: 20.w),
            child: GestureDetector(
              onTap: onTap, // <-- call the passed callback
              child: Container(
                height: 50.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15.r),
                  boxShadow: [
                    BoxShadow(
                      color: AppColor.customPurple.withOpacity(0.5),
                      blurRadius: 15.r,
                      offset: const Offset(0, 5),
                    ),
                  ],
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      AppColor.customPurple.withOpacity(0.9),
                      AppColor.customPurple.withOpacity(0.5),
                      Colors.black.withOpacity(0.3),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
                child: Center(
                  child: Text(
                    buttonText,
                    style: AppTextStyles.poppinsSemiBold.copyWith(
                      fontSize: 18.sp,
                      color: AppColor.white,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        // 4. Top-Left Back Button
        Positioned(
          top: 10.h,
          left: 10.w,
          child: const SafeArea(child: BackButtonBox()),
        ),
      ],
    );
  }
}
