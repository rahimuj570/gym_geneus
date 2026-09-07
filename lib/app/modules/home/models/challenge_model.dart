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
  final DateTime? startDate;
  final DateTime? endDate;
  final List<UserExercise> exercises; // Reusing your model!
  final int exerciseCount;
  final int estimatedDuration;
  final int estimatedCalories;
  final bool isActive;
  final bool isAvailable;
  final double timeRemainingSeconds;
  final DateTime? createdAt;

  Challenge({
    required this.id,
    required this.name,
    required this.description,
    required this.challengeType,
    required this.challengeTypeDisplay,
    required this.difficulty,
    required this.difficultyDisplay,
    required this.completionPoints,
    this.startDate,
    this.endDate,
    this.exercises = const [],
    this.exerciseCount = 0,
    required this.estimatedDuration,
    required this.estimatedCalories,
    required this.isActive,
    required this.isAvailable,
    this.timeRemainingSeconds = 0.0,
    this.createdAt,
  });

  factory Challenge.fromJson(Map<String, dynamic> json) {
    int parsedDuration = 0;
    if (json['estimated_duration'] is int) {
      parsedDuration = json['estimated_duration'];
    } else if (json['estimated_duration'] != null) {
      parsedDuration = int.tryParse(json['estimated_duration'].toString()) ?? 0;
    }

    int parsedCalories = 0;
    if (json['estimated_calories'] is int) {
      parsedCalories = json['estimated_calories'];
    } else if (json['estimated_calories'] != null) {
      parsedCalories = int.tryParse(json['estimated_calories'].toString()) ?? 0;
    }

    int parsedExerciseCount = 0;
    if (json['exercise_count'] is int) {
      parsedExerciseCount = json['exercise_count'];
    } else if (json['exercises'] is List) {
      parsedExerciseCount = (json['exercises'] as List).length;
    }

    List<UserExercise> parsedExercises = [];
    if (json['exercises'] != null && json['exercises'] is List) {
      parsedExercises = (json['exercises'] as List)
          .map(
            (e) =>
                UserExercise.fromJson(_mapChallengeExerciseToUserExercise(e as Map<String, dynamic>)),
          )
          .toList();
    }

    return Challenge(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      challengeType: json['challenge_type'] as String? ?? '',
      challengeTypeDisplay: json['challenge_type_display'] as String? ?? 'Daily Challenge',
      difficulty: json['difficulty'] as String? ?? '',
      difficultyDisplay: json['difficulty_display'] as String? ?? '',
      completionPoints: json['completion_points'] as int? ?? 0,
      startDate: json['start_date'] != null ? DateTime.tryParse(json['start_date'].toString()) : null,
      endDate: json['end_date'] != null ? DateTime.tryParse(json['end_date'].toString()) : null,
      exercises: parsedExercises,
      exerciseCount: parsedExerciseCount,
      estimatedDuration: parsedDuration,
      estimatedCalories: parsedCalories,
      isActive: json['is_active'] as bool? ?? false,
      isAvailable: json['is_available'] as bool? ?? false,
      timeRemainingSeconds: (json['time_remaining_seconds'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
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
