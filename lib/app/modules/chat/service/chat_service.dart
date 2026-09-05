// lib/app/data/services/chat_service.dart

import 'dart:convert';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:kenzeno/app/constants/appconstants.dart';
import '../model/chat_model.dart';

class ChatService extends GetxService {
  final box = GetStorage();

  // Helper to get token safely
  String? _getToken() {
    final token = box.read("loginToken");
    if (token == null || token.toString().isEmpty) {
      print("No login token found in GetStorage");
      return null;
    }
    return token.toString();
  }

  // Common headers with Bearer token
  Map<String, String> get _authHeaders {
    final token = _getToken();
    return {
      "Content-Type": "application/json",
      "Accept": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };
  }

  Future<ChatConversation> getConversation() async {
    final token = _getToken();
    if (token == null) {
      throw Exception("Please login to access chat");
    }

    final url = Uri.parse('${AppConstants.baseUrl}/ai_assistant/');
    print("Fetching chat from: $url");

    try {
      final response = await http.get(url, headers: _authHeaders);

      print("GET /ai_assistant/ → Status: ${response.statusCode}");
      print(
        "Response body: ${response.body.substring(0, response.body.length.clamp(0, 500))}...",
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
    final token = _getToken();
    if (token == null) {
      throw Exception("Login required to send message");
    }

    final url = Uri.parse('${AppConstants.baseUrl}/ai_assistant/');
    print("Sending message to: $url");
    print("Payload: {\"user_input\": \"$userInput\"}");

    try {
      final response = await http.post(
        url,
        headers: _authHeaders,
        body: jsonEncode({"user_input": userInput}),
      );

      print("POST /ai_assistant/ → Status: ${response.statusCode}");
      print("Response: ${response.body}");

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
