import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:kenzeno/app/modules/setup/controllers/setup_controller.dart';
import 'package:kenzeno/app/res/assets/asset.dart';
import 'package:kenzeno/app/widgets/backbutton_widget.dart';
import 'package:kenzeno/app/widgets/custom_button.dart';

import '../../../res/colors/colors.dart';
import '../../../res/fonts/textstyle.dart';
import '../service/service.dart';
import '../widgets/trainercard.dart';

class CoachPage extends StatelessWidget {
  final bool isFromSettings;
  final SetupController controller = Get.find<SetupController>();

  CoachPage({Key? key, this.isFromSettings = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    controller.fetchCoaches();
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButtonBox(),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Center(
                child: Text(
                  "Choose Your Coach",
                  style: AppTextStyles.poppinsBold.copyWith(fontSize: 22.sp),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 10.h),

              // Description
              Center(
                child: Text(
                  'Pick the look and personality of the coach who will guide you to achieve your goals.',
                  style: AppTextStyles.poppinsRegular.copyWith(
                    color: AppColor.white30,
                    fontSize: 14.sp,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 30.h),

              // Grid of Trainer Cards
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColor.customPurple,
                      ),
                    );
                  }

                  final isTablet = MediaQuery.of(context).size.width >= 600;

                  return GridView.builder(
                    padding: EdgeInsets.only(bottom: 20.h),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isTablet ? 3 : 2,
                      mainAxisSpacing: 20.h,
                      crossAxisSpacing: 16.w,
                      childAspectRatio: isTablet ? 4 / 5 : 2 / 3,
                    ),
                    itemCount: controller.coaches.length,
                    itemBuilder: (context, index) {
                      final coach = controller.coaches[index];

                      final String imagePath = switch (coach.id) {
                        1 => ImageAssets.img_11,
                        2 => ImageAssets.img_12,
                        3 => ImageAssets.img_13,
                        4 => ImageAssets.img_14,
                        _ => ImageAssets.img_11,
                      };

                      return TrainerCard(
                        imagePath: imagePath,
                        name: coach.name,
                        subtitle: coach.behavior,
                        coachId: coach.id,
                        isFromSettings: isFromSettings,
                      );
                    },
                  );
                }),
              ),

              // Complete Setup button (only shown in initial onboarding flow)
              if (!isFromSettings)
                Obx(() {
                  final isSelected = controller.selectedCoachId.value != null &&
                      controller.selectedCoachId.value! > 0;

                  return Padding(
                    padding: EdgeInsets.only(bottom: 20.h, top: 10.h),
                    child: CustomButton(
                      onPress: isSelected
                          ? () async {
                              final setupService = Get.find<SetupService>();
                              await setupService.completeSetup();
                            }
                          : null,
                      title: "Complete Setup",
                      fontSize: 16.sp,
                      height: 45.h,
                      svgorimage: true,
                      trailing: ImageAssets.svg3,
                      radius: 26.r,
                      fontWeight: FontWeight.w700,
                      textColor: Colors.white,
                      buttonColor: isSelected
                          ? AppColor.customPurple
                          : AppColor.white15,
                      borderColor: AppColor.white15,
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }
}
