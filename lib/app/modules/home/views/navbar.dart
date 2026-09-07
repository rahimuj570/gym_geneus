import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:kenzeno/app/modules/home/views/calender.dart';

import '../../../res/assets/asset.dart';
import '../../../res/colors/colors.dart';
import '../../../res/fonts/textstyle.dart';
import '../../chat/views/chat.dart';
import '../../setting/views/more.dart';
import '../../workout/views/workout.dart';
import '../controllers/navcontroller.dart';
import '../../home/views/home.dart';

import 'package:flutter/services.dart';

class Navbar extends StatelessWidget {
  Navbar({super.key});

  final NavController controller = Get.find();

  final List<Widget> pages = [
    HomeScreen(),
    Calender(),
    ChatScreen(),
    Workout(),
    More(),
  ];

  final List<String> labels = ['Home', 'Calender', 'Chat', 'Training', 'More'];
  final List<String> icons = [
    ImageAssets.svg18,
    ImageAssets.svg19,
    ImageAssets.svg20,
    ImageAssets.svg21,
    ImageAssets.svg22,
  ];

  Future<bool?> _showExitConfirmationDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: AppColor.gray1F2937,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(14.r),
                  decoration: BoxDecoration(
                    color: AppColor.customPurple.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.exit_to_app_rounded,
                    color: AppColor.customPurple,
                    size: 32.sp,
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  "Exit App",
                  style: AppTextStyles.poppinsBold.copyWith(
                    color: Colors.white,
                    fontSize: 18.sp,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  "Are you sure you want to exit Kenzeno?",
                  textAlign: TextAlign.center,
                  style: AppTextStyles.poppinsRegular.copyWith(
                    color: AppColor.gray9CA3AF,
                    fontSize: 13.sp,
                  ),
                ),
                SizedBox(height: 24.h),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.white24),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                        ),
                        child: Text(
                          "Cancel",
                          style: AppTextStyles.poppinsMedium.copyWith(
                            color: Colors.white,
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.customPurple,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                        ),
                        child: Text(
                          "Exit",
                          style: AppTextStyles.poppinsBold.copyWith(
                            color: Colors.white,
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) return;

        // If not on the Home tab, switch to the Home tab first
        if (controller.currentIndex.value != 0) {
          controller.currentIndex.value = 0;
          return;
        }

        // When on Home tab, ask for exit confirmation
        final shouldExit = await _showExitConfirmationDialog(context);
        if (shouldExit == true) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        body: Obx(() => pages[controller.currentIndex.value]),
      bottomNavigationBar: Obx(
        () => Container(
          color: AppColor.customDarkGray,
          child: SafeArea(
            bottom: true,
            child: Container(
              height: 64.h,
              decoration: BoxDecoration(
                color: AppColor.customDarkGray,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.r),
                  topRight: Radius.circular(20.r),
                ),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10.r)],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(5, (index) {
                  final isSelected = controller.currentIndex.value == index;
                  final bool isAddNew = index == 2;

                  final double iconWidth = isAddNew ? 24.w : 18.w;
                  final double iconHeight = isAddNew ? 24.h : 18.h;

                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => controller.currentIndex.value = index,
                    child: SizedBox(
                      width: 60.w,
                      height: 64.h,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            icons[index],
                            width: iconWidth,
                            height: iconHeight,
                            colorFilter: isAddNew
                                ? null
                                : ColorFilter.mode(
                                    isSelected
                                        ? AppColor.customPurple
                                        : AppColor.customGray,
                                    BlendMode.srcIn,
                                  ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            labels[index],
                            style: AppTextStyles.poppinsBold.copyWith(
                              fontSize: 10.sp,
                              color: isSelected
                                  ? AppColor.customPurple
                                  : AppColor.customGray,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    ),);
  }
}
