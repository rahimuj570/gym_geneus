import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:kenzeno/app/modules/home/controllers/post_controller.dart';
import 'package:kenzeno/app/modules/home/models/post_modeel.dart';
import 'package:kenzeno/app/res/colors/colors.dart';
import 'package:kenzeno/app/res/fonts/textstyle.dart';
import 'package:kenzeno/app/widgets/backbutton_widget.dart';

class BlockedUsersScreen extends StatefulWidget {
  const BlockedUsersScreen({super.key});

  @override
  State<BlockedUsersScreen> createState() => _BlockedUsersScreenState();
}

class _BlockedUsersScreenState extends State<BlockedUsersScreen> {
  late final ForumController _controller;

  @override
  void initState() {
    super.initState();
    if (Get.isRegistered<ForumController>()) {
      _controller = Get.find<ForumController>();
    } else {
      _controller = Get.put(ForumController());
    }
    _controller.fetchBlockedUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.black111214,
      appBar: AppBar(
        backgroundColor: AppColor.black111214,
        leading: const BackButtonBox(),
        title: Text(
          "Blocked Users",
          style: AppTextStyles.poppinsSemiBold.copyWith(
            fontSize: 20.sp,
            color: Colors.white,
          ),
        ),
      ),
      body: Obx(() {
        if (_controller.isLoadingBlockedUsers.value &&
            _controller.blockedUsers.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: AppColor.customPurple),
          );
        }

        if (_controller.blockedUsers.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.block_outlined,
                  size: 64.sp,
                  color: AppColor.gray9CA3AF.withOpacity(0.5),
                ),
                SizedBox(height: 16.h),
                Text(
                  "No blocked users",
                  style: AppTextStyles.poppinsSemiBold.copyWith(
                    color: Colors.white,
                    fontSize: 18.sp,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  "Users you block from the community will appear here.",
                  style: TextStyle(
                    color: AppColor.gray9CA3AF,
                    fontSize: 13.sp,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          color: AppColor.customPurple,
          onRefresh: () => _controller.fetchBlockedUsers(page: 1),
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            itemCount: _controller.blockedUsers.length,
            separatorBuilder: (_, __) => Divider(
              color: Colors.white12,
              height: 24.h,
            ),
            itemBuilder: (context, index) {
              final user = _controller.blockedUsers[index];
              return _buildUserTile(user);
            },
          ),
        );
      }),
    );
  }

  Widget _buildUserTile(BlockedUser user) {
    return Row(
      children: [
        CircleAvatar(
          radius: 22.r,
          backgroundColor: AppColor.gray1F2937,
          backgroundImage: user.blockedUserAvatar != null &&
                  user.blockedUserAvatar!.isNotEmpty
              ? NetworkImage(user.blockedUserAvatar!)
              : null,
          child: user.blockedUserAvatar == null ||
                  user.blockedUserAvatar!.isEmpty
              ? Text(
                  user.blockedUserName.isNotEmpty
                      ? user.blockedUserName[0].toUpperCase()
                      : "U",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : null,
        ),
        SizedBox(width: 14.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.blockedUserName,
                style: AppTextStyles.poppinsSemiBold.copyWith(
                  color: Colors.white,
                  fontSize: 15.sp,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              if (user.reason != null && user.reason!.isNotEmpty) ...[
                SizedBox(height: 2.h),
                Text(
                  "Reason: ${user.reason}",
                  style: TextStyle(
                    color: AppColor.gray9CA3AF,
                    fontSize: 12.sp,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
        SizedBox(width: 8.w),
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColor.customPurple),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
          ),
          onPressed: () async {
            final confirm = await Get.dialog<bool>(
              AlertDialog(
                backgroundColor: AppColor.gray1F2937,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
                title: Text(
                  "Unblock ${user.blockedUserName}?",
                  style: AppTextStyles.poppinsBold.copyWith(
                    color: Colors.white,
                    fontSize: 18.sp,
                  ),
                ),
                content: Text(
                  "You will be able to see their posts and comments in the community again.",
                  style: TextStyle(
                    color: AppColor.gray9CA3AF,
                    fontSize: 13.sp,
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Get.back(result: false),
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
                    onPressed: () => Get.back(result: true),
                    child: const Text(
                      "Unblock",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            );

            if (confirm == true) {
              await _controller.unblockUser(user.blockedUserId);
            }
          },
          child: Text(
            "Unblock",
            style: TextStyle(
              color: AppColor.customPurple,
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
