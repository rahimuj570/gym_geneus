// lib/app/modules/settings/views/privacy_policy_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:kenzeno/app/modules/setting/controller/setting_controller.dart';

import 'package:intl/intl.dart';
import '../../../res/colors/colors.dart';
import '../../../res/fonts/textstyle.dart';
import '../../../widgets/backbutton_widget.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Settingcontroller controller = Get.find();

    return Scaffold(
      backgroundColor: AppColor.black111214,

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButtonBox(),
        title: Text(
          'Privacy Policy',
          style: AppTextStyles.poppinsBold.copyWith(
            color: AppColor.white,
            fontSize: 20.sp,
          ),
        ),
        centerTitle: true,
      ),

      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColor.customPurple,
              strokeWidth: 3,
            ),
          );
        }

        if (controller.content.value.isEmpty) {
          return Center(
            child: Text(
              'No content available',
              style: TextStyle(color: AppColor.gray9CA3AF, fontSize: 16.sp),
            ),
          );
        }

        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(24.w, 10.h, 24.w, 40.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (controller.updatedAt.value.isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(bottom: 15.h),
                  child: Text(
                    "Last Updated: ${DateFormat('MMMM dd, yyyy').format(DateTime.parse(controller.updatedAt.value))}",
                    style: AppTextStyles.poppinsMedium.copyWith(
                      color: AppColor.purpleRoyal,
                      fontSize: 13.sp,
                    ),
                  ),
                ),
              Text(
                controller.content.value,
                style: AppTextStyles.poppinsRegular.copyWith(
                  color: AppColor.white,
                  fontSize: 14.sp,
                  height: 1.6,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
