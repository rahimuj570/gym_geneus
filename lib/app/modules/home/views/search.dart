import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:kenzeno/app/modules/home/controllers/searchcontroller.dart';
import 'package:kenzeno/app/modules/workout/controllers/workoutcontroller.dart';
import 'package:kenzeno/app/modules/workout/views/workoutdetails.dart';
import 'package:kenzeno/app/modules/setting/controller/profilecontroller.dart';
import '../../../res/assets/asset.dart';
import '../../../res/colors/colors.dart';
import '../../../res/fonts/textstyle.dart';
import '../../../widgets/backbutton_widget.dart';
import '../../setting/widgets/trainnigstep.dart';

class SearchScreen extends StatelessWidget {
  final SearchController2 controller = Get.find();
  final workoutController = Get.find<WorkoutController>();

  SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColor.black111214,
      appBar: AppBar(
        backgroundColor: AppColor.black111214,
        elevation: 0,
        leading: const BackButtonBox(),
        centerTitle: true,
        title: Text(
          "Search",
          style: AppTextStyles.poppinsBold.copyWith(
            fontSize: 20.sp,
            color: Colors.white,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 10.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: _buildSearchField(),
            ),
            SizedBox(height: 20.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              child: _buildCategoryTabs(context),
            ),
            SizedBox(height: 10.h),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value &&
                    controller.workoutResults.isEmpty &&
                    controller.articleResults.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                }

                return TabBarView(
                  controller: controller.tabController,
                  children: [
                    // ALL Results
                    _buildResultsList(
                      workouts: controller.workoutResults,
                      articles: controller.articleResults,
                    ),
                    // Workouts ONLY
                    _buildResultsList(
                      workouts: controller.workoutResults,
                      articles: [],
                    ),
                    // Articles ONLY
                    _buildResultsList(
                      workouts: [],
                      articles: controller.articleResults,
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      height: 48.h,
      decoration: BoxDecoration(
        color: AppColor.gray374151,
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: AppColor.purple9662F1.withOpacity(0.3)),
      ),
      child: TextField(
        controller: controller.searchController,
        onSubmitted: (value) => controller.performSearch(value),
        textInputAction: TextInputAction.search,
        style: AppTextStyles.poppinsRegular.copyWith(
          color: Colors.white,
          fontSize: 16.sp,
        ),
        cursorColor: AppColor.purple9662F1,
        decoration: InputDecoration(
          hintText: "Search workouts, articles...",
          hintStyle: AppTextStyles.poppinsRegular.copyWith(
            color: AppColor.gray9CA3AF,
            fontSize: 14.sp,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: AppColor.purple9662F1,
            size: 24.sp,
          ),
          suffixIcon: Obx(() => controller.searchBarText.value.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.white),
                  onPressed: () {
                    controller.searchController.clear();
                    controller.performSearch("");
                  },
                )
              : const SizedBox.shrink()),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 12.h),
        ),
      ),
    );
  }

  Widget _buildCategoryTabs(BuildContext context) {
    return Obx(() {
      return TabBar(
        controller: controller.tabController,
        isScrollable: false,
        padding: EdgeInsets.zero,
        labelPadding: EdgeInsets.zero,
        indicatorColor: Colors.transparent,
        dividerColor: Colors.transparent,
        tabs: controller.categories.map((category) {
          final index = controller.categories.indexOf(category);
          final isSelected = controller.selectedIndex.value == index;
          return Tab(
            child: Container(
              alignment: Alignment.center,
              margin: EdgeInsets.symmetric(horizontal: 5.w),
              padding: EdgeInsets.symmetric(vertical: 8.h),
              decoration: BoxDecoration(
                color: isSelected ? AppColor.customPurple : AppColor.gray374151,
                borderRadius: BorderRadius.circular(25.r),
              ),
              child: Text(
                category,
                style: AppTextStyles.poppinsMedium.copyWith(
                  color: Colors.white,
                  fontSize: 13.sp,
                ),
              ),
            ),
          );
        }).toList(),
      );
    });
  }

  Widget _buildResultsList({
    required List<dynamic> workouts,
    required List<dynamic> articles,
  }) {
    return RefreshIndicator(
      color: AppColor.customPurple,
      backgroundColor: AppColor.gray374151,
      onRefresh: () async {
        await controller.performSearch(controller.searchController.text);
      },
      child: (workouts.isEmpty && articles.isEmpty)
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(height: 150.h),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, size: 64.sp, color: AppColor.gray9CA3AF),
                      SizedBox(height: 16.h),
                      Text(
                        "No results found",
                        style: AppTextStyles.poppinsMedium.copyWith(
                          color: AppColor.gray9CA3AF,
                          fontSize: 16.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(vertical: 10.h),
              children: [
                if (workouts.isNotEmpty) ...[
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                    child: Text(
                      "Workouts",
                      style: AppTextStyles.poppinsBold.copyWith(
                        color: Colors.white,
                        fontSize: 18.sp,
                      ),
                    ),
                  ),
                  ...workouts.map((workout) => TrainingCardWidget(
                        title: workout.name,
                        duration: workout.estimatedDuration,
                        calories: workout.estimatedCalories,
                        exercises: "${workout.exerciseCount} Exercises",
                        imagePath: (workout.image != null && workout.image!.isNotEmpty)
                            ? workout.image!
                            : (Get.isRegistered<ProfileController>()
                                ? Get.find<ProfileController>().activeCoachImagePath
                                : ImageAssets.img_12),
                        type: 'workout', // Changed from 'video' to match API or keep as per UI needs
                        isVideo: false,
                        isFavorite: workout.isFavorite,
                        onFavoriteToggle: () => controller.toggleFavorite(
                          contentType: 'workoutvideo',
                          id: workout.id,
                        ),
                        onTap: () {
                          workoutController.loadWorkoutDetail(workout.id);
                        },
                      )),
                ],
                if (articles.isNotEmpty) ...[
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                    child: Text(
                      "Articles",
                      style: AppTextStyles.poppinsBold.copyWith(
                        color: Colors.white,
                        fontSize: 18.sp,
                      ),
                    ),
                  ),
                  ...articles.map((article) => TrainingCardWidget(
                        title: article.title,
                        subtitle: article.content,
                        imagePath: (article.mediaUrl != null && article.mediaUrl!.isNotEmpty)
                            ? article.mediaUrl!
                            : ImageAssets.img_1,
                        type: 'article',
                        isFavorite: article.isFavorite,
                        onFavoriteToggle: () => controller.toggleFavorite(
                          contentType: 'article',
                          id: article.id,
                        ),
                        onTap: () {
                          // Navigation to article details if available
                        },
                        duration: '',
                        calories: '',
                        exercises: '',
                      )),
                ],
                SizedBox(height: 50.h),
              ],
            ),
    );
  }
}
