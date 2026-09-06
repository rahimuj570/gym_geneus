// lib/app/modules/progress/views/progress_tracking_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:kenzeno/app/modules/home/controllers/homecontroller.dart';
import 'package:kenzeno/app/res/assets/asset.dart';
import 'package:kenzeno/app/widgets/backbutton_widget.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../../../res/colors/colors.dart';
import '../../../res/fonts/textstyle.dart';
import '../models/trackprogress.dart';

class ProgressTrackingScreen extends StatefulWidget {
  const ProgressTrackingScreen({super.key});

  @override
  State<ProgressTrackingScreen> createState() => _ProgressTrackingScreenState();
}

class _ProgressTrackingScreenState extends State<ProgressTrackingScreen> {
  late final HomeController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<HomeController>()
        ? Get.find<HomeController>()
        : Get.put(HomeController());
    final now = DateTime.now();
    controller.selectedDate.value = now;
    final formattedDate = DateFormat('yyyy-MM-dd').format(now);
    controller.loadProgress(date: formattedDate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.black111214,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: 80.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20.h),
            _buildDateSelector(controller),
            SizedBox(height: 30.h),
            _buildMetricCards(controller),
            SizedBox(height: 30.h),
            _buildActivitiesSection(controller),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: const BackButtonBox(),
      centerTitle: true,
      title: Text(
        'Progress Tracking',
        style: AppTextStyles.poppinsBold.copyWith(
          fontSize: 20.sp,
          color: AppColor.white,
        ),
      ),
    );
  }

  // FIXED: No more GetX error + instant update
  Widget _buildDateSelector(HomeController controller) {
    final now = DateTime.now();

    return SizedBox(
      height: 100.h,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        scrollDirection: Axis.horizontal,
        itemCount: 7,
        itemBuilder: (context, index) {
          // today is index 0, yesterday index 1, etc.
          final date = now.subtract(Duration(days: index));
          final bool isToday = index == 0;

          // Each card listens to selectedDate independently → NO ERROR + INSTANT UPDATE
          return Obx(() {
            final bool isSelected =
                date.year == controller.selectedDate.value.year &&
                date.month == controller.selectedDate.value.month &&
                date.day == controller.selectedDate.value.day;

            return GestureDetector(
              onTap: () => controller.selectDate(date),
              child: _DateCard(
                day: date.day.toString(),
                month: DateFormat('MMM').format(date),
                isSelected: isSelected,
                isToday: isToday,
              ),
            );
          });
        },
      ),
    );
  }

  Widget _buildMetricCards(HomeController controller) {
    return Obx(() {
      if (controller.isProgressLoading.value) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 60.h),
          child: Center(
            child: CircularProgressIndicator(
              color: AppColor.customPurple,
              strokeWidth: 4,
            ),
          ),
        );
      }

      final p =
          controller.progress.value ??
          TrackProgress(
            progressPercentage: 0,
            caloriesBurned: 0,
            totalTrainingTime: 0,
          );

      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: _progressCard(p.progressPercentage)),
                SizedBox(width: 20.w),
                Expanded(child: _caloriesCard(p.caloriesBurned)),
              ],
            ),
            SizedBox(height: 20.h),
            Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                width: 0.45.sw,
                child: _trainingTimeCard(p.totalTrainingTime),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _progressCard(int percent) => _MetricCard(
    title: 'Progress',
    icon: Icons.bar_chart,
    iconColor: AppColor.white,
    child: CircularPercentIndicator(
      radius: 55.r,
      lineWidth: 10.w,
      percent: percent / 100,
      linearGradient: const LinearGradient(
        colors: [AppColor.purple9662F1, AppColor.deepPurple673AB7],
      ),
      center: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$percent%',
            style: AppTextStyles.poppinsBold.copyWith(
              fontSize: 18.sp,
              color: AppColor.white,
            ),
          ),
          Text(
            'Workout',
            style: AppTextStyles.poppinsRegular.copyWith(
              fontSize: 14.sp,
              color: AppColor.white,
            ),
          ),
        ],
      ),
      backgroundColor: AppColor.gray9CA3AF,
      circularStrokeCap: CircularStrokeCap.round,
    ),
  );

  Widget _caloriesCard(int calories) => _MetricCard(
    title: 'Calories',
    icon: Icons.local_fire_department,
    iconColor: Colors.orange,
    child: CircularPercentIndicator(
      radius: 55.r,
      lineWidth: 10.w,
      percent: calories > 1000 ? 1.0 : calories / 1000,
      linearGradient: const LinearGradient(
        colors: [AppColor.purple9662F1, AppColor.deepPurple673AB7],
      ),
      center: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$calories',
            style: AppTextStyles.poppinsBold.copyWith(
              fontSize: 18.sp,
              color: AppColor.white,
            ),
          ),
          Text(
            'KCal',
            style: AppTextStyles.poppinsRegular.copyWith(
              fontSize: 14.sp,
              color: AppColor.white,
            ),
          ),
        ],
      ),
      backgroundColor: AppColor.gray9CA3AF,
      circularStrokeCap: CircularStrokeCap.round,
    ),
  );

  Widget _trainingTimeCard(int minutes) => _MetricCard(
    title: 'Training',
    icon: Icons.fitness_center,
    iconColor: Colors.orange,
    child: Center(
      child: Text(
        '$minutes minutes',
        style: AppTextStyles.poppinsBold.copyWith(
          fontSize: 18.sp,
          color: AppColor.white,
        ),
      ),
    ),
  );

  Widget _buildActivitiesSection(HomeController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Activities',
            style: AppTextStyles.poppinsBold.copyWith(
              fontSize: 20.sp,
              color: AppColor.white,
            ),
          ),
          SizedBox(height: 15.h),
          Obx(() {
            if (controller.isLoading.value)
              return const Center(
                child: CircularProgressIndicator(color: AppColor.customPurple),
              );
            if (controller.activities.isEmpty)
              return Padding(
                padding: EdgeInsets.only(top: 20.h),
                child: Text(
                  'No activities yet',
                  style: TextStyle(color: AppColor.gray9CA3AF, fontSize: 16.sp),
                ),
              );
            return Column(
              children: controller.activities
                  .map(
                    (a) => _ActivityListItem(
                      title: a.name,
                      details: a.displayDetails,
                      duration: a.displayDuration,
                    ),
                  )
                  .toList(),
            );
          }),
        ],
      ),
    );
  }
}

// BEAUTIFUL DATE CARD – WITH TODAY GLOW + SMOOTH ANIMATION
class _DateCard extends StatelessWidget {
  final String day;
  final String month;
  final bool isSelected;
  final bool isToday;

  const _DateCard({
    required this.day,
    required this.month,
    required this.isSelected,
    required this.isToday,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: 80.w,
      height: 90.h,
      margin: EdgeInsets.symmetric(horizontal: 6.w),
      decoration: BoxDecoration(
        gradient: isSelected
            ? const LinearGradient(
                colors: [AppColor.deepPurple673AB7, AppColor.purple9662F1],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: isSelected ? null : AppColor.gray374151,
        borderRadius: BorderRadius.circular(16.r),
        border: isToday && !isSelected
            ? Border.all(
                color: AppColor.purple9662F1.withOpacity(0.9),
                width: 2.5,
              )
            : null,
        boxShadow: isToday && !isSelected
            ? [
                BoxShadow(
                  color: AppColor.purple9662F1.withOpacity(0.6),
                  blurRadius: 16,
                  spreadRadius: 3,
                ),
              ]
            : isSelected
            ? [
                BoxShadow(
                  color: AppColor.purple9662F1.withOpacity(0.4),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            day,
            style: AppTextStyles.poppinsBold.copyWith(
              fontSize: 22.sp,
              color: AppColor.white,
            ),
          ),
          Text(
            month,
            style: AppTextStyles.poppinsMedium.copyWith(
              fontSize: 14.sp,
              color: AppColor.white,
            ),
          ),
          if (isToday && !isSelected)
            Padding(
              padding: EdgeInsets.only(top: 6.h),
              child: Text(
                "TODAY",
                style: TextStyle(
                  color: AppColor.purple9662F1,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final Widget child;
  const _MetricCard({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15.r),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColor.purple786CFF50, AppColor.blue5AC8FA40],
        ),
        borderRadius: BorderRadius.circular(15.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: AppTextStyles.poppinsRegular.copyWith(
                  fontSize: 14.sp,
                  color: AppColor.white,
                ),
              ),
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.w),
                  gradient: const LinearGradient(
                    colors: [AppColor.purple786CFF50, AppColor.blue5AC8FA40],
                  ),
                ),
                child: Icon(icon, color: iconColor),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Center(child: child),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }
}

class _ActivityListItem extends StatelessWidget {
  final String title;
  final String details;
  final String duration;
  const _ActivityListItem({
    required this.title,
    required this.details,
    required this.duration,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 15.h),
      child: Container(
        padding: EdgeInsets.all(15.r),
        decoration: BoxDecoration(
          color: AppColor.gray374151,
          borderRadius: BorderRadius.circular(15.r),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: AppColor.lavenderC7BDFC,
                borderRadius: BorderRadius.circular(30.r),
              ),
              child: Icon(
                Icons.directions_run,
                color: AppColor.customPurple,
                size: 24.r,
              ),
            ),
            SizedBox(width: 15.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.poppinsSemiBold.copyWith(
                      fontSize: 14.sp,
                      color: AppColor.white,
                    ),
                  ),
                  SizedBox(height: 5.h),
                  Text(
                    details,
                    style: AppTextStyles.poppinsRegular.copyWith(
                      fontSize: 12.sp,
                      color: AppColor.lavenderC7BDFC,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 15.w),
            Row(
              children: [
                SvgPicture.asset(
                  ImageAssets.svg30,
                  color: Colors.white,
                  height: 15.h,
                ),
                SizedBox(width: 5.w),
                Text(
                  duration,
                  style: AppTextStyles.poppinsRegular.copyWith(
                    fontSize: 14.sp,
                    color: AppColor.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
