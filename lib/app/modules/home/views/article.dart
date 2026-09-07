import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:kenzeno/app/modules/home/controllers/homecontroller.dart';
import 'package:kenzeno/app/res/assets/asset.dart';
import 'package:kenzeno/app/modules/setting/controller/profilecontroller.dart';
import 'package:kenzeno/app/modules/setting/views/profile.dart';
import '../../../res/colors/colors.dart';
import '../../../res/fonts/textstyle.dart';
import '../../setting/widgets/trainnigstep.dart';
import 'articledetails.dart';

class ArticlePage extends StatelessWidget {
  const ArticlePage({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.put(HomeController());
    final profileController = Get.isRegistered<ProfileController>()
        ? Get.find<ProfileController>()
        : null;

    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final isDobMissing = profileController?.profile.value == null ||
            profileController?.profile.value?.dateOfBirth == null ||
            profileController!.profile.value!.dateOfBirth!.trim().isEmpty;

        if (controller.articles.isEmpty) {
          return Center(
            child: Text(
              "No articles available",
              style: AppTextStyles.poppinsRegular.copyWith(
                color: AppColor.white,
                fontSize: 16.sp,
              ),
            ),
          );
        }

        return Column(
          children: [
            if (isDobMissing)
              GestureDetector(
                onTap: () => Get.to(
                  () => MyProfileEditScreen(),
                  transition: Transition.rightToLeft,
                ),
                child: Container(
                  margin: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 4.h),
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                  decoration: BoxDecoration(
                    color: AppColor.customPurple.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(
                      color: AppColor.customPurple.withOpacity(0.4),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppColor.customPurple,
                        size: 20.sp,
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Text(
                          "Add Date of Birth in Profile for age-tailored tips.",
                          style: AppTextStyles.poppinsRegular.copyWith(
                            color: Colors.white,
                            fontSize: 12.sp,
                          ),
                        ),
                      ),
                      Text(
                        "Add",
                        style: AppTextStyles.poppinsBold.copyWith(
                          color: AppColor.customPurple,
                          fontSize: 13.sp,
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: AppColor.customPurple,
                        size: 18.sp,
                      ),
                    ],
                  ),
                ),
              ),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(vertical: 10.h),
                itemCount: controller.articles.length,
                itemBuilder: (context, index) {
                  final article = controller.articles[index];

                  return TrainingCardWidget(
                    title: article.title,
                    subtitle: article.category,
                    imagePath: article.mediaUrl ?? ImageAssets.img_3,
                    type: 'article',
                    duration: '0 min',
                    calories: '0 kcal',
                    exercises: '0 exercises',
                    isVideo: false,
                    isFavorite: article.isFavorite,
                    onFavoriteToggle: () => controller.toggleFavorite(
                      contentType: 'article',
                      id: article.id,
                    ),
                    onTap: () {
                      Get.to(
                        () => const ArticleDetailPage(),
                        arguments: article.id, // Only ID needed!
                        transition: Transition.rightToLeft,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      }),
    );
  }
}
