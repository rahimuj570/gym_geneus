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
  final ChallengeUserProgress? userProgress;

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
    this.userProgress,
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
      final list = json['exercises'] as List;
      for (int i = 0; i < list.length; i++) {
        if (list[i] is Map<String, dynamic>) {
          parsedExercises.add(
            UserExercise.fromJson(
              _mapChallengeExerciseToUserExercise(
                list[i] as Map<String, dynamic>,
                i,
              ),
            ),
          );
        }
      }
    }

    ChallengeUserProgress? parsedUserProgress;
    if (json['user_progress'] != null &&
        json['user_progress'] is Map<String, dynamic>) {
      parsedUserProgress = ChallengeUserProgress.fromJson(
        json['user_progress'] as Map<String, dynamic>,
      );
    }

    return Challenge(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      challengeType: json['challenge_type'] as String? ?? '',
      challengeTypeDisplay:
          json['challenge_type_display'] as String? ?? 'Daily Challenge',
      difficulty: json['difficulty'] as String? ?? '',
      difficultyDisplay: json['difficulty_display'] as String? ?? '',
      completionPoints: json['completion_points'] as int? ?? 0,
      startDate: json['start_date'] != null
          ? DateTime.tryParse(json['start_date'].toString())
          : null,
      endDate: json['end_date'] != null
          ? DateTime.tryParse(json['end_date'].toString())
          : null,
      exercises: parsedExercises,
      exerciseCount: parsedExerciseCount,
      estimatedDuration: parsedDuration,
      estimatedCalories: parsedCalories,
      isActive: json['is_active'] as bool? ?? false,
      isAvailable: json['is_available'] as bool? ?? false,
      timeRemainingSeconds:
          (json['time_remaining_seconds'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      userProgress: parsedUserProgress,
    );
  }

  // Helper to map challenge exercise → your UserExercise format
  static Map<String, dynamic> _mapChallengeExerciseToUserExercise(
    Map<String, dynamic> json, [
    int index = 0,
  ]) {
    int duration = 3;
    if (json['duration_seconds'] is int) {
      duration = json['duration_seconds'];
    } else if (json['duration_seconds'] != null) {
      duration = int.tryParse(json['duration_seconds'].toString()) ?? 3;
    }

    return {
      'id': json['exercise_id'] ?? json['id'] ?? index,
      'exercise_name': json['name'] ?? 'Exercise',
      'exercise_description': json['description'] ?? '',
      'video': json['video'],
      'sets': json['sets'] is int
          ? json['sets']
          : (int.tryParse(json['sets']?.toString() ?? '') ?? 0),
      'reps': json['reps'] is int
          ? json['reps']
          : (int.tryParse(json['reps']?.toString() ?? '') ?? 0),
      'duration_seconds': duration,
      'rest_time': json['rest_time'] is int
          ? json['rest_time']
          : (int.tryParse(json['rest_time']?.toString() ?? '') ?? 0),
      'order': json['order'] ?? index,
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

class ChallengeUserProgress {
  final int id;
  final String status;
  final String statusDisplay;
  final List<dynamic> completedExercises;
  final double completionPercentage;
  final int pointsAwarded;
  final bool pointsClaimed;
  final String? notes;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime? updatedAt;

  ChallengeUserProgress({
    required this.id,
    this.status = '',
    this.statusDisplay = '',
    this.completedExercises = const [],
    this.completionPercentage = 0.0,
    this.pointsAwarded = 0,
    this.pointsClaimed = false,
    this.notes,
    this.startedAt,
    this.completedAt,
    this.updatedAt,
  });

  bool get isCompleted =>
      status.toUpperCase() == 'COMPLETED' || completionPercentage >= 100;

  factory ChallengeUserProgress.fromJson(Map<String, dynamic> json) {
    return ChallengeUserProgress(
      id: json['id'] as int? ?? 0,
      status: json['status'] as String? ?? '',
      statusDisplay: json['status_display'] as String? ?? '',
      completedExercises: (json['completed_exercises'] as List?) ?? [],
      completionPercentage:
          (json['completion_percentage'] as num?)?.toDouble() ?? 0.0,
      pointsAwarded: json['points_awarded'] as int? ?? 0,
      pointsClaimed: json['points_claimed'] as bool? ?? false,
      notes: json['notes'] as String?,
      startedAt: json['started_at'] != null
          ? DateTime.tryParse(json['started_at'].toString())
          : null,
      completedAt: json['completed_at'] != null
          ? DateTime.tryParse(json['completed_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }
}
