// lib/app/modules/setup/views/bodyanalysis.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kenzeno/app/modules/setup/controllers/setup_controller.dart';
import '../../../res/assets/asset.dart';
import '../../../res/colors/colors.dart';
import '../../../res/fonts/textstyle.dart';
import '../../../widgets/custom_button.dart';
import '../../home/controllers/calender_controller.dart';
import 'fill_profile.dart';

class Bodyanalysis extends StatelessWidget {
  Bodyanalysis({super.key});

  final ImagePicker _picker = ImagePicker();

  void _showPhotoSourceSheet() {
    final controller = Get.find<SetupController>();

    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(24.w),
        decoration: const BoxDecoration(
          color: AppColor.gray1F2937,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Add Progress Photo",
              style: AppTextStyles.poppinsBold.copyWith(
                fontSize: 20.sp,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 30.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _photoOption(Icons.camera_alt, "Camera", () async {
                  await controller.takeAndUploadPhoto(fromGallery: false);
                }),
                _photoOption(Icons.photo_library, "Gallery", () async {
                  await controller.takeAndUploadPhoto(fromGallery: true);
                }),
              ],
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          Image.asset(
            ImageAssets.img_9,
            fit: BoxFit.cover,
            colorBlendMode: BlendMode.darken,
          ),

          // Overlay
          Container(color: Colors.black.withOpacity(0.3)),

          // Content
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Spacer(),
              Center(
                child: Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                  ),
                  child: Column(
                    children: [
                      Text(
                        "Body Analysis",
                        style: AppTextStyles.workSansBold.copyWith(
                          fontSize: 35.sp,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        "We’ll now scan your body for better assessment result. Ensure the following:",
                        style: AppTextStyles.workSansRegular.copyWith(
                          fontSize: 16.sp,
                          color: Colors.white.withOpacity(0.6),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "720p Camera",
                            style: AppTextStyles.workSansBold.copyWith(
                              fontSize: 16.sp,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SvgPicture.asset(ImageAssets.svg11),
                        ],
                      ),
                      SizedBox(height: 10.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Stay Still",
                            style: AppTextStyles.workSansBold.copyWith(
                              fontSize: 16.sp,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SvgPicture.asset(ImageAssets.svg11),
                        ],
                      ),
                      SizedBox(height: 10.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Good Lighting",
                            style: AppTextStyles.workSansBold.copyWith(
                              fontSize: 16.sp,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SvgPicture.asset(ImageAssets.svg11),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              Spacer(),
              // Button — ONLY THIS CHANGED
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: CustomButton(
                  onPress: () async =>
                      _showPhotoSourceSheet(), // ← Only this line changed
                  title: "Got it,lets scan",
                  fontSize: 14.sp,
                  height: 45.h,
                  svgorimage: true,
                  trailing: ImageAssets.svg12,
                  fontFamily: 'WorkSans',
                  radius: 20.r,
                  width: 1,
                  fontWeight: FontWeight.bold,
                  textColor: AppColor.white,
                  borderColor: AppColor.customPurple,
                  buttonColor: AppColor.customPurple,
                ),
              ),

              SizedBox(height: 40.h),
            ],
          ),
        ],
      ),
    );
  }

  Widget _photoOption(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: AppColor.customPurple.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 30.sp, color: AppColor.customPurple),
          ),
          SizedBox(height: 12.h),
          Text(
            label,
            style: AppTextStyles.poppinsSemiBold.copyWith(
              color: Colors.white,
              fontSize: 12.sp,
            ),
          ),
        ],
      ),
    );
  }
}
