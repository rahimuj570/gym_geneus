// favourite.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:kenzeno/app/res/assets/asset.dart';
import 'package:kenzeno/app/widgets/backbutton_widget.dart';

import '../../../constants/appconstants.dart';
import '../../../res/colors/colors.dart';
import '../../../res/fonts/textstyle.dart';
import '../controller/favouritecontroller.dart';
import '../widgets/trainnigstep.dart';

class Favourite extends StatelessWidget {
  final FavouriteController controller = Get.put(FavouriteController());

  Favourite({super.key});

  // Safe preview text (prevents RangeError)
  String _safePreview(String? text) {
    if (text == null || text.isEmpty) return "No preview available";
    if (text.length <= 100) return text.trim();
    return "${text.substring(0, 100).trim()}...";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.black111214,
      appBar: AppBar(
        backgroundColor: AppColor.black111214,
        leading: const BackButtonBox(),
        title: Text(
          "Favorites",
          style: AppTextStyles.poppinsSemiBold.copyWith(
            fontSize: 20.sp,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.search, color: Colors.white, size: 25.h),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 10.h),

          // Sort By + Tabs
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              children: [
                Text(
                  'Sort By',
                  style: AppTextStyles.poppinsRegular.copyWith(
                    color: Colors.white,
                    fontSize: 12.sp,
                  ),
                ),
                _buildCategoryTabBar(),
              ],
            ),
          ),

          SizedBox(height: 20.h),

          // Main List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppColor.customPurple,
                  ),
                );
              }

              final list = controller.filteredFavorites;

              if (list.isEmpty) {
                return Center(
                  child: Text(
                    'No favorites yet.',
                    style: AppTextStyles.poppinsRegular.copyWith(
                      color: AppColor.gray9CA3AF,
                      fontSize: 16.sp,
                    ),
                  ),
                );
              }

              return ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final item = list[index];
                  final obj = item.object;

                  // Determine image URL

                  final String imageUrl = obj.displayImage.isEmpty
                      ? ImageAssets
                            .img_16 // local fallback
                      : (obj.displayImage.startsWith('http') ||
                                obj.displayImage.startsWith('assets/')
                            ? obj
                                  .displayImage // use as-is
                            : "${AppConstants.baseUrimage}/${obj.displayImage}");

                  return TrainingCardWidget(
                    title: obj.title,
                    duration: obj.isArticle
                        ? "Read time · 5 min"
                        : (obj.estimatedDuration ?? "Unknown duration"),
                    calories: obj.isArticle
                        ? "Article"
                        : (obj.estimatedCalories ?? "Unknown calories"),
                    exercises: obj.isArticle
                        ? (obj.category?.toUpperCase() ?? "FITNESS")
                        : "${obj.exerciseCount ?? 0} Exercises",
                    imagePath: imageUrl,
                    isVideo: !obj.isArticle,
                    type: obj.isArticle ? 'Article' : 'Video',
                    subtitle: obj.isArticle
                        ? _safePreview(obj.content)
                        : (obj.description ?? "No description"),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  // Category Tabs (All / Workouts / Articles)
  Widget _buildCategoryTabBar() {
    return Expanded(
      // ← THIS IS THE FIX
      child: Padding(
        padding: EdgeInsets.only(left: 20.w),
        child: Obx(
          () => SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(controller.categories.length, (i) {
                final bool isSelected = controller.selectedIndex.value == i;

                return Padding(
                  padding: EdgeInsets.only(right: 10.w),
                  child: GestureDetector(
                    onTap: () => controller.selectCategory(i),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColor.customPurple
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(30.r),
                        border: Border.all(
                          color: isSelected
                              ? AppColor.customPurple
                              : AppColor.white30,
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        controller.categories[i],
                        style: AppTextStyles.poppinsMedium.copyWith(
                          color: isSelected
                              ? Colors.white
                              : AppColor.customPurple,
                          fontSize: 12.sp,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
