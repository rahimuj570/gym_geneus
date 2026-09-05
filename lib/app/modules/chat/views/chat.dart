// lib/app/modules/chat/views/chat_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../../res/colors/colors.dart';
import '../../../res/fonts/textstyle.dart';
import '../controllers/chatcontroller.dart';
import 'package:kenzeno/app/modules/setting/controller/profilecontroller.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final String assistantImagePath;

  const MessageBubble({
    super.key,
    required this.message,
    required this.assistantImagePath,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    final bgColor = isUser ? AppColor.customPurple : AppColor.white;
    final textColor = isUser ? AppColor.white : AppColor.black111214;
    final timeColor = isUser ? AppColor.purpleCCC2FF : AppColor.gray9CA3AF;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.only(
          top: 8.h,
          bottom: 5.h,
          left: isUser ? 50.w : 10.w,
          right: isUser ? 5.w : 50.w,
        ),
        child: Row(
          mainAxisAlignment: isUser
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Coach avatar ONLY for AI messages
            if (!isUser)
              CircleAvatar(
                radius: 16.r,
                backgroundImage: AssetImage(assistantImagePath),
                backgroundColor: AppColor.customPurple,
              ),

            if (!isUser) SizedBox(width: 10.w),

            // Message bubble
            Flexible(
              child: Column(
                crossAxisAlignment: isUser
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  Container(
                    constraints: BoxConstraints(maxWidth: 250.w),
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 15.h,
                    ),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30.r),
                        topRight: Radius.circular(30.r),
                        bottomLeft: isUser
                            ? Radius.circular(30.r)
                            : Radius.circular(5.r),
                        bottomRight: isUser
                            ? Radius.circular(5.r)
                            : Radius.circular(30.r),
                      ),
                    ),
                    child: Text(
                      message.text,
                      style: AppTextStyles.poppinsRegular.copyWith(
                        fontSize: 14.sp,
                        color: textColor,
                      ),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    message.time,
                    style: AppTextStyles.poppinsRegular.copyWith(
                      fontSize: 10.sp,
                      color: timeColor,
                    ),
                  ),
                ],
              ),
            ),

            if (isUser) SizedBox(width: 20.w),
          ],
        ),
      ),
    );
  }
}

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ChatController controller = Get.put(ChatController());
    // Ensure ProfileController is registered so GetBuilder can find it
    if (!Get.isRegistered<ProfileController>()) {
      Get.put(ProfileController());
    }

    return Scaffold(
      backgroundColor: AppColor.black111214,
      appBar: AppBar(
        backgroundColor: AppColor.black111214,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        title: GetBuilder<ProfileController>(
          builder: (pc) {
            final assistantName = pc.activeCoachName;
            final assistantImagePath = pc.activeCoachImagePath;

            return Row(
              children: [
                GestureDetector(
                  onTap: () => Get.back(),
                  child: const Icon(
                    Icons.arrow_back_ios,
                    color: AppColor.white,
                    size: 24,
                  ),
                ),
                SizedBox(width: 10.w),
                CircleAvatar(
                  radius: 20.r,
                  backgroundImage: AssetImage(assistantImagePath),
                  backgroundColor: AppColor.customPurple,
                ),
                SizedBox(width: 10.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      assistantName,
                      style: AppTextStyles.poppinsBold.copyWith(
                        color: AppColor.white,
                        fontSize: 18.sp,
                      ),
                    ),
                    Text(
                      "I'm Here To Assist You",
                      style: AppTextStyles.poppinsRegular.copyWith(
                        color: AppColor.gray9CA3AF,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
      body: GetBuilder<ProfileController>(
        builder: (pc) {
          final assistantImagePath = pc.activeCoachImagePath;

          return Column(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Obx(() {
                      if (controller.isLoading.value &&
                          controller.messages.isEmpty) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: AppColor.customPurple,
                          ),
                        );
                      }

                      return ListView.builder(
                        reverse: true,
                        padding: EdgeInsets.symmetric(vertical: 20.h),
                        itemCount: controller.messages.length,
                        itemBuilder: (context, index) {
                          final message = controller.messages[index];
                          return MessageBubble(
                            message: message,
                            assistantImagePath: assistantImagePath,
                          );
                        },
                      );
                    }),

                    Obx(() {
                      if (controller.isLoading.value &&
                          controller.messages.isNotEmpty) {
                        return Positioned(
                          bottom: 10.h,
                          left: 10.w,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              CircleAvatar(
                                radius: 16.r,
                                backgroundImage: AssetImage(
                                  assistantImagePath,
                                ),
                                backgroundColor: AppColor.customPurple,
                              ),
                              SizedBox(width: 10.w),
                              LoadingAnimationWidget.staggeredDotsWave(
                                color: AppColor.customPurple,
                                size: 30.w,
                              ),
                            ],
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    }),
                  ],
                ),
              ),
              _buildInputBar(controller),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInputBar(ChatController controller) {
    return Obx(
      () => Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
        decoration: const BoxDecoration(color: AppColor.black111214),
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                decoration: BoxDecoration(
                  color: AppColor.white30,
                  borderRadius: BorderRadius.circular(30.r),
                ),
                child: TextField(
                  cursorColor: AppColor.white,
                  controller: controller.textController,
                  enabled: !controller.isLoading.value,
                  textCapitalization: TextCapitalization.sentences,
                  style: AppTextStyles.poppinsRegular.copyWith(
                    color: AppColor.white,
                    fontSize: 14.sp,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Write Here...',
                    hintStyle: AppTextStyles.poppinsRegular.copyWith(
                      color: AppColor.gray9CA3AF,
                      fontSize: 14.sp,
                    ),
                    border: InputBorder.none,
                  ),
                  onSubmitted: (_) => controller.sendMessage(),
                ),
              ),
            ),
            SizedBox(width: 10.w),
            GestureDetector(
              onTap: controller.isLoading.value ? null : controller.sendMessage,
              child: Container(
                width: 50.w,
                height: 50.w,
                decoration: BoxDecoration(
                  color: controller.isLoading.value
                      ? AppColor.gray9CA3AF
                      : AppColor.customPurple,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.send, color: AppColor.white, size: 24),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
