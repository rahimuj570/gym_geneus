// lib/app/data/services/chat_service.dart

import 'dart:convert';
import 'package:get/get.dart';
import 'package:kenzeno/app/constants/appconstants.dart';
import 'package:kenzeno/app/services/api_client.dart';
import '../model/chat_model.dart';

class ChatService extends GetxService {
  Future<ChatConversation> getConversation() async {
    final url = Uri.parse('${AppConstants.baseUrl}/ai_assistant/');

    try {
      final response = await ApiClient.get(
        url,
        tag: 'Chat-GetConversation',
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(utf8.decode(response.bodyBytes));
        return ChatConversation.fromJson(decoded);
      } else if (response.statusCode == 401) {
        throw Exception("Session expired. Please login again.");
      } else if (response.statusCode == 403) {
        throw Exception("You don't have permission to access this chat.");
      } else {
        throw Exception("Failed to load chat (HTTP ${response.statusCode})");
      }
    } catch (e) {
      print("ChatService.getConversation() ERROR: $e");
      rethrow;
    }
  }

  Future<void> sendMessage(String userInput) async {
    final url = Uri.parse('${AppConstants.baseUrl}/ai_assistant/');

    try {
      final response = await ApiClient.post(
        url,
        body: {"user_input": userInput},
        tag: 'Chat-SendMessage',
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return; // Success
      } else if (response.statusCode == 401) {
        throw Exception("Your session has expired. Please login again.");
      } else {
        throw Exception("Failed to send message (HTTP ${response.statusCode})");
      }
    } catch (e) {
      print("ChatService.sendMessage() ERROR: $e");
      rethrow;
    }
  }
}
