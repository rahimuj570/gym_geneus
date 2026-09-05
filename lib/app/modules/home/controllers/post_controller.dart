// lib/app/modules/community/controllers/forum_controller.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import '../../../constants/appconstants.dart';
import '../models/post_modeel.dart';

import '../../../res/colors/colors.dart';
import 'package:toastification/toastification.dart';
import 'package:kenzeno/app/res/fonts/textstyle.dart';
import 'package:kenzeno/app/res/colors/colors.dart';

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

      final response = await http
          .get(
            Uri.parse("${AppConstants.baseUrl}/community/forum-posts/"),
            headers: {
              "Authorization": "Bearer $token",
              "Accept": "application/json",
            },
          )
          .timeout(const Duration(seconds: 15));

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
      final response = await http.get(
        Uri.parse("${AppConstants.baseUrl}/community/forum-comments/$postId/"),
        headers: {"Authorization": "Bearer $token"},
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
      print("Fetch comments error: $e");
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

    try {
      final response = await http.post(
        Uri.parse("${AppConstants.baseUrl}/community/forum-post-like/"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({"post": id}),
      );
      print(response.statusCode);

      refreshPosts();
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
          "Check your connection",
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
      final response = await http.post(
        Uri.parse("${AppConstants.baseUrl}/community/forum-comment-create/"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({"post": postId, "content": content.trim()}),
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
      print("Create comment error: $e");
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
      final response = await http.patch(
        Uri.parse("${AppConstants.baseUrl}/community/forum-posts/$postId/"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({"content": newContent.trim()}),
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
      print("Update post error: $e");
    } finally {
      isPosting.value = false;
    }
    return false;
  }

  Future<bool> deleteForumPost({required int postId}) async {
    final token = box.read("loginToken");
    if (token == null) return false;

    try {
      final response = await http.delete(
        Uri.parse("${AppConstants.baseUrl}/community/forum-posts/$postId/"),
        headers: {"Authorization": "Bearer $token"},
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
      final response = await http.patch(
        Uri.parse(
          "${AppConstants.baseUrl}/community/forum-comment/$commentId/",
        ),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({"content": newContent.trim()}),
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
      print("Update comment error: $e");
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
      final response = await http.delete(
        Uri.parse(
          "${AppConstants.baseUrl}/community/forum-comment/$commentId/",
        ),
        headers: {"Authorization": "Bearer $token"},
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
      print("Delete comment error: $e");
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
      final response = await http.post(
        Uri.parse("${AppConstants.baseUrl}/community/forum-posts/"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({"content": content.trim()}),
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
      print("Create post error: $e");
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
