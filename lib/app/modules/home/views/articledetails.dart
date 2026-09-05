import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../../res/colors/colors.dart';
import '../../../res/fonts/textstyle.dart';
import '../../../res/assets/asset.dart';
import '../../../widgets/backbutton_widget.dart';
import '../controllers/homecontroller.dart'; // ← Only this import added

class ArticleDetailPage extends StatelessWidget {
  const ArticleDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.find<HomeController>();

    // Get the article ID passed from the list
    final int articleId = Get.arguments as int;

    // Trigger fetch only if it's a different article (prevents unnecessary calls)
    if (controller.selectedArticle.value?.id != articleId) {
      controller.fetchArticleDetail(articleId);
    }

    return Scaffold(
      body: Obx(() {
        // Loading
        if (controller.isLoadingArticle.value) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }

        // Error / Not found
        if (controller.selectedArticle.value == null) {
          return const Center(
            child: Text(
              "Article not found",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          );
        }

        final art = controller.selectedArticle.value!;
        final publishDate = art.createdAt.toLocal().toString().split(' ')[0];

        return CustomScrollView(
          slivers: [
            _buildSliverAppBar(context, art.title, publishDate, art.mediaUrl),
            SliverList(
              delegate: SliverChildListDelegate([
                _buildArticleDetails(art.content),
                // If you still want sections in future, just map them here
                // For now we keep it simple with just the full content
                SizedBox(height: 30.h),
              ]),
            ),
          ],
        );
      }),
    );
  }

  // ← Your EXACT SliverAppBar (only data changed to dynamic)
  Widget _buildSliverAppBar(
    BuildContext context,
    String title,
    String publishDate,
    String? mediaUrl,
  ) {
    return SliverAppBar(
      automaticallyImplyLeading: false,
      backgroundColor: AppColor.black111214,
      expandedHeight: 480.h,
      pinned: true,
      elevation: 0,
      leading: const BackButtonBox(),
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: false,
        titlePadding: EdgeInsets.only(left: 20.w, bottom: 0),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: AppTextStyles.poppinsBold.copyWith(
                color: Colors.white,
                fontSize: 16.sp,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 4.h),
            Row(
              children: [
                Icon(Icons.access_time, color: AppColor.gray9CA3AF, size: 12.r),
                SizedBox(width: 4.w),
                Text(
                  'Published On $publishDate',
                  style: AppTextStyles.poppinsRegular.copyWith(
                    color: AppColor.gray9CA3AF,
                    fontSize: 10.sp,
                  ),
                ),
              ],
            ),
          ],
        ),
        background: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: kToolbarHeight + 6.h),
            Center(
              child: Text(
                'Resources',
                style: AppTextStyles.poppinsBold.copyWith(
                  color: Colors.white,
                  fontSize: 20.sp,
                ),
              ),
            ),
            SizedBox(height: 20.h),
            Padding(
              padding: EdgeInsets.only(left: 20.w, right: 20.w),
              child: Text(
                title,
                style: AppTextStyles.poppinsBold.copyWith(
                  color: Colors.white,
                  fontSize: 22.sp,
                ),
              ),
            ),
            SizedBox(height: 8.h),
            Padding(
              padding: EdgeInsets.only(left: 20.w, right: 20.w),
              child: Row(
                children: [
                  Icon(
                    Icons.access_time,
                    color: AppColor.gray9CA3AF,
                    size: 14.r,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    'Published On $publishDate',
                    style: AppTextStyles.poppinsRegular.copyWith(
                      color: AppColor.gray9CA3AF,
                      fontSize: 14.sp,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),

            // Feature Image with Purple padding + Star (now uses network image)
            Stack(
              children: [
                Container(
                  padding: EdgeInsets.all(12.w),
                  color: AppColor.customPurple,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20.r),
                    child: mediaUrl != null
                        ? Image.network(
                            mediaUrl,
                            height: 250.h,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Image.asset(
                              ImageAssets.img_3, // fallback
                              height: 250.h,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Image.asset(
                            ImageAssets.img_3,
                            height: 250.h,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
                Positioned(
                  top: 15.h,
                  right: 15.w,
                  child: SvgPicture.asset(
                    ImageAssets.svg33,
                    height: 30.r,
                    width: 30.r,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ← Your exact article body
  Widget _buildArticleDetails(String contentSummary) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      child: Text(
        contentSummary,
        style: AppTextStyles.poppinsRegular.copyWith(
          color: AppColor.white,
          fontSize: 14.sp,
          height: 1.5,
        ),
      ),
    );
  }
}
