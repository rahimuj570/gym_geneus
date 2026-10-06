// lib/app/modules/community/models/post_model.dart

import '../../../constants/appconstants.dart';

class ForumPost {
  final int id;
  final String userId;
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
    this.userId = '',
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
      userId: (json['user_id'] ??
              json['user'] ??
              json['author_id'] ??
              json['author'] ??
              '')
          .toString(),
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
    String? userId,
    String? content,
    int? likes,
    int? comments,
    bool? isLiked,
  }) {
    return ForumPost(
      id: id,
      userId: userId ?? this.userId,
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

class ForumComment {
  final int id;
  final int postId;
  final String userId;
  final String userName;
  final String? avatar;
  final String content;
  final bool isOwner;
  final DateTime createdAt;
  final DateTime updatedAt;

  ForumComment({
    required this.id,
    required this.postId,
    this.userId = '',
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
      userId: (json['user_id'] ??
              json['user'] ??
              json['author_id'] ??
              json['author'] ??
              '')
          .toString(),
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

  ForumComment copyWith({String? content, bool? isOwner, String? userId}) {
    return ForumComment(
      id: id,
      postId: postId,
      userId: userId ?? this.userId,
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

class BlockedUser {
  final int id;
  final String blockedUserId;
  final String blockedUserName;
  final String blockedUserEmail;
  final String? blockedUserAvatar;
  final String? reason;
  final DateTime? createdAt;

  BlockedUser({
    required this.id,
    required this.blockedUserId,
    required this.blockedUserName,
    required this.blockedUserEmail,
    this.blockedUserAvatar,
    this.reason,
    this.createdAt,
  });

  factory BlockedUser.fromJson(Map<String, dynamic> json) {
    return BlockedUser(
      id: json['id'] ?? 0,
      blockedUserId: (json['blocked_user_id'] ??
              json['blocked'] ??
              json['user_id'] ??
              json['id'] ??
              '')
          .toString(),
      blockedUserName: json['blocked_user_name'] ?? 'User',
      blockedUserEmail: json['blocked_user_email'] ?? '',
      blockedUserAvatar: _getFullImageUrl(json['blocked_user_avatar'] as String?),
      reason: json['reason'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }
}

class BlockedUsersResponse {
  final int count;
  final String? next;
  final String? previous;
  final List<BlockedUser> results;

  BlockedUsersResponse({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory BlockedUsersResponse.fromJson(Map<String, dynamic> json) {
    final rawResults = json['results'] as List? ?? [];
    return BlockedUsersResponse(
      count: json['count'] ?? 0,
      next: json['next'],
      previous: json['previous'],
      results: rawResults
          .map((e) => BlockedUser.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

// Helper to format image URLs
String? _getFullImageUrl(String? path) {
  if (path == null || path.isEmpty || path == 'null') return null;
  if (path.startsWith('http')) return path;
  final base = AppConstants.baseUrl.replaceAll('/api', '');
  return '$base$path';
}
