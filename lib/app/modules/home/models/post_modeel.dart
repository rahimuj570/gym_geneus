// lib/app/modules/community/models/post_model.dart

import 'package:get/get.dart';

class ForumPost {
  final int id;
  final String userName;
  final String? avatar;
  final String content;
  final int likes;
  final int comments;
  final bool isOwner;
  final bool isLiked;
  final DateTime createdAt;
  final DateTime updatedAt;

  ForumPost({
    required this.id,
    required this.userName,
    this.avatar,
    required this.content,
    required this.likes,
    required this.comments,
    required this.isOwner,
    required this.isLiked,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ForumPost.fromJson(Map<String, dynamic> json) {
    return ForumPost(
      id: json['id'] ?? 0,
      userName: (json['user_name'] as String?)?.trim().isNotEmpty == true
          ? json['user_name']
          : 'Anonymous',
      avatar: _getFullImageUrl(json['avatar'] as String?),
      content: (json['content'] as String?)?.trim() ?? 'No content',
      likes: json['likes'] ?? 0,
      comments: json['comments'] ?? json['comment_count'] ?? 0,
      isOwner: json['is_owner'] == true,
      isLiked: json['is_liked'] == true,
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(json['updated_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  // For optimistic UI updates (like/dislike)
  ForumPost copyWith({
    String? content,
    int? likes,
    int? comments,
    bool? isLiked,
  }) {
    return ForumPost(
      id: id,
      userName: userName,
      avatar: avatar,
      content: content ?? this.content,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      isOwner: isOwner,
      isLiked: isLiked ?? this.isLiked,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  // Critical for GetX list reactivity
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ForumPost && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

// lib/app/modules/community/models/post_model.dart (or comment_model.dart)

class ForumComment {
  final int id;
  final int postId;
  final String userName;
  final String? avatar;
  final String content;
  final bool isOwner;
  final DateTime createdAt;
  final DateTime updatedAt;

  ForumComment({
    required this.id,
    required this.postId,
    required this.userName,
    this.avatar,
    required this.content,
    required this.isOwner,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ForumComment.fromJson(Map<String, dynamic> json) {
    final String? rawName = json['user_name'] as String?;
    final String name = (rawName != null && rawName.trim().isNotEmpty)
        ? rawName.trim()
        : 'Anonymous';

    return ForumComment(
      id: json['id'] ?? 0,
      postId: json['post'] ?? 0,
      userName: name,
      avatar: _getFullImageUrl(json['avatar'] as String?),
      content: (json['content'] as String?)?.trim() ?? 'No content',
      isOwner: json['is_owner'] == true,
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(json['updated_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  // Optional: For future updates (e.g. editing comment)
  ForumComment copyWith({String? content, bool? isOwner}) {
    return ForumComment(
      id: id,
      postId: postId,
      userName: userName,
      avatar: avatar,
      content: content ?? this.content,
      isOwner: isOwner ?? this.isOwner,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ForumComment &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

// Keep this helper at the bottom of the file
String? _getFullImageUrl(String? path) {
  if (path == null || path.isEmpty || path == 'null') return null;
  if (path.startsWith('http')) return path;

  // CHANGE THIS TO YOUR BASE URL
  const String baseUrl = 'http://172.252.13.85'; // Your current local IP
  // Or better: use your AppConstants.baseUrl
  // return '${AppConstants.baseUrl}$path';

  return '$baseUrl$path';
}
