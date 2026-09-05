import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../res/colors/colors.dart';

import '../controllers/post_controller.dart';
import '../widgets/postcard.dart';
import 'package:toastification/toastification.dart';
import 'package:kenzeno/app/res/fonts/textstyle.dart';
import 'package:kenzeno/app/res/colors/colors.dart';

class DiscussionForumPage extends StatelessWidget {
  DiscussionForumPage({super.key});

  // Controller for text input
  final TextEditingController textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ForumController());

    // Fixed Post Creation Box — exactly the same as yours
    final Widget postInputBar = Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColor.gray1F2937,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColor.customPurple.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22.r,
            backgroundImage: const NetworkImage(
              "https://randomuser.me/api/portraits/men/86.jpg",
            ),
            backgroundColor: AppColor.gray9CA3AF,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: TextField(
              controller: textController,
              style: TextStyle(color: AppColor.white, fontSize: 16.sp),
              decoration: InputDecoration(
                hintText: "Share your opinion ",
                hintStyle: TextStyle(
                  color: AppColor.white.withOpacity(0.5),
                  fontSize: 15.sp,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
          SizedBox(width: 10.w),

          // SEND BUTTON — NOW WORKS PERFECTLY
          GestureDetector(
            onTap: controller.isPosting.value
                ? null
                : () async {
                    final text = textController.text.trim();
                    if (text.isEmpty) {
                      toastification.show(
                        type: ToastificationType.info,
                        style: ToastificationStyle.fillColored,
                        primaryColor: AppColor.green16A34A,
                        foregroundColor: Colors.white,
                        title: Text(
                          "Empty",
                          style: AppTextStyles.poppinsBold.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        description: Text(
                          "Write something first",
                          style: AppTextStyles.poppinsRegular.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        alignment: Alignment.topRight,
                        autoCloseDuration: const Duration(seconds: 4),
                        borderRadius: BorderRadius.circular(12),
                        showProgressBar: true,
                      );
                      return;
                    }
                    final success = await controller.createForumPost(
                      content: text,
                    );
                    Get.closeAllSnackbars();

                    if (success) {
                      textController.clear();
                      // No need to call fetchPosts() — new post is added instantly
                    }
                  },
            child: Obx(
              () => Container(
                padding: EdgeInsets.all(10.r),
                decoration: const BoxDecoration(
                  color: AppColor.customPurple,
                  shape: BoxShape.circle,
                ),
                child: controller.isPosting.value
                    ? CircularProgressIndicator(
                        color: AppColor.white,
                        strokeWidth: 2,
                      )
                    : Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 22.sp,
                      ),
              ),
            ),
          ),
        ],
      ),
    );

    return Scaffold(
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: controller.fetchPosts,
            color: AppColor.customPurple,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.only(bottom: 100.h),
              children: [
                SizedBox(height: 16.h),

                // POSTS LIST — ONLY CHANGES HERE
                Obx(
                  () => Column(
                    children: controller.posts
                        .map(
                          (post) => PostCard(
                            key: ValueKey(
                              post.id,
                            ), // Helps Flutter delete the correct card
                            avatarUrl:
                                post.avatar ??
                                "https://ui-avatars.com/api/?name=${Uri.encodeComponent(post.userName)}&background=6B46C1&color=fff",
                            name: post.userName,
                            content: post.content,
                            favoriteCount: post.likes,
                            commentCount: post.comments,
                            isFavorited: post.isLiked,
                            isowner: post.isOwner,
                            onFavoriteTap: () {
                              controller.toggleLike(post.id);
                            },
                            postId: post.id,
                            onEditComplete: (newText) {
                              // Update content instantly after edit
                              final index = controller.posts.indexWhere(
                                (p) => p.id == post.id,
                              );
                              if (index != -1) {
                                controller.posts[index] = controller
                                    .posts[index]
                                    .copyWith(content: newText);
                                controller.posts.refresh();
                              }
                            },
                          ),
                        )
                        .toList(),
                  ),
                ),

                SizedBox(height: 40.h),
              ],
            ),
          ),

          Positioned(
            bottom: 20.h,
            left: 16.w,
            right: 16.w,
            child: postInputBar,
          ),
        ],
      ),
    );
  }
}
