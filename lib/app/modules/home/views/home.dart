// home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:kenzeno/app/modules/home/views/communitypage.dart';
import 'package:kenzeno/app/modules/home/views/dailychallenge.dart';
import 'package:kenzeno/app/modules/home/views/progresstracking.dart';
import 'package:kenzeno/app/modules/home/views/recommendation.dart';
import 'package:kenzeno/app/modules/home/views/resources.dart';
import 'package:kenzeno/app/modules/home/views/search.dart';
import 'package:kenzeno/app/modules/nutrition/views/mealoverall.dart';
import 'package:kenzeno/app/modules/setting/views/profile.dart';
import 'package:kenzeno/app/res/assets/asset.dart';
import '../../../res/colors/colors.dart';
import '../../../res/fonts/textstyle.dart';
import '../../../widgets/workoutcard.dart';
import 'package:kenzeno/app/modules/workout/views/workout.dart';
import 'package:kenzeno/app/modules/workout/controllers/workoutcontroller.dart';
import 'package:kenzeno/app/modules/home/views/articledetails.dart';
import 'package:kenzeno/app/modules/subscription/views/subscription.dart';
import '../../setting/controller/profilecontroller.dart';
import '../controllers/homecontroller.dart';
import 'notification.dart';

class HomeScreen extends StatelessWidget {
  final controller = Get.put(HomeController());
  final profileController = Get.isRegistered<ProfileController>()
      ? Get.find<ProfileController>()
      : Get.put(ProfileController());

  HomeScreen({Key? key}) : super(key: key);

  // Generate real 7-day calendar starting from today
  List<Map<String, dynamic>> get _weekDays {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final List<Map<String, dynamic>> days = [];

    for (int i = 0; i < 7; i++) {
      final date = today.add(Duration(days: i));
      final dayName = DateFormat('EEE').format(date).toUpperCase();
      final dayNumber = date.day;

      final isPreferredDay =
          profileController.profile.value?.preferredWorkoutDays?.any(
            (d) => d.name.toUpperCase() == dayName,
          ) ??
          false;

      days.add({
        'date': dayNumber,
        'day': dayName,
        'fullDate': date,
        'hasActivity': isPreferredDay,
      });
    }
    return days;
  }

  bool get _isTodayWorkoutDay {
    final todayAbbr = DateFormat('EEE').format(DateTime.now()).toUpperCase();
    return profileController.profile.value?.preferredWorkoutDays?.any(
          (day) => day.name.toUpperCase() == todayAbbr,
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    if (profileController.profile.value == null) {
      profileController.fetchProfile();
    }

    return Scaffold(
      backgroundColor: AppColor.black111214,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: AppColor.black111214,
        title: SvgPicture.asset(ImageAssets.svg1, height: 80.h),
        actions: [
          GestureDetector(
            onTap: () =>
                Get.to(() => SearchScreen(), transition: Transition.fadeIn),
            child: Padding(
              padding: EdgeInsets.all(8.w),
              child: SvgPicture.asset(ImageAssets.svg52, height: 20.h),
            ),
          ),
          GestureDetector(
            onTap: () => Get.to(
              () => NotificationScreen(),
              transition: Transition.fadeIn,
            ),
            child: Padding(
              padding: EdgeInsets.all(8.w),
              child: SvgPicture.asset(ImageAssets.svg38, height: 20.h),
            ),
          ),
          GestureDetector(
            onTap: () => Get.to(
              () => MyProfileEditScreen(),
              transition: Transition.rightToLeft,
            ),
            child: Padding(
              padding: EdgeInsets.all(8.w),
              child: SvgPicture.asset(ImageAssets.svg39, height: 20.h),
            ),
          ),
          SizedBox(width: 10.w),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColor.customPurple,
          backgroundColor: AppColor.gray374151,
          onRefresh: () async {
            if (Get.isRegistered<ProfileController>()) {
              await Get.find<ProfileController>().fetchProfile();
            }
            await Future.wait([
              controller.fetchHomeOverview(),
              controller.fetchAllArticles(),
              controller.fetchWorkoutVideos(),
              controller.fetchActivities(),
              controller.loadProgress(),
              controller.fetchRecommendedWorkouts(),
            ]);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                SizedBox(height: 10.h),
                _buildGreeting(),
                SizedBox(height: 10.h),
                _buildWorkoutCard(),
                SizedBox(height: 24.h),
                GestureDetector(
                  onTap: () {
                    if (controller.dailyChallenge.value != null) {
                      Get.to(
                        () => const DailyChallenge(),
                        transition: Transition.rightToLeft,
                      );
                    }
                  },
                  child: _buildDailyChallenge(),
                ),
                SizedBox(height: 24.h),
                _buildRecommendationsSection(),
                SizedBox(height: 24.h),
                _buildArticlesSection(controller),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String get _membershipWeek {
    final diff = DateTime.now().difference(DateTime(2023, 1, 1));
    return (diff.inDays / 7).ceil().toString();
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Obx(() {
            final firstName =
                profileController.profile.value?.fullName?.split(' ').first ??
                'there';

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'WEEK $_membershipWeek',
                  style: AppTextStyles.poppinsMedium.copyWith(
                    fontSize: 14.sp,
                    color: AppColor.gray9CA3AF,
                  ),
                ),
                Text(
                  'HELLO $firstName,',
                  style: AppTextStyles.poppinsBold.copyWith(
                    fontSize: 24.sp,
                    color: Colors.white,
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildGreeting() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWeekCalendar(),
          SizedBox(height: 20.h),
          _buildFeatureRow(),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  Widget _buildWeekCalendar() {
    return Obx(() {
      final today = DateTime.now();
      final todayDate = DateTime(today.year, today.month, today.day);
      final weekDaysList = _weekDays;

      return SizedBox(
        height: 80.h,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: weekDaysList.length,
          itemBuilder: (context, index) {
            final day = weekDaysList[index];
            final isToday = day['fullDate'] == todayDate;

            return Container(
              width: 50.w,
              margin: EdgeInsets.only(right: 12.w),
              child: Column(
                children: [
                  Text(
                    day['day'],
                    style: AppTextStyles.poppinsMedium.copyWith(
                      fontSize: 12.sp,
                      color: AppColor.gray9CA3AF,
                    ),
                  ),
                  SizedBox(height: 5.h),
                  Container(
                    width: 50.w,
                    height: 50.h,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: isToday
                          ? Border.all(color: AppColor.customPurple, width: 2)
                          : null,
                      color: Colors.transparent,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${day['date']}',
                          style: AppTextStyles.poppinsSemiBold.copyWith(
                            fontSize: 18.sp,
                            color: Colors.white,
                          ),
                        ),
                        if (day['hasActivity'] == true)
                          Container(
                            width: 6.w,
                            height: 6.h,
                            margin: EdgeInsets.only(top: 4.h),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                          )
                        else
                          SizedBox(height: 8.h),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    });
  }

  Widget _buildFeatureRow() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Obx(() {
              final isActive = _isTodayWorkoutDay;
              return _buildFeatureColumn(
                svgPath: ImageAssets.svg41,
                label: 'Workout',
                iconColor: isActive ? AppColor.customPurple : AppColor.white,
                textColor: isActive ? AppColor.customPurple : AppColor.white,
                onTap: () => Get.to(
                  () => const Workout(isPop: true),
                  transition: Transition.rightToLeft,
                ),
              );
            }),
            _buildDivider(),
            _buildFeatureColumn(
              svgPath: ImageAssets.svg43,
              label: 'Progress',
              iconColor: AppColor.white,
              textColor: AppColor.white,
              onTap: () => Get.to(
                () => ProgressTrackingScreen(),
                transition: Transition.rightToLeft,
              ),
            ),
            _buildDivider(),
            _buildFeatureColumn(
              svgPath: ImageAssets.svg47,
              label: 'Nutrition',
              iconColor: AppColor.white,
              textColor: AppColor.white,
              onTap: () => Get.to(
                () => MealIdeasPage(),
                transition: Transition.rightToLeft,
              ),
            ),
            _buildDivider(),
            _buildFeatureColumn(
              svgPath: ImageAssets.svg48,
              label: 'Community',
              iconColor: AppColor.white,
              textColor: AppColor.white,
              onTap: () => Get.to(
                () => CommunityPage(),
                transition: Transition.rightToLeft,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1.w,
      height: 40.h,
      color: Colors.white.withValues(alpha: 0.1),
    );
  }

  Widget _buildFeatureColumn({
    required String svgPath,
    required String label,
    required Color iconColor,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColor.white15,
            ),
            child: SvgPicture.asset(
              svgPath,
              width: 24.w,
              height: 24.h,
              colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            label,
            style: AppTextStyles.poppinsMedium.copyWith(
              fontSize: 10.sp,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutCard() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: AppColor.black232323,
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(width: 1, color: AppColor.gray9CA3AF),
        ),
        child: Obx(() {
          if (controller.isLoadingHomeOverview.value) {
            return SizedBox(
              height: 180.h,
              child: const Center(
                child: CircularProgressIndicator(color: AppColor.customPurple),
              ),
            );
          }

          final session = controller.dailyWorkoutSession.value;
          final coachImg = profileController.activeCoachImagePath;
          final List<String> previewImages = [
            coachImg,
            ImageAssets.img_4,
            ImageAssets.img_5,
            ImageAssets.img_3,
          ];

          if (session == null) {
            return SizedBox(
              height: 120.h,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.fitness_center,
                      color: AppColor.gray9CA3AF,
                      size: 28.sp,
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      "No daily workout session available",
                      style: AppTextStyles.poppinsMedium.copyWith(
                        color: AppColor.gray9CA3AF,
                        fontSize: 14.sp,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final durationText =
              session.estimatedDuration.isNotEmpty &&
                  session.estimatedDuration != 'N/A'
              ? session.estimatedDuration
              : '45 minutes';

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFA855F7), Color(0xFFD8B4FE)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.fitness_center_rounded,
                          color: Colors.white,
                          size: 14.sp,
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          'Daily Workout Session',
                          style: AppTextStyles.poppinsBold.copyWith(
                            fontSize: 12.sp,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (session.difficulty.isNotEmpty)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColor.white15,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        session.difficulty.toUpperCase(),
                        style: AppTextStyles.poppinsMedium.copyWith(
                          fontSize: 10.sp,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: 12.h),
              Text(
                durationText,
                style: AppTextStyles.poppinsBold.copyWith(
                  fontSize: 38.sp,
                  color: Colors.white,
                  height: 1.1,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                session.name,
                style: AppTextStyles.poppinsSemiBold.copyWith(
                  fontSize: 16.sp,
                  color: AppColor.customPurple,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (session.description.isNotEmpty) ...[
                SizedBox(height: 4.h),
                Text(
                  session.description,
                  style: AppTextStyles.poppinsRegular.copyWith(
                    fontSize: 13.sp,
                    color: AppColor.gray9CA3AF,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              SizedBox(height: 16.h),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 50.h,
                      child: Stack(
                        children: List.generate(previewImages.length, (index) {
                          return Positioned(
                            left: index * 42.w,
                            child: Container(
                              width: 65.w,
                              height: 50.h,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16.r),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  width: 2.w,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16.r),
                                child: Image.asset(
                                  previewImages[index],
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  GestureDetector(
                    onTap: () {
                      final workoutController =
                          Get.isRegistered<WorkoutController>()
                          ? Get.find<WorkoutController>()
                          : Get.put(WorkoutController());
                      workoutController.loadWorkoutDetail(session.id);
                    },
                    child: Container(
                      width: 50.w,
                      height: 50.h,
                      decoration: BoxDecoration(
                        color: AppColor.purple896CFE,
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Icon(
                        Icons.arrow_forward,
                        color: Colors.black,
                        size: 22.h,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildDailyChallenge() {
    return Obx(() {
      final challenge = controller.dailyChallenge.value;
      final hasChallenge = challenge != null;

      return Container(
        color: AppColor.purpleRoyal,
        padding: EdgeInsets.all(15.w),
        child: Container(
          height: 120.h,
          decoration: BoxDecoration(
            color: AppColor.black111214,
            borderRadius: BorderRadius.circular(24.r),
          ),
          child: hasChallenge
              ? Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 14.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Wrap(
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8.w,
                                    vertical: 3.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColor.customPurple.withValues(
                                      alpha: 0.2,
                                    ),
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  child: Text(
                                    'DAILY CHALLENGE',
                                    style: AppTextStyles.poppinsBold.copyWith(
                                      fontSize: 10.sp,
                                      color: AppColor.customPurple,
                                    ),
                                  ),
                                ),
                                if (challenge.completionPoints > 0) ...[
                                  SizedBox(width: 6.w),
                                  Text(
                                    '+${challenge.completionPoints} pts',
                                    style: AppTextStyles.poppinsSemiBold
                                        .copyWith(
                                          fontSize: 11.sp,
                                          color: Colors.amberAccent,
                                        ),
                                  ),
                                ],
                              ],
                            ),
                            SizedBox(height: 6.h),
                            Text(
                              challenge.name,
                              style: AppTextStyles.poppinsBold.copyWith(
                                fontSize: 16.sp,
                                color: Colors.white,
                                height: 1.2,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              challenge.description.isNotEmpty
                                  ? challenge.description
                                  : "${challenge.exerciseCount} exercises · ${challenge.estimatedDuration} min",
                              style: AppTextStyles.poppinsRegular.copyWith(
                                fontSize: 11.sp,
                                color: Colors.white70,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(24.r),
                        bottomRight: Radius.circular(24.r),
                      ),
                      child: Image.asset(
                        ImageAssets.img_17,
                        height: 120.h,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                )
              : Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.emoji_events_outlined,
                              color: AppColor.gray9CA3AF,
                              size: 22.sp,
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              'Daily Challenge',
                              style: AppTextStyles.poppinsBold.copyWith(
                                fontSize: 16.sp,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          'No daily challenge available today. Check back tomorrow!',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.poppinsRegular.copyWith(
                            fontSize: 12.sp,
                            color: AppColor.gray9CA3AF,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      );
    });
  }

  Widget _buildRecommendationsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recommendations',
                style: AppTextStyles.poppinsBold.copyWith(
                  fontSize: 18.sp,
                  color: Colors.white,
                ),
              ),
              GestureDetector(
                onTap: () => Get.to(
                  () => Recommendation(),
                  transition: Transition.rightToLeft,
                ),
                child: Row(
                  children: [
                    Text(
                      'See All',
                      style: AppTextStyles.poppinsBold.copyWith(
                        fontSize: 16.sp,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 5.w),
                    SvgPicture.asset(
                      ImageAssets.svg23,
                      height: 10.h,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        Obx(() {
          if (controller.isLoading.value) {
            return SizedBox(
              height: 180.h,
              child: Center(
                child: CircularProgressIndicator(color: AppColor.customPurple),
              ),
            );
          }
          if (controller.recommendedWorkouts.isEmpty) {
            return SizedBox(
              height: 180.h,
              child: Center(
                child: Text(
                  "No recommendations yet",
                  style: TextStyle(color: AppColor.gray9CA3AF),
                ),
              ),
            );
          }
          return SizedBox(
            height: 200.h,
            child: ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              scrollDirection: Axis.horizontal,
              itemCount: controller.recommendedWorkouts.length,
              separatorBuilder: (_, __) => SizedBox(width: 15.w),
              itemBuilder: (context, index) {
                final workout = controller.recommendedWorkouts[index];
                return Container(
                  width: 160.w,
                  child: WorkoutCardWidget(
                    title: workout.name,
                    duration: workout.estimatedDuration,
                    exercises: "${workout.exerciseCount} exercises",
                    imagePath:
                        (workout.image != null && workout.image!.isNotEmpty)
                        ? workout.image!
                        : profileController.activeCoachImagePath,
                    isFavorite: workout.isFavorite,
                    onFavoriteToggle: () => controller.toggleFavorite(
                      contentType: 'userworkout',
                      id: workout.id,
                    ),
                    onTap: () {
                      final workoutController =
                          Get.isRegistered<WorkoutController>()
                          ? Get.find<WorkoutController>()
                          : Get.put(WorkoutController());
                      workoutController.loadWorkoutDetail(workout.id);
                    },
                  ),
                );
              },
            ),
          );
        }),
      ],
    );
  }

  Widget _buildArticlesSection(HomeController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Articles & Tips',
                style: AppTextStyles.poppinsBold.copyWith(
                  fontSize: 20.sp,
                  color: Colors.white,
                ),
              ),
              GestureDetector(
                onTap: () => Get.to(
                  () => ResourcesTabScreen(),
                  transition: Transition.rightToLeft,
                ),
                child: Row(
                  children: [
                    Text(
                      'See all',
                      style: AppTextStyles.poppinsBold.copyWith(
                        fontSize: 16.sp,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 5.w),
                    SvgPicture.asset(ImageAssets.svg23, height: 10.h),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        Obx(() {
          final profile = profileController.profile.value;
          final isDobMissing =
              !profileController.isLoading.value &&
              (profile.id != null || profile.email != null) &&
              profile.isDateOfBirthMissing;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isDobMissing)
                GestureDetector(
                  onTap: () => Get.to(
                    () => MyProfileEditScreen(),
                    transition: Transition.rightToLeft,
                  ),
                  child: Container(
                    margin: EdgeInsets.only(left: 10.w, right: 10.w, top: 8.h),
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColor.customPurple.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: AppColor.customPurple.withOpacity(0.4),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: AppColor.customPurple,
                          size: 18.sp,
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            "Add Date of Birth in Profile for age-tailored tips.",
                            style: AppTextStyles.poppinsRegular.copyWith(
                              color: Colors.white,
                              fontSize: 11.sp,
                            ),
                          ),
                        ),
                        Text(
                          "Add",
                          style: AppTextStyles.poppinsBold.copyWith(
                            color: AppColor.customPurple,
                            fontSize: 12.sp,
                          ),
                        ),
                        Icon(
                          Icons.chevron_right,
                          color: AppColor.customPurple,
                          size: 16.sp,
                        ),
                      ],
                    ),
                  ),
                ),
              SizedBox(height: 12.h),
              if (controller.isLoading.value)
                SizedBox(
                  height: 240.h,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColor.customPurple,
                    ),
                  ),
                )
              else if (controller.articles.isEmpty)
                SizedBox(
                  height: 240.h,
                  child: Center(
                    child: Text(
                      "No articles available",
                      style: TextStyle(color: AppColor.gray9CA3AF),
                    ),
                  ),
                )
              else
                SizedBox(
                  height: 240.h,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    itemCount: controller.articles.length,
                    separatorBuilder: (_, __) => SizedBox(width: 16.w),
                    itemBuilder: (context, index) {
                      final article = controller.articles[index];
                      final mediaUrl = article.mediaUrl;
                      final hasUrl = mediaUrl != null && mediaUrl.isNotEmpty;

                      return GestureDetector(
                        onTap: () {
                          Get.to(
                            () => const ArticleDetailPage(),
                            arguments: article.id,
                            transition: Transition.rightToLeft,
                          );
                        },
                        child: Column(
                          children: [
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(30.r),
                                    bottomLeft: Radius.circular(30.r),
                                    topRight: Radius.circular(20.r),
                                    bottomRight: Radius.circular(20.r),
                                  ),
                                  child: hasUrl
                                      ? (mediaUrl.startsWith('http')
                                            ? Image.network(
                                                mediaUrl,
                                                width: 160.w,
                                                height: 130.h,
                                                fit: BoxFit.cover,
                                                errorBuilder: (_, __, ___) =>
                                                    Image.asset(
                                                      ImageAssets.img_3,
                                                      width: 160.w,
                                                      height: 130.h,
                                                      fit: BoxFit.cover,
                                                    ),
                                              )
                                            : Image.asset(
                                                mediaUrl,
                                                width: 160.w,
                                                height: 130.h,
                                                fit: BoxFit.cover,
                                                errorBuilder: (_, __, ___) =>
                                                    Image.asset(
                                                      ImageAssets.img_3,
                                                      width: 160.w,
                                                      height: 130.h,
                                                      fit: BoxFit.cover,
                                                    ),
                                              ))
                                      : Image.asset(
                                          ImageAssets.img_3,
                                          width: 160.w,
                                          height: 130.h,
                                          fit: BoxFit.cover,
                                        ),
                                ),
                                Positioned(
                                  top: 6.h,
                                  right: 6.w,
                                  child: GestureDetector(
                                    onTap: () => controller.toggleFavorite(
                                      contentType: 'article',
                                      id: article.id,
                                    ),
                                    child: SvgPicture.asset(
                                      ImageAssets.svg33,
                                      colorFilter: ColorFilter.mode(
                                        article.isFavorite
                                            ? AppColor.customPurple
                                            : Colors.white,
                                        BlendMode.srcIn,
                                      ),
                                      height: 20.h,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8.h),
                            SizedBox(
                              width: 150.w,
                              child: Text(
                                article.title,
                                style: AppTextStyles.poppinsMedium.copyWith(
                                  fontSize: 14.sp,
                                  color: Colors.white,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                            ),
                            SizedBox(height: 5.h),
                            Text(
                              article.category ?? "",
                              style: AppTextStyles.poppinsRegular.copyWith(
                                fontSize: 12.sp,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
            ],
          );
        }),
      ],
    );
  }
}
