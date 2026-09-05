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

class Navbar extends StatelessWidget {
  Navbar({Key? key}) : super(key: key);

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
    );
  }
}
