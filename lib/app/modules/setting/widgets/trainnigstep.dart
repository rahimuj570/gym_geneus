import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../res/colors/colors.dart';
import '../../../res/fonts/textstyle.dart';
import '../../../res/assets/asset.dart';

class TrainingCardWidget extends StatelessWidget {
  final String title;
  final String duration;
  final String calories;
  final String exercises;
  final String imagePath;
  final bool isVideo;
  final String type;
  final String? subtitle;
  final VoidCallback? onTap;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;

  const TrainingCardWidget({
    super.key,
    required this.title,
    required this.duration,
    required this.calories,
    required this.exercises,
    required this.imagePath,
    required this.type,
    this.isVideo = false,
    this.subtitle,
    this.onTap,
    this.isFavorite = false,
    this.onFavoriteToggle,
  });

  // Check if the card is for an Article
  bool get isArticle => type.toLowerCase() == 'article';

  @override
  Widget build(BuildContext context) {
    // WRAP THE ENTIRE WIDGET CONTENT IN A GestureDetector
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 5.h),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8.r,
                offset: Offset(0, 4.h),
              ),
            ],
          ),
          child: Row(
            children: [
              // Left: Text Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        16.w,
                        4.h,
                        16.w,
                        isArticle ? 4.h : 8.h,
                      ),
                      child: Text(
                        title,
                        style: AppTextStyles.poppinsBold.copyWith(
                          color: AppColor.black232323,
                          fontSize: 16.sp,
                        ),
                      ),
                    ),

                    // Conditional Content Area: Subtitle for Article, Info Rows for Video
                    Padding(
                      padding: EdgeInsets.fromLTRB(16.w, 0, 5.w, 16.h),
                      child: isArticle
                          ? _buildSubtitle(
                              subtitle,
                            ) // Show subtitle for Article
                          : _buildInfoWrap(), // Show info rows for Video/Default
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12.w),
              // Right: Image with optional play/star
              _buildImageSection(context),
            ],
          ),
        ),
      ),
    );
  }

  // Widget for displaying a descriptive subtitle (for Articles)
  Widget _buildSubtitle(String? text) {
    return Text(
      text ?? 'No description available...',
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
      style: AppTextStyles.poppinsRegular.copyWith(
        color: AppColor.gray9CA3AF, // Lighter color for subtitle
        fontSize: 12.sp,
      ),
    );
  }

  // Widget for displaying the duration/calories/exercises info (for Videos)
  Widget _buildInfoWrap() {
    return Wrap(
      spacing: 12.w,
      runSpacing: 6.h,
      children: [
        _buildInfoRow(
          ImageAssets.svg30,
          duration,
        ), // Assuming svg30 is clock/duration icon
        _buildInfoRow(
          ImageAssets.svg31,
          calories,
        ), // Assuming svg31 is fire/calorie icon
        _buildInfoRow(
          ImageAssets.svg32,
          exercises,
        ), // Assuming svg32 is running/exercise icon
      ],
    );
  }

  Widget _buildImageSection(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Image Container
        Container(
          width: 120.w,
          height: 100.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30.r),
              bottomLeft: Radius.circular(30.r),
              topRight: Radius.circular(20.r),
              bottomRight: Radius.circular(20.r),
            ),
            image: DecorationImage(
              image: imagePath.isEmpty
                  ? const AssetImage(ImageAssets.img_3) as ImageProvider
                  : (imagePath.startsWith('http')
                      ? NetworkImage(imagePath)
                      : AssetImage(imagePath) as ImageProvider),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(),
        ),

        // Play Button (only if isVideo is true)
        if (isVideo)
          Container(
            padding: EdgeInsets.all(6.r),
            decoration: BoxDecoration(
              color: AppColor.customPurple,
              shape: BoxShape.circle,
            ),
            child: SvgPicture.asset(
              ImageAssets.svg34,
              height: 20.sp,
              width: 20.sp,
              color: AppColor.black111214,
            ),
          ),

        // Star Icon Positioned
        Positioned(
          top: 6.h,
          right: 6.w,
          child: GestureDetector(
            onTap: onFavoriteToggle,
            child: Container(
              padding: EdgeInsets.all(4.r),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
                color: AppColor.black50,
              ),
              child: SvgPicture.asset(
                ImageAssets.svg33,
                height: 18.sp,
                width: 18.sp,
                color: isFavorite ? AppColor.customPurple : Colors.white70,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String svgPath, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(
          svgPath,
          height: 12.sp,
          width: 12.sp,
          color: AppColor.black232323,
        ),
        SizedBox(width: 4.w),
        Text(
          text,
          style: AppTextStyles.poppinsRegular.copyWith(
            color: AppColor.black232323,
            fontSize: 11.sp,
          ),
        ),
      ],
    );
  }
}
