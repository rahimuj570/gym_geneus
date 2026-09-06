// lib/app/modules/community/controllers/forum_controller.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_debug_logger/flutter_debug_logger.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import '../../../constants/appconstants.dart';
import '../models/post_modeel.dart';

import '../../../res/colors/colors.dart';
import 'package:toastification/toastification.dart';
import 'package:kenzeno/app/res/fonts/textstyle.dart';

class ForumController extends GetxController {
  final box = GetStorage();

  var isLoading = true.obs;
  var posts = <ForumPost>[].obs;
  var comments = <ForumComment>[].obs;
  var isPosting = false.obs;
  var isLoadingComments = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchPosts();
  }

  Future<void> fetchPosts({bool showLoading = true}) async {
    if (showLoading) isLoading(true);
    try {
      final token = box.read("loginToken");
      if (token == null) throw Exception("Not logged in");

      final url = "${AppConstants.baseUrl}/community/forum-posts/";
      final response = await http
          .get(
            Uri.parse(url),
            headers: {
              "Authorization": "Bearer $token",
              "Accept": "application/json",
            },
          )
          .timeout(const Duration(seconds: 15));

      FlutterDebugLogger.printJsonResponse(
        url: url,
        method: Method.GET,
        tag: 'Forum-FetchPosts',
        statusCode: response.statusCode,
        responseBody: response.body,
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        final List<dynamic> results = jsonResponse['results'] ?? [];
        final fetched =
            results
                .map((e) => ForumPost.fromJson(e as Map<String, dynamic>))
                .toList()
              ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

        posts.assignAll(fetched);
      } else {
        throw Exception("Failed to load posts");
      }
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
          "Failed to load posts",
          style: AppTextStyles.poppinsRegular.copyWith(color: Colors.white),
        ),
        alignment: Alignment.topRight,
        autoCloseDuration: const Duration(seconds: 4),
        borderRadius: BorderRadius.circular(12),
        showProgressBar: true,
      );
    } finally {
      if (showLoading) isLoading(false);
    }
  }

  Future<void> fetchComments(int postId) async {
    final token = box.read("loginToken");
    if (token == null) return;

    try {
      isLoadingComments.value = true;
      final url = "${AppConstants.baseUrl}/community/forum-comments/$postId/";
      final response = await http.get(
        Uri.parse(url),
        headers: {"Authorization": "Bearer $token"},
      );

      FlutterDebugLogger.printJsonResponse(
        url: url,
        method: Method.GET,
        tag: 'Forum-FetchComments',
        statusCode: response.statusCode,
        responseBody: response.body,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(
          utf8.decode(response.bodyBytes),
        );
        final List<dynamic> results = json['results'] ?? [];

        comments.assignAll(
          results
              .map((e) => ForumComment.fromJson(e as Map<String, dynamic>))
              .toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt)),
        );
      }
    } catch (e) {
      comments.clear();
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
          "Failed to load comments",
          style: AppTextStyles.poppinsRegular.copyWith(color: Colors.white),
        ),
        alignment: Alignment.topRight,
        autoCloseDuration: const Duration(seconds: 4),
        borderRadius: BorderRadius.circular(12),
        showProgressBar: true,
      );
    } finally {
      isLoadingComments.value = false;
    }
  }

  // LIKE / UNLIKE POST (Optimistic + Instant UI)
  Future<void> toggleLike(int id) async {
    final token = box.read("loginToken");
    if (token == null) return;

    final index = posts.indexWhere((p) => p.id == id);
    if (index == -1) return;

    final originalPost = posts[index];
    final bool newIsLiked = !originalPost.isLiked;
    final int newLikes = newIsLiked
        ? originalPost.likes + 1
        : (originalPost.likes > 0 ? originalPost.likes - 1 : 0);

    // 1. Instantly update the post in the reactive GetX list
    posts[index] = originalPost.copyWith(
      isLiked: newIsLiked,
      likes: newLikes,
    );

    try {
      final url = "${AppConstants.baseUrl}/community/forum-post-like/";
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({"post": id}),
      );

      FlutterDebugLogger.printJsonResponse(
        url: url,
        method: Method.POST,
        tag: 'Forum-ToggleLike',
        statusCode: response.statusCode,
        responseBody: response.body,
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        // Revert on non-success status code
        final revertIndex = posts.indexWhere((p) => p.id == id);
        if (revertIndex != -1) {
          posts[revertIndex] = originalPost;
        }
        throw Exception("Failed to update like");
      }
    } catch (e) {
      // Revert on exception
      final revertIndex = posts.indexWhere((p) => p.id == id);
      if (revertIndex != -1) {
        posts[revertIndex] = originalPost;
      }
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
          "Could not update like. Please check your connection.",
          style: AppTextStyles.poppinsRegular.copyWith(color: Colors.white),
        ),
        alignment: Alignment.topRight,
        autoCloseDuration: const Duration(seconds: 4),
        borderRadius: BorderRadius.circular(12),
        showProgressBar: true,
      );
    }
  }

  Future<bool> createComment({
    required int postId,
    required String content,
  }) async {
    final token = box.read("loginToken");
    if (token == null) return false;

    try {
      final url = "${AppConstants.baseUrl}/community/forum-comment-create/";
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({"post": postId, "content": content.trim()}),
      );

      FlutterDebugLogger.printJsonResponse(
        url: url,
        method: Method.POST,
        tag: 'Forum-CreateComment',
        statusCode: response.statusCode,
        responseBody: response.body,
      );

      if (response.statusCode == 201) {
        // Update comment count
        final postIndex = posts.indexWhere((p) => p.id == postId);
        if (postIndex != -1) {
          posts[postIndex] = posts[postIndex].copyWith(
            comments: posts[postIndex].comments + 1,
          );
          posts.refresh();
        }
        await fetchComments(postId);
        return true;
      }
    } catch (e) {
      // Logged or handled
    }
    return false;
  }

  Future<bool> updateForumPost({
    required int postId,
    required String newContent,
  }) async {
    final token = box.read("loginToken");
    if (token == null) return false;

    try {
      isPosting.value = true;
      final url = "${AppConstants.baseUrl}/community/forum-posts/$postId/";
      final response = await http.patch(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({"content": newContent.trim()}),
      );

      FlutterDebugLogger.printJsonResponse(
        url: url,
        method: Method.PATCH,
        tag: 'Forum-UpdatePost',
        statusCode: response.statusCode,
        responseBody: response.body,
      );

      if (response.statusCode == 200) {
        final index = posts.indexWhere((p) => p.id == postId);
        if (index != -1) {
          posts[index] = posts[index].copyWith(content: newContent.trim());
          posts.refresh();
        }
        toastification.show(
          type: ToastificationType.success,
          style: ToastificationStyle.fillColored,
          primaryColor: AppColor.green16A34A,
          foregroundColor: Colors.white,
          title: Text(
            "Success",
            style: AppTextStyles.poppinsBold.copyWith(color: Colors.white),
          ),
          description: Text(
            "Post updated",
            style: AppTextStyles.poppinsRegular.copyWith(color: Colors.white),
          ),
          alignment: Alignment.topRight,
          autoCloseDuration: const Duration(seconds: 4),
          borderRadius: BorderRadius.circular(12),
          showProgressBar: true,
        );
        return true;
      }
    } catch (e) {
      // Handled
    } finally {
      isPosting.value = false;
    }
    return false;
  }

  Future<bool> deleteForumPost({required int postId}) async {
    final token = box.read("loginToken");
    if (token == null) return false;

    try {
      final url = "${AppConstants.baseUrl}/community/forum-posts/$postId/";
      final response = await http.delete(
        Uri.parse(url),
        headers: {"Authorization": "Bearer $token"},
      );

      FlutterDebugLogger.printJsonResponse(
        url: url,
        method: Method.DELETE,
        tag: 'Forum-DeletePost',
        statusCode: response.statusCode,
        responseBody: response.body,
      );

      if (response.statusCode == 204 || response.statusCode == 200) {
        posts.removeWhere((p) => p.id == postId);
        toastification.show(
          type: ToastificationType.info,
          style: ToastificationStyle.fillColored,
          primaryColor: AppColor.green16A34A,
          foregroundColor: Colors.white,
          title: Text(
            "Deleted",
            style: AppTextStyles.poppinsBold.copyWith(color: Colors.white),
          ),
          description: Text(
            "Post removed",
            style: AppTextStyles.poppinsRegular.copyWith(color: Colors.white),
          ),
          alignment: Alignment.topRight,
          autoCloseDuration: const Duration(seconds: 4),
          borderRadius: BorderRadius.circular(12),
          showProgressBar: true,
        );
        return true;
      }
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
          "Failed to delete post",
          style: AppTextStyles.poppinsRegular.copyWith(color: Colors.white),
        ),
        alignment: Alignment.topRight,
        autoCloseDuration: const Duration(seconds: 4),
        borderRadius: BorderRadius.circular(12),
        showProgressBar: true,
      );
    }
    return false;
  }

  Future<bool> updateComment({
    required int commentId,
    required String newContent,
  }) async {
    final token = box.read("loginToken");
    if (token == null) return false;

    try {
      isLoadingComments.value = true;
      final url = "${AppConstants.baseUrl}/community/forum-comment/$commentId/";
      final response = await http.patch(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({"content": newContent.trim()}),
      );

      FlutterDebugLogger.printJsonResponse(
        url: url,
        method: Method.PATCH,
        tag: 'Forum-UpdateComment',
        statusCode: response.statusCode,
        responseBody: response.body,
      );

      if (response.statusCode == 200) {
        final index = comments.indexWhere((c) => c.id == commentId);
        if (index != -1) {
          comments[index] = comments[index].copyWith(
            content: newContent.trim(),
          );
          comments.refresh();
        }
        toastification.show(
          type: ToastificationType.info,
          style: ToastificationStyle.fillColored,
          primaryColor: AppColor.green16A34A,
          foregroundColor: Colors.white,
          title: Text(
            "Updated",
            style: AppTextStyles.poppinsBold.copyWith(color: Colors.white),
          ),
          description: Text(
            "Comment edited",
            style: AppTextStyles.poppinsRegular.copyWith(color: Colors.white),
          ),
          alignment: Alignment.topRight,
          autoCloseDuration: const Duration(seconds: 4),
          borderRadius: BorderRadius.circular(12),
          showProgressBar: true,
        );
        return true;
      }
    } catch (e) {
      // Handled
    } finally {
      isLoadingComments.value = false;
    }
    return false;
  }

  Future<bool> deleteComment({
    required int commentId,
    required int postId,
  }) async {
    final token = box.read("loginToken");
    if (token == null) return false;

    try {
      final url = "${AppConstants.baseUrl}/community/forum-comment/$commentId/";
      final response = await http.delete(
        Uri.parse(url),
        headers: {"Authorization": "Bearer $token"},
      );

      FlutterDebugLogger.printJsonResponse(
        url: url,
        method: Method.DELETE,
        tag: 'Forum-DeleteComment',
        statusCode: response.statusCode,
        responseBody: response.body,
      );

      if (response.statusCode == 204 || response.statusCode == 200) {
        comments.removeWhere((c) => c.id == commentId);
        comments.refresh();

        final postIndex = posts.indexWhere((p) => p.id == postId);
        if (postIndex != -1 && posts[postIndex].comments > 0) {
          posts[postIndex] = posts[postIndex].copyWith(
            comments: posts[postIndex].comments - 1,
          );
          posts.refresh();
        }

        toastification.show(
          type: ToastificationType.info,
          style: ToastificationStyle.fillColored,
          primaryColor: AppColor.green16A34A,
          foregroundColor: Colors.white,
          title: Text(
            "Deleted",
            style: AppTextStyles.poppinsBold.copyWith(color: Colors.white),
          ),
          description: Text(
            "Comment removed",
            style: AppTextStyles.poppinsRegular.copyWith(color: Colors.white),
          ),
          alignment: Alignment.topRight,
          autoCloseDuration: const Duration(seconds: 4),
          borderRadius: BorderRadius.circular(12),
          showProgressBar: true,
        );
        return true;
      }
    } catch (e) {
      // Handled
    }
    return false;
  }

  Future<bool> createForumPost({required String content}) async {
    final token = box.read("loginToken");
    if (token == null) {
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
          "Login required",
          style: AppTextStyles.poppinsRegular.copyWith(color: Colors.white),
        ),
        alignment: Alignment.topRight,
        autoCloseDuration: const Duration(seconds: 4),
        borderRadius: BorderRadius.circular(12),
        showProgressBar: true,
      );
      return false;
    }

    try {
      isPosting.value = true;
      final url = "${AppConstants.baseUrl}/community/forum-posts/";
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({"content": content.trim()}),
      );

      FlutterDebugLogger.printJsonResponse(
        url: url,
        method: Method.POST,
        tag: 'Forum-CreatePost',
        statusCode: response.statusCode,
        responseBody: response.body,
      );

      if (response.statusCode == 201) {
        final newPost = ForumPost.fromJson(jsonDecode(response.body));
        posts.insert(0, newPost);
        toastification.show(
          type: ToastificationType.success,
          style: ToastificationStyle.fillColored,
          primaryColor: AppColor.green16A34A,
          foregroundColor: Colors.white,
          title: Text(
            "Success",
            style: AppTextStyles.poppinsBold.copyWith(color: Colors.white),
          ),
          description: Text(
            "Posted!",
            style: AppTextStyles.poppinsRegular.copyWith(color: Colors.white),
          ),
          alignment: Alignment.topRight,
          autoCloseDuration: const Duration(seconds: 4),
          borderRadius: BorderRadius.circular(12),
          showProgressBar: true,
        );
        return true;
      }
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
          "Failed to post",
          style: AppTextStyles.poppinsRegular.copyWith(color: Colors.white),
        ),
        alignment: Alignment.topRight,
        autoCloseDuration: const Duration(seconds: 4),
        borderRadius: BorderRadius.circular(12),
        showProgressBar: true,
      );
    } finally {
      isPosting.value = false;
    }
    return false;
  }

  Future<void> refreshPosts() => fetchPosts(showLoading: false);
}
