import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:kenzeno/app/widgets/backbutton_widget.dart';

import '../../../res/colors/colors.dart';
import '../../../res/fonts/textstyle.dart';
import '../../../res/assets/asset.dart';
import '../controllers/leaderboardcontroller.dart';

class LeaderboardPage extends StatelessWidget {
  LeaderboardPage({super.key});

  // Define Colors for Top 3 Positions
  static const Color _goldColor = Color(0xFFFFD700);
  static const Color _silverColor = Color(0xFFC0C0C0);
  static const Color _bronzeColor = Color(0xFFCD7F32);
  static const Color _goldShadow = Color(0x33FFD700);
  static const Color _silverShadow = Color(0x33C0C0C0);
  static const Color _bronzeShadow = Color(0x33CD7F32);

  final Map<String, String> rankIcons = {
    'Bronze': ImageAssets.svg64,
    'Silver': ImageAssets.svg65,
    'Gold': ImageAssets.svg66,
    'Platinum': ImageAssets.svg67,
    'Diamond': ImageAssets.svg68,
  };

  // Helper to get Top 3 colors
  Color _getPositionColor(int position) {
    if (position == 1) return _goldColor;
    if (position == 2) return _silverColor;
    if (position == 3) return _bronzeColor;
    return AppColor.gray9CA3AF; // Default for others
  }

  // Helper to get Top 3 card background color (for subtle glow/shadow)
  Color _getShadowColor(int position) {
    if (position == 1) return _goldShadow;
    if (position == 2) return _silverShadow;
    if (position == 3) return _bronzeShadow;
    return Colors.transparent;
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LeaderboardController());

    return Scaffold(
      backgroundColor: AppColor.black111214,
      appBar: AppBar(
        backgroundColor: AppColor.black111214,
        elevation: 0,
        leading: BackButtonBox(),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Smaller trophy icon
            SvgPicture.asset(
              ImageAssets.svg56,
              height: 24.h,
              color: _goldColor,
            ),
            SizedBox(width: 8.w), // Smaller space
            Text(
              'Leaderboard',
              style: AppTextStyles.poppinsBold.copyWith(
                color: Colors.white,
                fontSize: 20.sp,
              ),
            ), // Smaller font
          ],
        ),
        actions: [SizedBox(width: 48.w)],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColor.customPurple),
          );
        }

        final data = controller.leaderboard.value!.data;
        // Check if data.leaderboard is not empty before accessing the first element
        // Try to find the current user first. If not found, fall back to the first user in the list (index 0).
        final currentUser =
            data.leaderboard.firstWhereOrNull((u) => u.isCurrentUser) ??
            (data.leaderboard.isNotEmpty ? data.leaderboard.first : null);
        if (currentUser == null) {
          return const Center(
            child: Text(
              "No user data found.",
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        final weekStart = DateFormat(
          'MMM dd',
        ).format(DateTime.parse(data.weekStart));

        // Convert rankColor from String to Color
        final rankPrimaryColor = Color(
          int.parse(data.rankColor.replaceFirst('#', '0xFF')),
        );

        return ListView(
          padding: EdgeInsets.symmetric(
            horizontal: 16.w,
          ), // Reduced horizontal padding
          children: [
            SizedBox(height: 16.h), // Reduced height
            // === YOUR RANK CARD (Enhanced with Shadow/Depth) ===
            Container(
              padding: EdgeInsets.all(16.r), // Reduced internal padding
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    rankPrimaryColor,
                    rankPrimaryColor.withOpacity(0.85),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(
                  20.r,
                ), // Reduced border radius
                border: Border.all(
                  color: rankPrimaryColor,
                  width: 1.5,
                ), // Reduced border width
                boxShadow: [
                  BoxShadow(
                    color: rankPrimaryColor.withOpacity(
                      0.3,
                    ), // Reduced shadow opacity
                    blurRadius: 8.r, // Reduced blur
                    spreadRadius: 1.r, // Reduced spread
                    offset: Offset(0, 3.h), // Reduced offset
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Rank Icon
                  SvgPicture.asset(
                    rankIcons[data.rank] ?? ImageAssets.svg1,
                    height: 56.r, // Reduced size
                    width: 56.r, // Reduced size
                  ),
                  SizedBox(width: 12.w), // Reduced space
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "YOUR RANK",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                          ), // Reduced font
                        ),
                        SizedBox(height: 2.h), // Reduced space
                        Text(
                          data.rank,
                          style: AppTextStyles.poppinsBold.copyWith(
                            color: Colors.white,
                            fontSize: 28.sp,
                          ), // Reduced font
                        ),
                        Text(
                          "Position #${data.userPosition} of ${data.totalUsersInRank}",
                          style: TextStyle(
                            color: Colors.white60,
                            fontSize: 13.sp,
                          ), // Reduced font
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "${currentUser.weeklyPoints}",
                        style: AppTextStyles.poppinsBold.copyWith(
                          color: Colors.white,
                          fontSize: 24.sp,
                        ), // Reduced font
                      ),
                      Text(
                        "PTS",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13.sp,
                        ),
                      ), // Reduced font
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 24.h), // Reduced height
            // Week Label
            Center(
              child: Text(
                "CURRENT WEEK: $weekStart",
                style: TextStyle(
                  color: AppColor.gray9CA3AF,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ), // Reduced font
              ),
            ),

            SizedBox(height: 16.h), // Reduced height
            // === LEADERBOARD LIST ===
            ...data.leaderboard.map((user) {
              final isYou = user.isCurrentUser;
              final positionColor = _getPositionColor(user.position);
              final shadowColor = _getShadowColor(user.position);

              // Top 3 specific styling
              final isTop3 = user.position <= 3;
              final cardBackgroundColor = isTop3
                  ? positionColor.withOpacity(0.15)
                  : (isYou
                        ? AppColor.customPurple.withOpacity(0.2)
                        : AppColor.gray1F2937.withOpacity(0.3));
              final cardBorderColor = isTop3
                  ? positionColor
                  : (isYou ? AppColor.customPurple : AppColor.greyBlue);

              return Padding(
                padding: EdgeInsets.only(bottom: 8.h), // Reduced bottom margin
                child: Container(
                  padding: EdgeInsets.all(12.r), // Reduced internal padding
                  decoration: BoxDecoration(
                    color: cardBackgroundColor,
                    borderRadius: BorderRadius.circular(
                      16.r,
                    ), // Reduced border radius
                    border: Border.all(
                      color: cardBorderColor,
                      width: isTop3 || isYou ? 1.5 : 1, // Reduced border width
                    ),
                    // Add a slight glow for Top 3
                    boxShadow: isTop3
                        ? [
                            BoxShadow(
                              color: shadowColor,
                              blurRadius: 6.r, // Reduced blur
                              spreadRadius: 0.5.r, // Reduced spread
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    children: [
                      // Position (Badge Style)
                      Container(
                        width: 36.r, // Reduced size
                        height: 36.r, // Reduced size
                        decoration: BoxDecoration(
                          color: positionColor,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.8),
                            width: 1.r, // Reduced border width
                          ),
                        ),
                        child: Center(
                          child: Text(
                            "${user.position}",
                            style: AppTextStyles.poppinsBold.copyWith(
                              color: user.position <= 3
                                  ? Colors.black
                                  : Colors.white,
                              fontSize: 16.sp, // Reduced font size
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10.w), // Reduced space
                      // Avatar
                      CircleAvatar(
                        radius: 20.r, // Reduced size
                        backgroundColor: AppColor.gray9CA3AF,
                        child: Text(
                          user.username.isNotEmpty
                              ? user.username[0].toUpperCase()
                              : "A",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                          ), // Reduced font
                        ),
                      ),
                      SizedBox(width: 10.w), // Reduced space
                      // Name & Points
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isYou ? "${user.username} (You)" : user.username,
                              style: AppTextStyles.poppinsSemiBold.copyWith(
                                color: isYou
                                    ? AppColor.green22C55E
                                    : Colors.white,
                                fontSize: 15.sp, // Reduced font size
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 2.h), // Reduced space
                            Text(
                              "${user.weeklyPoints} pts this week",
                              style: TextStyle(
                                color: AppColor.gray9CA3AF,
                                fontSize: 12.sp,
                              ), // Reduced font
                            ),
                          ],
                        ),
                      ),

                      // Trophy for Top 3 / Star for You
                      if (user.position == 1)
                        SvgPicture.asset(
                          ImageAssets.svg56,
                          height: 28.r,
                          color: _goldColor,
                        ) // Reduced size
                      else if (user.position == 2)
                        SvgPicture.asset(
                          ImageAssets.svg56,
                          height: 24.r,
                          color: _silverColor,
                        ) // Reduced size
                      else if (user.position == 3)
                        SvgPicture.asset(
                          ImageAssets.svg56,
                          height: 22.r,
                          color: _bronzeColor,
                        ) // Reduced size
                      else if (isYou)
                        Icon(
                          Icons.star,
                          color: AppColor.customPurple,
                          size: 24.r,
                        ),
                      // Reduced size
                    ],
                  ),
                ),
              );
            }).toList(),

            SizedBox(height: 30.h), // Reduced height
          ],
        );
      }),
    );
  }
}
