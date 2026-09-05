import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kenzeno/app/modules/home/views/article.dart';
import 'package:kenzeno/app/modules/home/views/workoutvideo.dart';
import 'package:kenzeno/app/widgets/backbutton_widget.dart';
import '../../../res/colors/colors.dart';
import '../../../res/fonts/textstyle.dart';

class ResourcesTabScreen extends StatelessWidget {
  const ResourcesTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          leading: const BackButtonBox(),
          title: Text(
            'Resources',
            style: AppTextStyles.poppinsBold.copyWith(
              color: AppColor.white,
              fontSize: 20.sp,
            ),
          ),
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(55.h),
            child: Center(
              // ✅ centers the TabBar
              child: Container(
                margin: EdgeInsets.only(bottom: 10.h),
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(50.r),
                ),
                child: TabBar(
                  // ✅ allows tabs to take minimal width
                  dividerColor: Colors.transparent,
                  indicator: BoxDecoration(
                    color: AppColor.customPurple, // active tab color
                    borderRadius: BorderRadius.circular(50.r),
                  ),
                  unselectedLabelColor: AppColor.customPurple,
                  labelColor: Colors.white,
                  indicatorColor: Colors.transparent,
                  labelPadding: EdgeInsets.symmetric(horizontal: 2.w),
                  tabs: [
                    _buildTab('Workout Videos'),
                    _buildTab('Articles & Tips'),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: const TabBarView(children: [WorkoutvideoPage(), ArticlePage()]),
      ),
    );
  }

  Widget _buildTab(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 6.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50.r),
        border: Border.all(color: AppColor.customPurple, width: 1.w),
      ),
      child: Text(
        text,
        style: AppTextStyles.poppinsMedium.copyWith(fontSize: 14.sp),
      ),
    );
  }
}
