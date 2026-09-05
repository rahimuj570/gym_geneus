import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:kenzeno/app/modules/setup/views/gender.dart';

import '../../../res/assets/asset.dart';

import '../../../res/colors/colors.dart';
import '../../../res/fonts/textstyle.dart';

import '../../../widgets/custom_button.dart';

class Setup extends StatelessWidget {
  Setup({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: AppColor.black111214,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: 0.5.sh,
              child: Image.asset(
                ImageAssets.img_6,
                fit: BoxFit.cover,
                colorBlendMode: BlendMode.darken,
              ),
            ),

            SizedBox(height: 40.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Text(
                "Consistency Is\nthe Key To progress.\nDon't Give Up!",
                style: AppTextStyles.workSansSemiBold.copyWith(
                  fontSize: 28.sp, // reduced size
                ),
                textAlign: TextAlign.center,
              ),
            ),

            Spacer(),

            // Button
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: CustomButton(
                onPress: () async {
                  Get.to(Gender(), transition: Transition.rightToLeft);
                },
                title: "Continue",
                fontSize: 14.sp,
                height: 45.h,
                svgorimage: true,
                trailing: ImageAssets.svg3,
                fontFamily: 'WorkSans',
                radius: 20.r,

                fontWeight: FontWeight.bold,
                textColor: AppColor.white,
                borderColor: AppColor.customPurple,
                buttonColor: AppColor.white15,
              ),
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }
}
