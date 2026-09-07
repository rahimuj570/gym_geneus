import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../res/assets/asset.dart';
import '../res/colors/colors.dart';
import '../res/fonts/textstyle.dart';

class WorkoutCardWidget extends StatelessWidget {
  final String title;
  final String duration;
  final String exercises;
  final String imagePath;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;

  // Add this: onTap callback
  final VoidCallback? onTap;

  const WorkoutCardWidget({
    Key? key,
    required this.title,
    required this.duration,
    required this.exercises,
    required this.imagePath,
    this.onTap, // Make it optional (safe for existing usage)
    this.isFavorite = false,
    this.onFavoriteToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // Use the passed onTap
      child: Container(
        padding: EdgeInsets.only(bottom: 10.w),
        decoration: BoxDecoration(
          color: AppColor.black232323,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(15.r),
                  child: imagePath.isEmpty
                      ? Image.asset(
                          ImageAssets.img_12,
                          height: 100.h,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        )
                      : (imagePath.startsWith('http')
                          ? Image.network(
                              imagePath,
                              height: 100.h,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Image.asset(
                                ImageAssets.img_12,
                                height: 100.h,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Image.asset(
                              imagePath,
                              height: 100.h,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            )),
                ),
                // Star Icon
                Positioned(
                  top: 8.h,
                  right: 8.w,
                  child: GestureDetector(
                    onTap: onFavoriteToggle,
                    child: SvgPicture.asset(
                      ImageAssets.svg33,
                      height: 16.r,
                      width: 16.r,
                      colorFilter: ColorFilter.mode(
                        isFavorite ? AppColor.customPurple : Colors.white,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
                // Play button
                Positioned(
                  bottom: -15.h,
                  right: 12.w,
                  child: Container(
                    padding: EdgeInsets.all(4.r),
                    decoration: BoxDecoration(
                      color: AppColor.customPurple,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColor.customPurple.withOpacity(0.4),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 20.r,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              child: Text(
                title,
                style: AppTextStyles.poppinsBold.copyWith(
                  color: AppColor.white,
                  fontSize: 12.sp,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(height: 5.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              child: Wrap(
                spacing: 4.w,     // horizontal spacing
                runSpacing: 4.h,  // vertical spacing when wrapped
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(
                        ImageAssets.svg30,
                        height: 12.r,
                        width: 12.r,
                        color: AppColor.customPurple,
                      ),
                      SizedBox(width: 5.w),
                      Text(
                        '$duration',
                        style: AppTextStyles.poppinsRegular.copyWith(
                          color: AppColor.white,
                          fontSize: 10.sp,
                        ),
                      ),
                    ],
                  ),

                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(
                        ImageAssets.svg31,
                        height: 12.r,
                        width: 12.r,
                        color: AppColor.customPurple,
                      ),
                      SizedBox(width: 5.w),
                      Text(
                        exercises,
                        style: AppTextStyles.poppinsRegular.copyWith(
                          color: AppColor.white,
                          fontSize: 10.sp,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )


          ],
        ),
      ),
    );
  }
}