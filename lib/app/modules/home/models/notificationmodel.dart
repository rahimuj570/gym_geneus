class NotificationItem {
  final String id;
  final String message;
  final String date;
  final String time;
  final bool isReminder; // true if it belongs to Reminders tab
  final String iconPath; // SVG path or asset path
  final bool hasRedDot; // Indicates unread/new status

  NotificationItem({
    required this.id,
    required this.message,
    required this.date,
    required this.time,
    required this.isReminder,
    required this.iconPath,
    this.hasRedDot = true,
  });
}

class GroupedNotification {
  final String dateHeader;
  final List<NotificationItem> items;

  GroupedNotification({required this.dateHeader, required this.items});
}
