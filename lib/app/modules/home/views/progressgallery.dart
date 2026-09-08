// lib/app/modules/home/views/progressgallery.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';

import '../../../res/colors/colors.dart';
import '../../../res/fonts/textstyle.dart';
import '../controllers/calender_controller.dart';

class ProgressGalleryPage extends StatelessWidget {
  ProgressGalleryPage({super.key});

  final GalleryController controller = Get.find();

  Color _getColorByType(String type) {
    final t = type.toLowerCase().trim();
    if (t.contains('back') || t.contains('rear')) return AppColor.cyan06B6D4;
    if (t.contains('side') || t.contains('lateral') || t.contains('left') || t.contains('right')) return AppColor.green22C55E;
    if (t.contains('front')) return AppColor.customPurple;
    return AppColor.gray9CA3AF;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.black111214,
      appBar: AppBar(
        backgroundColor: AppColor.black111214,
        title: Text(
          'Progress Gallery',
          style: AppTextStyles.poppinsBold.copyWith(
            color: AppColor.white,
            fontSize: 22.sp,
          ),
        ),
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: const Icon(Icons.arrow_back_ios, color: AppColor.white),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColor.customPurple),
          );
        }

        if (controller.galleryImages.isEmpty) {
          return Center(
            child: Text(
              "No photos yet",
              style: TextStyle(color: AppColor.white, fontSize: 18.sp),
            ),
          );
        }

        final isTablet = MediaQuery.of(context).size.width >= 600;

        return Padding(
          padding: EdgeInsets.all(10.w),
          child: GridView.builder(
            itemCount: controller.galleryImages.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isTablet ? 3 : 2,
              crossAxisSpacing: 12.w,
              mainAxisSpacing: 12.h,
              childAspectRatio: isTablet ? 0.85 : 0.7,
            ),
            itemBuilder: (context, index) {
              final img = controller.galleryImages[index];
              final date = DateFormat('MMM dd, yyyy').format(img.uploadedAt);
              final type = img.progressType.label;

              return GestureDetector(
                onTap: () {
                  Get.to(
                    () => FullScreenImagePage(
                      imageUrl: img.imageUrl,
                      date: date,
                      type: type,
                      tagColor: _getColorByType(img.imageType),
                      heroTag: 'gallery_${img.id}',
                    ),
                    transition: Transition.zoom,
                    duration: const Duration(milliseconds: 350),
                  );
                },
                child: Hero(
                  tag: 'gallery_${img.id}',
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColor.gray9CA3AF.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(15.r),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(15.r),
                            ),
                            child: Image.network(
                              img.imageUrl,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              loadingBuilder: (_, child, progress) =>
                                  progress == null
                                  ? child
                                  : Container(
                                      color: AppColor.gray1F2937,
                                      child: const Center(
                                        child: CircularProgressIndicator(
                                          color: AppColor.customPurple,
                                        ),
                                      ),
                                    ),
                              errorBuilder: (_, __, ___) => Container(
                                color: AppColor.gray1F2937,
                                child: const Icon(
                                  Icons.error,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.w),
                          child: Text(
                            date,
                            style: AppTextStyles.poppinsSemiBold.copyWith(
                              color: AppColor.white,
                              fontSize: 12.sp,
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(8.w, 0, 8.w, 8.h),
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 5.h,
                          ),
                          decoration: BoxDecoration(
                            color: _getColorByType(img.imageType),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Text(
                            type,
                            style: AppTextStyles.poppinsSemiBold.copyWith(
                              color: AppColor.white,
                              fontSize: 11.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}

// Full Screen Viewer (inside same file)
class FullScreenImagePage extends StatelessWidget {
  final String imageUrl;
  final String date;
  final String type;
  final Color tagColor;
  final String heroTag;

  const FullScreenImagePage({
    Key? key,
    required this.imageUrl,
    required this.date,
    required this.type,
    required this.tagColor,
    required this.heroTag,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white, size: 30),
          onPressed: () => Get.back(),
        ),
        actions: [
          Container(
            margin: EdgeInsets.only(right: 16.w),
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: tagColor,
              borderRadius: BorderRadius.circular(30.r),
            ),
            child: Text(
              type,
              style: AppTextStyles.poppinsBold.copyWith(
                color: Colors.white,
                fontSize: 13.sp,
              ),
            ),
          ),
          SizedBox(width: 10.w),
        ],
      ),
      body: Stack(
        children: [
          Center(
            child: Hero(
              tag: heroTag,
              child: PhotoView(
                imageProvider: NetworkImage(imageUrl),
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 4,
                loadingBuilder: (context, event) => const Center(
                  child: CircularProgressIndicator(
                    color: AppColor.customPurple,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 50.h,
            left: 20.w,
            child: Text(
              date,
              style: AppTextStyles.poppinsSemiBold.copyWith(
                color: Colors.white,
                fontSize: 18.sp,
                shadows: const [Shadow(color: Colors.black54, blurRadius: 10)],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
