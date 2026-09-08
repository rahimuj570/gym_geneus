// lib/app/modules/notification/views/notification_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../res/assets/asset.dart';
import '../../../res/colors/colors.dart';
import '../../../res/fonts/textstyle.dart';
import '../../../widgets/backbutton_widget.dart';
import '../controllers/notificationcontroller.dart';
import '../models/app_notification.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  static const List<String> tabs = ['Reminders', 'System'];

  Widget _buildTabButton(NotificationController controller, String tabName) {
    final isSelected = tabName == controller.selectedTab.value;
    final type = tabName == 'Reminders' ? 'reminder' : 'system';
    final unreadCount = controller.unreadCountForType(type);

    return GestureDetector(
      onTap: () => controller.selectTab(tabName),
      child: Container(
        width: 150.w,
        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 10.w),
        decoration: BoxDecoration(
          color: isSelected ? AppColor.customPurple : AppColor.white,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              tabName,
              style: AppTextStyles.poppinsSemiBold.copyWith(
                fontSize: 14.sp,
                color: isSelected ? AppColor.white : AppColor.black232323,
              ),
            ),
            if (unreadCount > 0) ...[
              SizedBox(width: 6.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: isSelected ? AppColor.white : AppColor.customPurple,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  '$unreadCount',
                  style: AppTextStyles.poppinsBold.copyWith(
                    fontSize: 10.sp,
                    color: isSelected ? AppColor.customPurple : AppColor.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // SMART DATE FORMATTER
  // Replace this function inside NotificationScreen
  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final notificationDate = DateTime(date.year, date.month, date.day);

    if (notificationDate == today) return 'Today';
    if (notificationDate == yesterday) return 'Yesterday';

    final difference = today.difference(notificationDate).inDays;

    if (difference <= 6) {
      return '$difference days ago'; // 2 days ago, 3 days ago, etc.
    }

    // Older than 6 days → show "Last week", "2 weeks ago", "Last month", etc.
    if (difference <= 13) return 'Last week';
    if (difference <= 20) return '2 weeks ago';
    if (difference <= 27) return '3 weeks ago';
    if (difference <= 35) return 'Last month';

    // Very old → just show month name
    return DateFormat('MMMM yyyy').format(date); // e.g. November 2025
  }

  Widget _buildNotificationItem(AppNotification item) {
    final bool isReminder = item.notificationType == 'reminder';

    Widget leadingWidget = isReminder
        ? Container(
            width: 50.w,
            height: 50.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15.r),
              image: const DecorationImage(
                image: AssetImage(ImageAssets.img_12),
                fit: BoxFit.cover,
              ),
            ),
          )
        : SvgPicture.asset(
            ImageAssets.svg35,
            height: 35.h,
            width: 35.w,
            color: AppColor.customPurple,
          );

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      child: Container(
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: AppColor.white,
          borderRadius: BorderRadius.circular(30.r),
          boxShadow: [
            BoxShadow(
              color: AppColor.black111214.withOpacity(0.1),
              blurRadius: 10.r,
              offset: Offset(0, 4.h),
            ),
          ],
        ),
        child: Row(
          children: [
            Stack(
              children: [
                leadingWidget,
                if (!item.isRead)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: 10.w,
                      height: 10.w,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColor.white, width: 2.w),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(width: 15.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: AppTextStyles.poppinsSemiBold.copyWith(
                      color: AppColor.black232323,
                      fontSize: 14.sp,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    item.message,
                    style: AppTextStyles.poppinsRegular.copyWith(
                      color: AppColor.gray9CA3AF,
                      fontSize: 13.sp,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '${item.formattedDate} • ${item.formattedTime}',
                    style: AppTextStyles.poppinsRegular.copyWith(
                      color: AppColor.customPurple,
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final NotificationController controller = Get.put(NotificationController());

    return Scaffold(
      backgroundColor: AppColor.black111214,
      appBar: AppBar(
        backgroundColor: AppColor.black111214,
        elevation: 0,
        leading: const BackButtonBox(),
        title: Text(
          'Notifications',
          style: AppTextStyles.poppinsBold.copyWith(
            color: AppColor.white,
            fontSize: 18.sp,
          ),
        ),
      ),
      body: Column(
        children: [
          // Tab Buttons
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
            child: Obx(
              () => Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: tabs
                    .map((tab) => _buildTabButton(controller, tab))
                    .toList(),
              ),
            ),
          ),

          // Dedicated Per-Tab Status & Mark All Read Bar
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 2.h),
            child: Obx(() {
              final isReminder = controller.selectedTab.value == 'Reminders';
              final String type = isReminder ? 'reminder' : 'system';
              final bool hasUnread = controller.hasUnreadForType(type);
              final int unreadCount = controller.unreadCountForType(type);
              final int totalCount = controller.countForType(type);
              final bool isMarking = controller.isMarkingRead.value;

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    unreadCount > 0
                        ? '$unreadCount unread ${controller.selectedTab.value.toLowerCase()}'
                        : '$totalCount ${controller.selectedTab.value.toLowerCase()}',
                    style: AppTextStyles.poppinsMedium.copyWith(
                      color: AppColor.gray9CA3AF,
                      fontSize: 12.sp,
                    ),
                  ),
                  InkWell(
                    onTap: isMarking || !hasUnread
                        ? null
                        : () => controller.markAllAsRead(type: type),
                    borderRadius: BorderRadius.circular(8.r),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isMarking)
                            SizedBox(
                              width: 14.w,
                              height: 14.w,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColor.customPurple,
                              ),
                            )
                          else
                            Icon(
                              Icons.done_all_rounded,
                              size: 16.sp,
                              color: hasUnread
                                  ? AppColor.customPurple
                                  : AppColor.gray9CA3AF.withOpacity(0.4),
                            ),
                          SizedBox(width: 4.w),
                          Text(
                            'Mark ${controller.selectedTab.value} Read',
                            style: AppTextStyles.poppinsMedium.copyWith(
                              color: hasUnread
                                  ? AppColor.customPurple
                                  : AppColor.gray9CA3AF.withOpacity(0.4),
                              fontSize: 12.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
          SizedBox(height: 6.h),

          // Notification List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppColor.customPurple,
                  ),
                );
              }

              final groups = controller.groupedNotifications;

              if (groups.isEmpty) {
                return Center(
                  child: Text(
                    'No notifications yet',
                    style: TextStyle(
                      color: AppColor.gray9CA3AF,
                      fontSize: 16.sp,
                    ),
                  ),
                );
              }

              return ListView.builder(
                padding: EdgeInsets.only(bottom: 20.h),
                itemCount: groups.length,
                itemBuilder: (context, i) {
                  final group = groups[i];
                  final headerText = _formatDateHeader(
                    group.items.first.createdAt,
                  );

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 10.h),
                        child: Text(
                          headerText,
                          style: AppTextStyles.poppinsBold.copyWith(
                            color: AppColor.white,
                            fontSize: 18.sp,
                          ),
                        ),
                      ),
                      ...group.items.map(_buildNotificationItem).toList(),
                    ],
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
