// lib/app/modules/community/controllers/forum_controller.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:kenzeno/app/services/api_client.dart';
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
      final url = "${AppConstants.baseUrl}/community/forum-posts/";
      final response = await ApiClient.get(
        Uri.parse(url),
        tag: 'Forum-FetchPosts',
      ).timeout(const Duration(seconds: 15));

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
    try {
      isLoadingComments.value = true;
      final url = "${AppConstants.baseUrl}/community/forum-comments/$postId/";
      final response = await ApiClient.get(
        Uri.parse(url),
        tag: 'Forum-FetchComments',
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
      final response = await ApiClient.post(
        Uri.parse(url),
        body: {"post": id},
        tag: 'Forum-ToggleLike',
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
    try {
      final url = "${AppConstants.baseUrl}/community/forum-comment-create/";
      final response = await ApiClient.post(
        Uri.parse(url),
        body: {"post": postId, "content": content.trim()},
        tag: 'Forum-CreateComment',
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
    try {
      isPosting.value = true;
      final url = "${AppConstants.baseUrl}/community/forum-posts/$postId/";
      final response = await ApiClient.patch(
        Uri.parse(url),
        body: {"content": newContent.trim()},
        tag: 'Forum-UpdatePost',
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
    try {
      final url = "${AppConstants.baseUrl}/community/forum-posts/$postId/";
      final response = await ApiClient.delete(
        Uri.parse(url),
        tag: 'Forum-DeletePost',
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
    try {
      isLoadingComments.value = true;
      final url = "${AppConstants.baseUrl}/community/forum-comment/$commentId/";
      final response = await ApiClient.patch(
        Uri.parse(url),
        body: {"content": newContent.trim()},
        tag: 'Forum-UpdateComment',
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
    try {
      final url = "${AppConstants.baseUrl}/community/forum-comment/$commentId/";
      final response = await ApiClient.delete(
        Uri.parse(url),
        tag: 'Forum-DeleteComment',
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
    try {
      isPosting.value = true;
      final url = "${AppConstants.baseUrl}/community/forum-posts/";
      final response = await ApiClient.post(
        Uri.parse(url),
        body: {"content": content.trim()},
        tag: 'Forum-CreatePost',
      );

      if (response.statusCode == 201) {
        final newPost = ForumPost.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
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

  // -------------------------------------------------------------
  // REPORT & BLOCK APIS
  // -------------------------------------------------------------

  var blockedUsers = <BlockedUser>[].obs;
  var isLoadingBlockedUsers = false.obs;

  /// Report a Forum Post: POST /api/community/report-post/
  Future<bool> reportPost({
    required int postId,
    required String reason,
    String description = '',
  }) async {
    try {
      final url = "${AppConstants.baseUrl}/community/report-post/";
      final payload = {
        "post": postId,
        "reason": reason,
        if (description.trim().isNotEmpty) "description": description.trim(),
      };

      final response = await ApiClient.post(
        Uri.parse(url),
        body: payload,
        tag: 'Forum-ReportPost',
      );

      final Map<String, dynamic> data = jsonDecode(
        utf8.decode(response.bodyBytes),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        toastification.show(
          type: ToastificationType.success,
          style: ToastificationStyle.fillColored,
          primaryColor: AppColor.green16A34A,
          foregroundColor: Colors.white,
          title: Text(
            "Report Submitted",
            style: AppTextStyles.poppinsBold.copyWith(color: Colors.white),
          ),
          description: Text(
            data['detail'] ?? "Post reported successfully. Our team will review it.",
            style: AppTextStyles.poppinsRegular.copyWith(color: Colors.white),
          ),
          alignment: Alignment.topRight,
          autoCloseDuration: const Duration(seconds: 4),
          borderRadius: BorderRadius.circular(12),
          showProgressBar: true,
        );
        return true;
      } else {
        final errorMsg = data['detail'] ??
            data['non_field_errors']?.first ??
            data['error'] ??
            "Failed to report post.";
        toastification.show(
          type: ToastificationType.error,
          style: ToastificationStyle.fillColored,
          primaryColor: Colors.red,
          foregroundColor: Colors.white,
          title: Text(
            "Report Error",
            style: AppTextStyles.poppinsBold.copyWith(color: Colors.white),
          ),
          description: Text(
            errorMsg.toString(),
            style: AppTextStyles.poppinsRegular.copyWith(color: Colors.white),
          ),
          alignment: Alignment.topRight,
          autoCloseDuration: const Duration(seconds: 4),
          borderRadius: BorderRadius.circular(12),
          showProgressBar: true,
        );
        return false;
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
          "An error occurred while reporting this post.",
          style: AppTextStyles.poppinsRegular.copyWith(color: Colors.white),
        ),
        alignment: Alignment.topRight,
        autoCloseDuration: const Duration(seconds: 4),
        borderRadius: BorderRadius.circular(12),
        showProgressBar: true,
      );
      return false;
    }
  }

  /// Report a Forum Comment: POST /api/community/report-comment/
  Future<bool> reportComment({
    required int commentId,
    required String reason,
    String description = '',
  }) async {
    try {
      final url = "${AppConstants.baseUrl}/community/report-comment/";
      final payload = {
        "comment": commentId,
        "reason": reason,
        if (description.trim().isNotEmpty) "description": description.trim(),
      };

      final response = await ApiClient.post(
        Uri.parse(url),
        body: payload,
        tag: 'Forum-ReportComment',
      );

      final Map<String, dynamic> data = jsonDecode(
        utf8.decode(response.bodyBytes),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        toastification.show(
          type: ToastificationType.success,
          style: ToastificationStyle.fillColored,
          primaryColor: AppColor.green16A34A,
          foregroundColor: Colors.white,
          title: Text(
            "Report Submitted",
            style: AppTextStyles.poppinsBold.copyWith(color: Colors.white),
          ),
          description: Text(
            data['detail'] ?? "Comment reported successfully. Our team will review it.",
            style: AppTextStyles.poppinsRegular.copyWith(color: Colors.white),
          ),
          alignment: Alignment.topRight,
          autoCloseDuration: const Duration(seconds: 4),
          borderRadius: BorderRadius.circular(12),
          showProgressBar: true,
        );
        return true;
      } else {
        final errorMsg = data['detail'] ??
            data['non_field_errors']?.first ??
            data['error'] ??
            "Failed to report comment.";
        toastification.show(
          type: ToastificationType.error,
          style: ToastificationStyle.fillColored,
          primaryColor: Colors.red,
          foregroundColor: Colors.white,
          title: Text(
            "Report Error",
            style: AppTextStyles.poppinsBold.copyWith(color: Colors.white),
          ),
          description: Text(
            errorMsg.toString(),
            style: AppTextStyles.poppinsRegular.copyWith(color: Colors.white),
          ),
          alignment: Alignment.topRight,
          autoCloseDuration: const Duration(seconds: 4),
          borderRadius: BorderRadius.circular(12),
          showProgressBar: true,
        );
        return false;
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
          "An error occurred while reporting this comment.",
          style: AppTextStyles.poppinsRegular.copyWith(color: Colors.white),
        ),
        alignment: Alignment.topRight,
        autoCloseDuration: const Duration(seconds: 4),
        borderRadius: BorderRadius.circular(12),
        showProgressBar: true,
      );
      return false;
    }
  }

  /// Block a User: POST /api/community/block-user/
  Future<bool> blockUser({
    required dynamic userId,
    String? reason,
    String? userName,
  }) async {
    try {
      final url = "${AppConstants.baseUrl}/community/block-user/";
      final payload = {
        "blocked": userId,
        if (reason != null && reason.trim().isNotEmpty) "reason": reason.trim(),
      };

      final response = await ApiClient.post(
        Uri.parse(url),
        body: payload,
        tag: 'Forum-BlockUser',
      );

      final Map<String, dynamic> data = jsonDecode(
        utf8.decode(response.bodyBytes),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final uIdStr = userId.toString();
        // Immediately remove their posts and comments from current view
        if (uIdStr.isNotEmpty && uIdStr != '0') {
          posts.removeWhere((p) => p.userId == uIdStr);
          comments.removeWhere((c) => c.userId == uIdStr);
        }
        if (userName != null && userName.isNotEmpty) {
          posts.removeWhere((p) => p.userName == userName);
          comments.removeWhere((c) => c.userName == userName);
        }

        toastification.show(
          type: ToastificationType.success,
          style: ToastificationStyle.fillColored,
          primaryColor: AppColor.green16A34A,
          foregroundColor: Colors.white,
          title: Text(
            "User Blocked",
            style: AppTextStyles.poppinsBold.copyWith(color: Colors.white),
          ),
          description: Text(
            data['detail'] ?? "User blocked successfully.",
            style: AppTextStyles.poppinsRegular.copyWith(color: Colors.white),
          ),
          alignment: Alignment.topRight,
          autoCloseDuration: const Duration(seconds: 4),
          borderRadius: BorderRadius.circular(12),
          showProgressBar: true,
        );
        return true;
      } else {
        final errorMsg = data['detail'] ??
            data['non_field_errors']?.first ??
            data['error'] ??
            "Failed to block user.";
        toastification.show(
          type: ToastificationType.error,
          style: ToastificationStyle.fillColored,
          primaryColor: Colors.red,
          foregroundColor: Colors.white,
          title: Text(
            "Block Error",
            style: AppTextStyles.poppinsBold.copyWith(color: Colors.white),
          ),
          description: Text(
            errorMsg.toString(),
            style: AppTextStyles.poppinsRegular.copyWith(color: Colors.white),
          ),
          alignment: Alignment.topRight,
          autoCloseDuration: const Duration(seconds: 4),
          borderRadius: BorderRadius.circular(12),
          showProgressBar: true,
        );
        return false;
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
          "An error occurred while blocking user.",
          style: AppTextStyles.poppinsRegular.copyWith(color: Colors.white),
        ),
        alignment: Alignment.topRight,
        autoCloseDuration: const Duration(seconds: 4),
        borderRadius: BorderRadius.circular(12),
        showProgressBar: true,
      );
      return false;
    }
  }

  /// Unblock a User: DELETE /api/community/unblock-user/{user_id}/
  Future<bool> unblockUser(dynamic userId) async {
    try {
      final url = "${AppConstants.baseUrl}/community/unblock-user/$userId/";
      final response = await ApiClient.delete(
        Uri.parse(url),
        tag: 'Forum-UnblockUser',
      );

      final Map<String, dynamic> data = jsonDecode(
        utf8.decode(response.bodyBytes),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        final uIdStr = userId.toString();
        blockedUsers.removeWhere((u) => u.blockedUserId == uIdStr);
        toastification.show(
          type: ToastificationType.success,
          style: ToastificationStyle.fillColored,
          primaryColor: AppColor.green16A34A,
          foregroundColor: Colors.white,
          title: Text(
            "User Unblocked",
            style: AppTextStyles.poppinsBold.copyWith(color: Colors.white),
          ),
          description: Text(
            data['detail'] ?? "User unblocked successfully.",
            style: AppTextStyles.poppinsRegular.copyWith(color: Colors.white),
          ),
          alignment: Alignment.topRight,
          autoCloseDuration: const Duration(seconds: 4),
          borderRadius: BorderRadius.circular(12),
          showProgressBar: true,
        );
        // Refresh feed so their posts reappear
        fetchPosts(showLoading: false);
        return true;
      } else {
        final errorMsg = data['detail'] ??
            data['non_field_errors']?.first ??
            "Failed to unblock user.";
        toastification.show(
          type: ToastificationType.error,
          style: ToastificationStyle.fillColored,
          primaryColor: Colors.red,
          foregroundColor: Colors.white,
          title: Text(
            "Unblock Error",
            style: AppTextStyles.poppinsBold.copyWith(color: Colors.white),
          ),
          description: Text(
            errorMsg.toString(),
            style: AppTextStyles.poppinsRegular.copyWith(color: Colors.white),
          ),
          alignment: Alignment.topRight,
          autoCloseDuration: const Duration(seconds: 4),
          borderRadius: BorderRadius.circular(12),
          showProgressBar: true,
        );
        return false;
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
          "An error occurred while unblocking user.",
          style: AppTextStyles.poppinsRegular.copyWith(color: Colors.white),
        ),
        alignment: Alignment.topRight,
        autoCloseDuration: const Duration(seconds: 4),
        borderRadius: BorderRadius.circular(12),
        showProgressBar: true,
      );
      return false;
    }
  }

  /// Get Blocked Users List: GET /api/community/blocked-users/
  Future<void> fetchBlockedUsers({int page = 1}) async {
    try {
      isLoadingBlockedUsers.value = true;
      final uri = Uri.parse(
        "${AppConstants.baseUrl}/community/blocked-users/",
      ).replace(queryParameters: {'page': page.toString()});

      final response = await ApiClient.get(
        uri,
        tag: 'Forum-BlockedUsers',
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(
          utf8.decode(response.bodyBytes),
        );
        final parsed = BlockedUsersResponse.fromJson(data);
        if (page == 1) {
          blockedUsers.assignAll(parsed.results);
        } else {
          blockedUsers.addAll(parsed.results);
        }
      }
    } catch (e) {
      // Handled
    } finally {
      isLoadingBlockedUsers.value = false;
    }
  }
}
