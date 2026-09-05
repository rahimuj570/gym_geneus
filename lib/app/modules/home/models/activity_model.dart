// lib/app/modules/progress/models/activity_model.dart

import 'package:intl/intl.dart';

class WorkoutActivity {
  final int id;
  final String name;
  final int duration; // in minutes (comes as int from backend)
  final int calories; // now safely accepts both int and double (500 or 500.0)
  final DateTime createdAt;

  WorkoutActivity({
    required this.id,
    required this.name,
    required this.duration,
    required this.calories,
    required this.createdAt,
  });

  factory WorkoutActivity.fromJson(Map<String, dynamic> json) {
    return WorkoutActivity(
      id: json['id'] as int,
      name: json['name'] as String,
      duration: json['duration'] as int,

      // This line fixes the crash: accepts both int and double
      calories: (json['calories'] as num).toInt(),

      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  // Display: "500 KCal • 14 Nov"
  String get displayDetails {
    final day = createdAt.day;
    final month = DateFormat('MMM').format(createdAt);
    return '$calories KCal • $day $month';
  }

  // Display: "50 Mins"
  String get displayDuration => '$duration Mins';
}
