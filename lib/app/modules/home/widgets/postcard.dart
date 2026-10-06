import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:kenzeno/app/res/assets/asset.dart';
import 'package:kenzeno/app/res/colors/colors.dart';
import '../../../res/fonts/textstyle.dart';
import '../controllers/post_controller.dart';
import 'package:toastification/toastification.dart';

class PostCard extends StatefulWidget {
  final String avatarUrl;
  final String name;
  final String content;
  final int postId;
  final String userId;
  final int favoriteCount;
  final int commentCount;
  final bool isFavorited;
  final bool isowner;

  final VoidCallback? onFavoriteTap;
  final Function(String)? onEditComplete;

  const PostCard({
    Key? key,
    required this.avatarUrl,
    required this.name,
    required this.content,
    required this.postId,
    this.userId = '',
    required this.favoriteCount,
    required this.commentCount,
    this.isFavorited = false,
    this.onFavoriteTap,
    this.onEditComplete,
    required this.isowner,
  }) : super(key: key);

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard>
    with SingleTickerProviderStateMixin {
  late String currentContent = widget.content;
  late AnimationController _likeAnimController;
  late Animation<double> _likeScaleAnimation;

  @override
  void initState() {
    super.initState();
    _likeAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _likeScaleAnimation = Tween<double>(begin: 1.0, end: 1.35).animate(
      CurvedAnimation(parent: _likeAnimController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _likeAnimController.dispose();
    super.dispose();
  }

  void _onLikeTapped() {
    _likeAnimController
        .forward()
        .then((_) => _likeAnimController.reverse());
    widget.onFavoriteTap?.call();
  }

  void _showReportDialog({
    required String contentType,
    required String targetName,
    int? postId,
    int? commentId,
  }) {
    String selectedReasonKey = "inappropriate";
    final descController = TextEditingController();
    var isSubmitting = false;

    final reasons = [
      {"key": "inappropriate", "label": "Inappropriate Content"},
      {"key": "spam", "label": "Spam"},
      {"key": "harassment", "label": "Harassment"},
      {"key": "hate_speech", "label": "Hate Speech"},
      {"key": "misinformation", "label": "Misinformation"},
      {"key": "other", "label": "Other"},
    ];

    Get.dialog(
      StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: AppColor.gray1F2937,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
            title: Text(
              "Report $contentType",
              style: AppTextStyles.poppinsBold.copyWith(
                color: Colors.white,
                fontSize: 18.sp,
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Why are you reporting this $contentType from $targetName?",
                    style: TextStyle(color: AppColor.gray9CA3AF, fontSize: 13.sp),
                  ),
                  SizedBox(height: 12.h),
                  ...reasons.map(
                    (item) => RadioListTile<String>(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        item["label"]!,
                        style: TextStyle(color: Colors.white, fontSize: 13.sp),
                      ),
                      value: item["key"]!,
                      groupValue: selectedReasonKey,
                      activeColor: AppColor.customPurple,
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() => selectedReasonKey = val);
                        }
                      },
                    ),
                  ),
                  SizedBox(height: 8.h),
                  TextField(
                    controller: descController,
                    maxLines: 2,
                    style: TextStyle(color: Colors.white, fontSize: 13.sp),
                    decoration: InputDecoration(
                      hintText: "Additional details (optional)...",
                      hintStyle: TextStyle(color: Colors.white54, fontSize: 12.sp),
                      filled: true,
                      fillColor: AppColor.black111214,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.all(10.r),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: Text(
                  "Cancel",
                  style: TextStyle(color: AppColor.gray9CA3AF),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.customPurple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                onPressed: isSubmitting
                    ? null
                    : () async {
                        setDialogState(() => isSubmitting = true);
                        final controller = Get.find<ForumController>();
                        final desc = descController.text.trim();

                        if (postId != null) {
                          await controller.reportPost(
                            postId: postId,
                            reason: selectedReasonKey,
                            description: desc,
                          );
                        } else if (commentId != null) {
                          await controller.reportComment(
                            commentId: commentId,
                            reason: selectedReasonKey,
                            description: desc,
                          );
                        }
                        Get.back();
                      },
                child: isSubmitting
                    ? SizedBox(
                        height: 16.h,
                        width: 16.w,
                        child: const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        "Submit Report",
                        style: TextStyle(color: Colors.white),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showBlockUserDialog({required String userId, required String userName}) {
    final reasonController = TextEditingController();
    var isSubmitting = false;

    Get.dialog(
      StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: AppColor.gray1F2937,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
            title: Text(
              "Block $userName?",
              style: AppTextStyles.poppinsBold.copyWith(
                color: Colors.white,
                fontSize: 18.sp,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "You will no longer see posts or comments from $userName. This user will also not be able to interact with your content.",
                  style: TextStyle(color: AppColor.gray9CA3AF, fontSize: 13.sp),
                ),
                SizedBox(height: 12.h),
                TextField(
                  controller: reasonController,
                  maxLines: 2,
                  style: TextStyle(color: Colors.white, fontSize: 13.sp),
                  decoration: InputDecoration(
                    hintText: "Reason for blocking (optional)...",
                    hintStyle: TextStyle(color: Colors.white54, fontSize: 12.sp),
                    filled: true,
                    fillColor: AppColor.black111214,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.all(10.r),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: Text(
                  "Cancel",
                  style: TextStyle(color: AppColor.gray9CA3AF),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.redDC2626,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                onPressed: isSubmitting
                    ? null
                    : () async {
                        setDialogState(() => isSubmitting = true);
                        final controller = Get.find<ForumController>();
                        await controller.blockUser(
                          userId: userId,
                          userName: userName,
                          reason: reasonController.text.trim(),
                        );
                        Get.back();
                      },
                child: isSubmitting
                    ? SizedBox(
                        height: 16.h,
                        width: 16.w,
                        child: const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        "Block User",
                        style: TextStyle(color: Colors.white),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showEditModal() {
    final controller = TextEditingController(text: currentContent);
    var isSaving = false.obs;

    Get.bottomSheet(
      Obx(
        () => WillPopScope(
          onWillPop: () async => !isSaving.value,
          child: Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: AppColor.gray1F2937,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 4.h,
                  width: 40.w,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                SizedBox(height: 20.h),
                Text(
                  "Edit Post",
                  style: AppTextStyles.poppinsBold.copyWith(
                    color: Colors.white,
                    fontSize: 20.sp,
                  ),
                ),
                SizedBox(height: 20.h),
                TextField(
                  controller: controller,
                  maxLines: 8,
                  enabled: !isSaving.value,
                  style: TextStyle(color: Colors.white, fontSize: 16.sp),
                  decoration: InputDecoration(
                    hintText: "What's on your mind?",
                    hintStyle: TextStyle(color: Colors.white54),
                    filled: true,
                    fillColor: AppColor.black111214,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.r),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.all(16.r),
                  ),
                ),
                SizedBox(height: 20.h),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: isSaving.value ? null : () => Get.back(),
                        child: Text(
                          "Cancel",
                          style: TextStyle(
                            color: isSaving.value
                                ? AppColor.gray9CA3AF.withOpacity(0.4)
                                : AppColor.gray9CA3AF,
                            fontSize: 16.sp,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.customPurple,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                        ),
                        onPressed: isSaving.value
                            ? null
                            : () async {
                                final newText = controller.text.trim();
                                if (newText.isEmpty) {
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
                                      "Post cannot be empty",
                                      style: AppTextStyles.poppinsRegular
                                          .copyWith(color: Colors.white),
                                    ),
                                    alignment: Alignment.topRight,
                                    autoCloseDuration: const Duration(
                                      seconds: 4,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    showProgressBar: true,
                                  );
                                  return;
                                }
                                if (newText == currentContent) {
                                  Get.back();
                                  return;
                                }

                                isSaving.value = true;
                                final success =
                                    await Get.find<ForumController>()
                                        .updateForumPost(
                                          postId: widget.postId,
                                          newContent: newText,
                                        );
                                isSaving.value = false;

                                if (success) {
                                  setState(() => currentContent = newText);
                                  widget.onEditComplete?.call(newText);
                                  Navigator.of(context).pop();
                                }
                              },
                        child: isSaving.value
                            ? SizedBox(
                                height: 20.h,
                                width: 20.w,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                "Save",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.sp,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  void _showCommentsPopup() async {
    final controller = Get.find<ForumController>();
    final commentCtrl = TextEditingController();
    final scrollCtrl = ScrollController();

    controller.fetchComments(widget.postId);

    Get.bottomSheet(
      Container(
        height: Get.height * 0.85,
        decoration: BoxDecoration(
          color: AppColor.black111214,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.white10)),
              ),
              child: Row(
                children: [
                  Obx(
                    () => Text(
                      "Comments (${controller.comments.length})",
                      style: AppTextStyles.poppinsBold.copyWith(
                        color: Colors.white,
                        fontSize: 20.sp,
                      ),
                    ),
                  ),
                  Spacer(),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.white),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
            ),

            // Comments List
            Expanded(
              child: Obx(() {
                if (controller.isLoadingComments.value) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: AppColor.customPurple,
                    ),
                  );
                }
                if (controller.comments.isEmpty) {
                  return Center(
                    child: Text(
                      "No comments yet",
                      style: TextStyle(color: AppColor.gray9CA3AF),
                    ),
                  );
                }

                return ListView.builder(
                  controller: scrollCtrl,
                  padding: EdgeInsets.all(16.r),
                  itemCount: controller.comments.length,
                  itemBuilder: (ctx, i) {
                    final c = controller.comments[i];

                    return Padding(
                      padding: EdgeInsets.only(bottom: 16.h),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          // Avatar with fallback
                          CircleAvatar(
                            radius: 16.r,
                            backgroundColor: AppColor.customPurple,
                            backgroundImage:
                                c.avatar != null && c.avatar!.isNotEmpty
                                ? NetworkImage(c.avatar!)
                                : null,
                            child: c.avatar == null || c.avatar!.isEmpty
                                ? Text(
                                    c.userName.isNotEmpty
                                        ? c.userName[0].toUpperCase()
                                        : "A",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14.sp,
                                    ),
                                  )
                                : null,
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: 20.h,
                                  child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            // Username
                                            Expanded(
                                              child: Text(
                                                c.userName,
                                                style: AppTextStyles
                                                    .poppinsSemiBold
                                                    .copyWith(
                                                      color: Colors.white,
                                                      fontSize: 14.sp,
                                                    ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),

                                            // Popup Menu (no extra space!)
                                            PopupMenuButton<String>(
                                              padding: EdgeInsets.zero,
                                              splashRadius:
                                                  1, // removes ripple padding
                                              constraints:
                                                  BoxConstraints(), // prevents default min width
                                              offset: Offset(
                                                0,
                                                20,
                                              ), // optional: better dropdown position
                                              icon: Icon(
                                                Icons.more_vert,
                                                color: Colors.white70,
                                                size: 18.sp,
                                              ),

                                              color: AppColor.gray1F2937,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12.r),
                                              ),

                                              onSelected: (value) async {
                                                if (value == 'report') {
                                                  _showReportDialog(
                                                    contentType: "Comment",
                                                    targetName: c.userName,
                                                    commentId: c.id,
                                                  );
                                                }
                                                if (value == 'block') {
                                                  _showBlockUserDialog(
                                                    userId: c.userId,
                                                    userName: c.userName,
                                                  );
                                                }
                                                if (value == 'edit') {
                                                  final editCtrl =
                                                      TextEditingController(
                                                        text: c.content,
                                                      );

                                                  await Get.dialog(
                                                    AlertDialog(
                                                      backgroundColor:
                                                          AppColor.gray1F2937,
                                                      title: Text(
                                                        "Edit Comment",
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                      content: TextField(
                                                        controller: editCtrl,
                                                        maxLines: 4,
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                        ),
                                                        decoration: InputDecoration(
                                                          filled: true,
                                                          fillColor: AppColor
                                                              .black111214,
                                                          border:
                                                              OutlineInputBorder(
                                                                borderSide:
                                                                    BorderSide
                                                                        .none,
                                                              ),
                                                          contentPadding:
                                                              EdgeInsets.all(
                                                                12.r,
                                                              ),
                                                        ),
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () =>
                                                              Get.back(),
                                                          child: Text(
                                                            "Cancel",
                                                            style: TextStyle(
                                                              color: AppColor
                                                                  .gray9CA3AF,
                                                            ),
                                                          ),
                                                        ),
                                                        Obx(
                                                          () => TextButton(
                                                            onPressed:
                                                                controller
                                                                    .isLoadingComments
                                                                    .value
                                                                ? null
                                                                : () async {
                                                                    final newText =
                                                                        editCtrl
                                                                            .text
                                                                            .trim();
                                                                    if (newText
                                                                        .isEmpty) {
                                                                      toastification.show(
                                                                        type: ToastificationType
                                                                            .error,
                                                                        style: ToastificationStyle
                                                                            .fillColored,
                                                                        primaryColor:
                                                                            Colors.red,
                                                                        foregroundColor:
                                                                            Colors.white,
                                                                        title: Text(
                                                                          "Error",
                                                                          style: AppTextStyles.poppinsBold.copyWith(
                                                                            color:
                                                                                Colors.white,
                                                                          ),
                                                                        ),
                                                                        description: Text(
                                                                          "Comment cannot be empty",
                                                                          style: AppTextStyles.poppinsRegular.copyWith(
                                                                            color:
                                                                                Colors.white,
                                                                          ),
                                                                        ),
                                                                        alignment:
                                                                            Alignment.topRight,
                                                                        autoCloseDuration: const Duration(
                                                                          seconds:
                                                                              4,
                                                                        ),
                                                                        borderRadius:
                                                                            BorderRadius.circular(
                                                                              12,
                                                                            ),
                                                                        showProgressBar:
                                                                            true,
                                                                      );
                                                                      return;
                                                                    }

                                                                    controller
                                                                            .isLoadingComments
                                                                            .value =
                                                                        true;

                                                                    final success = await controller.updateComment(
                                                                      commentId:
                                                                          c.id,
                                                                      newContent:
                                                                          newText,
                                                                    );

                                                                    controller
                                                                            .isLoadingComments
                                                                            .value =
                                                                        false;

                                                                    if (success) {
                                                                      Navigator.of(
                                                                        context,
                                                                      ).pop();
                                                                    }
                                                                  },
                                                            child:
                                                                controller
                                                                    .isLoadingComments
                                                                    .value
                                                                ? SizedBox(
                                                                    width: 18.w,
                                                                    height:
                                                                        18.h,
                                                                    child: CircularProgressIndicator(
                                                                      color: Colors
                                                                          .white,
                                                                      strokeWidth:
                                                                          2.0,
                                                                    ),
                                                                  )
                                                                : Text(
                                                                    "Save",
                                                                    style: TextStyle(
                                                                      color: AppColor
                                                                          .green22C55E,
                                                                    ),
                                                                  ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                }

                                                if (value == 'delete') {
                                                  // Close popup before delete dialog

                                                  final confirm =
                                                      await Get.dialog<bool>(
                                                        AlertDialog(
                                                          backgroundColor:
                                                              AppColor
                                                                  .gray1F2937,
                                                          title: Text(
                                                            "Delete Comment?",
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          ),
                                                          content: Text(
                                                            "This cannot be undone.",
                                                            style: TextStyle(
                                                              color: AppColor
                                                                  .gray9CA3AF,
                                                            ),
                                                          ),
                                                          actions: [
                                                            TextButton(
                                                              onPressed: () =>
                                                                  Get.back(
                                                                    result:
                                                                        false,
                                                                  ),
                                                              child: Text(
                                                                "Cancel",
                                                              ),
                                                            ),
                                                            TextButton(
                                                              onPressed: () =>
                                                                  Get.back(
                                                                    result:
                                                                        true,
                                                                  ),
                                                              child: Text(
                                                                "Delete",
                                                                style: TextStyle(
                                                                  color: AppColor
                                                                      .redDC2626,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      );

                                                  if (confirm == true) {
                                                    await controller
                                                        .deleteComment(
                                                          commentId: c.id,
                                                          postId: widget.postId,
                                                        );
                                                  }
                                                }
                                              },

                                              itemBuilder: (_) => c.isOwner
                                                  ? [
                                                      PopupMenuItem(
                                                        value: 'edit',
                                                        child: Row(
                                                          children: [
                                                            const Icon(
                                                              Icons.edit_outlined,
                                                              size: 18,
                                                              color: Colors.white,
                                                            ),
                                                            SizedBox(width: 8.w),
                                                            const Text(
                                                              "Edit",
                                                              style: TextStyle(
                                                                color: Colors.white,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      PopupMenuItem(
                                                        value: 'delete',
                                                        child: Row(
                                                          children: [
                                                            const Icon(
                                                              Icons.delete_outline,
                                                              size: 18,
                                                              color:
                                                                  AppColor.redDC2626,
                                                            ),
                                                            SizedBox(width: 8.w),
                                                            const Text(
                                                              "Delete",
                                                              style: TextStyle(
                                                                color: AppColor
                                                                    .redDC2626,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ]
                                                  : [
                                                      PopupMenuItem(
                                                        value: 'report',
                                                        child: Row(
                                                          children: [
                                                            const Icon(
                                                              Icons.flag_outlined,
                                                              size: 18,
                                                              color: Colors.amber,
                                                            ),
                                                            SizedBox(width: 8.w),
                                                            const Text(
                                                              "Report Comment",
                                                              style: TextStyle(
                                                                color: Colors.white,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      PopupMenuItem(
                                                        value: 'block',
                                                        child: Row(
                                                          children: [
                                                            const Icon(
                                                              Icons.block_outlined,
                                                              size: 18,
                                                              color:
                                                                  AppColor.redDC2626,
                                                            ),
                                                            SizedBox(width: 8.w),
                                                            const Text(
                                                              "Block User",
                                                              style: TextStyle(
                                                                color: Colors.white,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                            ),
                                          ],
                                        ),
                                      ),
                                SizedBox(height: 5.h),
                                Text(
                                  c.content,
                                  style: TextStyle(
                                    color: AppColor.white,
                                    fontSize: 14.sp,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  _timeAgo(c.createdAt),
                                  style: TextStyle(
                                    color: AppColor.gray9CA3AF,
                                    fontSize: 12.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              }),
            ),

            // Add Comment Input
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: AppColor.gray1F2937,
                border: Border(top: BorderSide(color: Colors.white10)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: commentCtrl,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "Add a comment...",
                        hintStyle: TextStyle(color: Colors.white54),
                        border: InputBorder.none,
                        filled: true,
                        fillColor: AppColor.black111214.withOpacity(0.3),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 12.h,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  GestureDetector(
                    onTap: () async {
                      final text = commentCtrl.text.trim();
                      if (text.isEmpty) return;
                      final success = await controller.createComment(
                        postId: widget.postId,
                        content: text,
                      );
                      if (success) {
                        commentCtrl.clear();
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (scrollCtrl.hasClients) {
                            scrollCtrl.animateTo(
                              0,
                              duration: 300.milliseconds,
                              curve: Curves.easeOut,
                            );
                          }
                        });
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.all(12.r),
                      decoration: BoxDecoration(
                        color: AppColor.customPurple,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 20.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return "now";
    if (diff.inHours < 1) return "${diff.inMinutes}m ago";
    if (diff.inDays < 1) return "${diff.inHours}h ago";
    return "${diff.inDays}d ago";
  }

  String _formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return count.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColor.black111214,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.white, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16.r,
                backgroundImage: NetworkImage(widget.avatarUrl),
                backgroundColor: AppColor.gray1F2937,
              ),
              SizedBox(width: 12.w),
              Text(
                widget.name,
                style: AppTextStyles.poppinsBold.copyWith(
                  color: AppColor.white,
                  fontSize: 14.sp,
                ),
              ),
              Spacer(),
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_horiz,
                  color: AppColor.white.withOpacity(0.6),
                ),
                color: AppColor.gray1F2937,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                onSelected: (value) async {
                  if (value == 'edit') _showEditModal();
                  if (value == 'report') {
                    _showReportDialog(
                      contentType: "Post",
                      targetName: widget.name,
                      postId: widget.postId,
                    );
                  }
                  if (value == 'block') {
                    _showBlockUserDialog(
                      userId: widget.userId,
                      userName: widget.name,
                    );
                  }
                  if (value == 'delete') {
                    final confirmed = await Get.dialog<bool>(
                      AlertDialog(
                        backgroundColor: AppColor.gray1F2937,
                        title: const Text(
                          "Delete Post?",
                          style: TextStyle(color: Colors.white),
                        ),
                        content: const Text(
                          "This action cannot be undone.",
                          style: TextStyle(color: AppColor.gray9CA3AF),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Get.back(result: false),
                            child: const Text("Cancel"),
                          ),
                          TextButton(
                            onPressed: () => Get.back(result: true),
                            child: const Text(
                              "Delete",
                              style: TextStyle(color: AppColor.redDC2626),
                            ),
                          ),
                        ],
                      ),
                    );
                    if (confirmed == true) {
                      await Get.find<ForumController>().deleteForumPost(
                        postId: widget.postId,
                      );
                    }
                  }
                },
                itemBuilder: (_) => widget.isowner
                    ? [
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              const Icon(Icons.edit_outlined, color: Colors.white),
                              SizedBox(width: 12.w),
                              const Text("Edit", style: TextStyle(color: Colors.white)),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              const Icon(Icons.delete_outline, color: AppColor.redDC2626),
                              SizedBox(width: 12.w),
                              const Text(
                                "Delete",
                                style: TextStyle(color: AppColor.redDC2626),
                              ),
                            ],
                          ),
                        ),
                      ]
                    : [
                        PopupMenuItem(
                          value: 'report',
                          child: Row(
                            children: [
                              const Icon(Icons.flag_outlined, color: Colors.amber),
                              SizedBox(width: 12.w),
                              const Text("Report Post", style: TextStyle(color: Colors.white)),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'block',
                          child: Row(
                            children: [
                              const Icon(Icons.block_outlined, color: AppColor.redDC2626),
                              SizedBox(width: 12.w),
                              const Text("Block User", style: TextStyle(color: Colors.white)),
                            ],
                          ),
                        ),
                      ],
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            currentContent,
            style: AppTextStyles.poppinsRegular.copyWith(
              color: AppColor.white,
              fontSize: 12.sp,
              height: 1.5,
            ),
          ),
          SizedBox(height: 20.h),
          Row(
            children: [
              GestureDetector(
                onTap: _onLikeTapped,
                child: Row(
                  children: [
                    ScaleTransition(
                      scale: _likeScaleAnimation,
                      child: SvgPicture.asset(
                        ImageAssets.svg33,
                        height: 15.h,
                        colorFilter: widget.isFavorited == true
                            ? ColorFilter.mode(
                                AppColor.purpleRoyal,
                                BlendMode.srcIn,
                              )
                            : ColorFilter.mode(Colors.grey, BlendMode.srcIn),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      _formatCount(widget.favoriteCount),
                      style: AppTextStyles.poppinsMedium.copyWith(
                        color: widget.isFavorited
                            ? AppColor.purpleRoyal
                            : AppColor.white.withOpacity(0.7),
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 32.w),
              GestureDetector(
                onTap: _showCommentsPopup,
                child: Row(
                  children: [
                    Icon(
                      Icons.chat_outlined,
                      color: AppColor.customPurple,
                      size: 20.sp,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      _formatCount(widget.commentCount),
                      style: AppTextStyles.poppinsMedium.copyWith(
                        color: AppColor.white.withOpacity(0.7),
                        fontSize: 14.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
