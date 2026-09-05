// lib/app/modules/chat/controllers/chatcontroller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../service/chat_service.dart';
import 'package:toastification/toastification.dart';
import 'package:kenzeno/app/res/fonts/textstyle.dart';
import 'package:kenzeno/app/res/colors/colors.dart';

class Message {
  final String text;
  final String time;
  final bool isUser;

  Message({required this.text, required this.time, required this.isUser});
}

class ChatController extends GetxController {
  final ChatService _chatService = ChatService();

  var messages = <Message>[].obs;
  var isLoading = false.obs;

  final TextEditingController textController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadConversation();
  }

  Future<void> loadConversation() async {
    try {
      isLoading.value = true;
      final convo = await _chatService.getConversation();

      final DateFormat formatter = DateFormat('h:mm a');

      // Load messages: newest at top (index 0) → perfect for reverse: true
      messages.assignAll(
        convo.messages.reversed.map((m) {
          return Message(
            text: m.message,
            time: formatter.format(m.timestamp.toLocal()),
            isUser: m.isUser,
          );
        }).toList(),
      );
    } catch (e) {
      toastification.show(
        type: ToastificationType.error,
        style: ToastificationStyle.fillColored,
        primaryColor: Colors.red,
        foregroundColor: Colors.white,
        title: Text(
          "Error",
          style: AppTextStyles.poppinsBold.copyWith(color: Colors.white),
        ),
        description: Text(
          "Could not load chat history",
          style: AppTextStyles.poppinsRegular.copyWith(color: Colors.white),
        ),
        alignment: Alignment.topRight,
        autoCloseDuration: const Duration(seconds: 4),
        borderRadius: BorderRadius.circular(12),
        showProgressBar: true,
      );
      print("Load error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> sendMessage() async {
    final text = textController.text.trim();
    if (text.isEmpty || isLoading.value) return;

    final now = DateTime.now();
    final timeString = DateFormat('h:mm a').format(now);

    // Show user message immediately
    messages.insert(0, Message(text: text, time: timeString, isUser: true));
    textController.clear();

    isLoading.value = true;

    try {
      await _chatService.sendMessage(text);
      await loadConversation(); // Refresh with real AI reply (even if it's an error)
    } catch (e) {
      toastification.show(
        type: ToastificationType.error,
        style: ToastificationStyle.fillColored,
        primaryColor: Colors.red,
        foregroundColor: Colors.white,
        title: Text(
          "Failed",
          style: AppTextStyles.poppinsBold.copyWith(color: Colors.white),
        ),
        description: Text(
          "Could not send message",
          style: AppTextStyles.poppinsRegular.copyWith(color: Colors.white),
        ),
        alignment: Alignment.topRight,
        autoCloseDuration: const Duration(seconds: 4),
        borderRadius: BorderRadius.circular(12),
        showProgressBar: true,
      );
      messages.removeAt(0); // remove failed message
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    textController.dispose();
    super.onClose();
  }
}
