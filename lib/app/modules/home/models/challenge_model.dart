import '../../workout/model/workoutmodel.dart';

class ChallengeResponse {
  final bool success;
  final int count;
  final List<Challenge> data;

  ChallengeResponse({
    required this.success,
    required this.count,
    required this.data,
  });

  factory ChallengeResponse.fromJson(Map<String, dynamic> json) {
    return ChallengeResponse(
      success: json['success'] ?? false,
      count: json['count'] ?? 0,
      data: (json['data'] as List)
          .map((item) => Challenge.fromJson(item))
          .toList(),
    );
  }
}

class Challenge {
  final int id;
  final String name;
  final String description;
  final String challengeType;
  final String challengeTypeDisplay;
  final String difficulty;
  final String difficultyDisplay;
  final int completionPoints;
  final DateTime startDate;
  final DateTime endDate;
  final List<UserExercise> exercises; // Reusing your model!
  final int estimatedDuration;
  final int estimatedCalories;
  final bool isActive;
  final bool isAvailable;
  final double timeRemainingSeconds;
  final DateTime createdAt;

  Challenge({
    required this.id,
    required this.name,
    required this.description,
    required this.challengeType,
    required this.challengeTypeDisplay,
    required this.difficulty,
    required this.difficultyDisplay,
    required this.completionPoints,
    required this.startDate,
    required this.endDate,
    required this.exercises,
    required this.estimatedDuration,
    required this.estimatedCalories,
    required this.isActive,
    required this.isAvailable,
    required this.timeRemainingSeconds,
    required this.createdAt,
  });

  factory Challenge.fromJson(Map<String, dynamic> json) {
    return Challenge(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      challengeType: json['challenge_type'] ?? '',
      challengeTypeDisplay: json['challenge_type_display'] ?? '',
      difficulty: json['difficulty'] ?? '',
      difficultyDisplay: json['difficulty_display'] ?? '',
      completionPoints: json['completion_points'] ?? 0,
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      exercises: (json['exercises'] as List)
          .map(
            (e) =>
                UserExercise.fromJson(_mapChallengeExerciseToUserExercise(e)),
          )
          .toList(),
      estimatedDuration: json['estimated_duration'] ?? 0,
      estimatedCalories: json['estimated_calories'] ?? 0,
      isActive: json['is_active'] ?? false,
      isAvailable: json['is_available'] ?? false,
      timeRemainingSeconds: (json['time_remaining_seconds'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  // Helper to map challenge exercise → your UserExercise format
  static Map<String, dynamic> _mapChallengeExerciseToUserExercise(
    Map<String, dynamic> json,
  ) {
    return {
      'id': json['exercise_id'],
      'exercise_name': json['name'],
      'exercise_description': json['description'] ?? '',
      'video': json['video'],
      'sets': json['sets'],
      'reps': json['reps'],
      'duration_seconds': 0, // fallback – not in challenge response
      'rest_time': json['rest_time'],
      'order': 0, // you can add order logic later if needed
      'notes': json['notes'] ?? '',
    };
  }

  String get formattedTimeRemaining {
    final duration = Duration(seconds: timeRemainingSeconds.floor());
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    if (hours > 0) return '$hours h $minutes min left';
    return '$minutes min left';
  }
}
