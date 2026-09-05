import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:kenzeno/app/modules/home/views/leaderboard.dart';
import 'package:kenzeno/app/res/assets/asset.dart';
import 'package:kenzeno/app/widgets/backbutton_widget.dart';
import '../../../res/colors/colors.dart';
import '../../../res/fonts/textstyle.dart';
import 'challenges.dart';
import 'discussion.dart';

class CommunityPage extends StatelessWidget {
  const CommunityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          leading: BackButtonBox(),
          title: Row(
            children: [
              Text(
                'Community',
                style: AppTextStyles.poppinsBold.copyWith(
                  color: Colors.white,
                  fontSize: 22.sp,
                ),
              ),

              Spacer(),
              GestureDetector(
                onTap: () {
                  Get.to(LeaderboardPage(), transition: Transition.rightToLeft);
                },
                child: SvgPicture.asset(ImageAssets.svg51, height: 30.h),
              ),
            ],
          ),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(60.h),
            child: Builder(
              builder: (context) {
                final TabController controller = DefaultTabController.of(
                  context,
                );
                return AnimatedBuilder(
                  animation: controller.animation!,
                  builder: (context, _) {
                    return Align(
                      alignment: Alignment.centerLeft,
                      child: TabBar(
                        isScrollable: true,
                        indicatorColor: Colors.transparent,
                        tabAlignment: TabAlignment.start,
                        dividerColor: Colors.transparent,
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        labelPadding: EdgeInsets.only(right: 10.w),
                        tabs: [
                          _buildTab('Discussion Forum', controller.index == 0),
                          _buildTab('Challenges', controller.index == 1),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
        body: TabBarView(children: [DiscussionForumPage(), ChallengesPage()]),
      ),
    );
  }

  Widget _buildTab(String text, bool isSelected) {
    return Tab(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColor.customPurple : Colors.white,
          borderRadius: BorderRadius.circular(50.r),
          border: Border.all(color: AppColor.customPurple, width: 1.w),
        ),
        child: Text(
          text,
          style: AppTextStyles.poppinsMedium.copyWith(
            fontSize: 12.sp,
            color: isSelected ? Colors.white : AppColor.customPurple,
          ),
        ),
      ),
    );
  }
}
