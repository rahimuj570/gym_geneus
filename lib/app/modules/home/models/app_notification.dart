// lib/app/modules/notification/models/notification_model.dart

import 'package:intl/intl.dart';
import 'package:sync_datetime/sync_datetime.dart';

class AppNotification {
  final int id;
  final String title;
  final String message;
  final String notificationType; // "reminder" or "system"
  final bool isRead;
  final DateTime createdAt;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.notificationType,
    required this.isRead,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'],
      title: json['title'] ?? 'Notification',
      message: json['message'],
      notificationType: json['notification_type'], // reminder or system
      isRead: json['is_read'] ?? false,
      createdAt: SyncDateTime.fromUtc(DateTime.parse(json['created_at'])),
    );
  }

  AppNotification copyWith({
    int? id,
    String? title,
    String? message,
    String? notificationType,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      notificationType: notificationType ?? this.notificationType,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Format date like: Today, Yesterday, June 10
  String get formattedDate {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final date = DateTime(createdAt.year, createdAt.month, createdAt.day);

    if (date == today) return 'Today';
    if (date == yesterday) return 'Yesterday';
    return DateFormat('MMMM d').format(createdAt); // e.g. June 10
  }

  String get formattedTime =>
      DateFormat('h:mm a').format(createdAt); // 10:00 AM
}

class GroupedNotification {
  final String dateHeader;
  final List<AppNotification> items;

  GroupedNotification({required this.dateHeader, required this.items});
}
