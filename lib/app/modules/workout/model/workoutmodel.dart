// lib/models/workout.dart

class UserExercise {
  final int id;
  final String exerciseName;
  final String exerciseDescription;
  final String? videoUrl;
  final int sets;
  final int reps;
  final int durationSeconds;
  final int restTime;
  final int order;
  final String notes;

  UserExercise({
    required this.id,
    required this.exerciseName,
    required this.exerciseDescription,
    this.videoUrl,
    required this.sets,
    required this.reps,
    required this.durationSeconds,
    required this.restTime,
    required this.order,
    required this.notes,
  });

  factory UserExercise.fromJson(Map<String, dynamic> json) {
    return UserExercise(
      id: json['id'],
      exerciseName: json['exercise_name'] ?? 'Unnamed Exercise',
      exerciseDescription: json['exercise_description'] ?? '',
      videoUrl: json['video'], // can be null
      sets: json['sets'] ?? 0,
      reps: json['reps'] ?? 0,
      durationSeconds: json['duration_seconds'] ?? 0,
      restTime: json['rest_time'] ?? 60,
      order: json['order'] ?? 0,
      notes: json['notes'] ?? '',
    );
  }
}

class WorkoutProgress {
  final int? id;
  final String? completedAt;
  final List<dynamic> completedExercises;
  final int completionPercentage;
  final int? userWorkout;

  WorkoutProgress({
    this.id,
    this.completedAt,
    this.completedExercises = const [],
    this.completionPercentage = 0,
    this.userWorkout,
  });

  factory WorkoutProgress.fromJson(Map<String, dynamic> json) {
    return WorkoutProgress(
      id: json['id'] as int?,
      completedAt: json['completed_at'] as String?,
      completedExercises: (json['completed_exercises'] as List?) ?? [],
      completionPercentage: json['completion_percentage'] is int
          ? json['completion_percentage']
          : int.tryParse(json['completion_percentage']?.toString() ?? '0') ?? 0,
      userWorkout: json['user_workout'] as int?,
    );
  }
}

class WorkoutProgressResponse {
  final WorkoutProgress? workoutProgress;
  final String? workoutName;
  final int totalExercises;
  final int completedExercisesCount;
  final int completionPercentage;
  final bool allCompleted;

  WorkoutProgressResponse({
    this.workoutProgress,
    this.workoutName,
    this.totalExercises = 0,
    this.completedExercisesCount = 0,
    this.completionPercentage = 0,
    this.allCompleted = false,
  });

  factory WorkoutProgressResponse.fromJson(Map<String, dynamic> json) {
    final progressJson = json['workout_progress'];
    return WorkoutProgressResponse(
      workoutProgress: progressJson is Map<String, dynamic>
          ? WorkoutProgress.fromJson(progressJson)
          : null,
      workoutName: json['workout_name'] as String?,
      totalExercises: json['total_exercises'] is int
          ? json['total_exercises']
          : int.tryParse(json['total_exercises']?.toString() ?? '0') ?? 0,
      completedExercisesCount: json['completed_exercises'] is int
          ? json['completed_exercises']
          : (json['completed_exercises'] is List
              ? (json['completed_exercises'] as List).length
              : int.tryParse(json['completed_exercises']?.toString() ?? '0') ?? 0),
      completionPercentage: json['completion_percentage'] is int
          ? json['completion_percentage']
          : int.tryParse(json['completion_percentage']?.toString() ?? '0') ?? 0,
      allCompleted: json['all_completed'] as bool? ?? false,
    );
  }
}

class Workout {
  final int id;
  final String name;
  final String description;
  final String? image; // ← was String, now String? (null in API)
  final String estimatedDuration;
  final String estimatedCalories;
  final int exerciseCount;
  final String difficulty;
  final bool isFavorite;
  final List<UserExercise>? exercises; // ← can be null if not loaded
  final WorkoutProgress? progress;

  Workout({
    required this.id,
    required this.name,
    required this.description,
    this.image,
    required this.estimatedDuration,
    required this.estimatedCalories,
    required this.exerciseCount,
    required this.difficulty,
    this.isFavorite = false,
    this.exercises,
    this.progress,
  });

  factory Workout.fromJson(Map<String, dynamic> json) {
    return Workout(
      id: json['id'],
      name: json['name'] ?? 'Untitled Workout',
      description: json['description'] ?? '',
      image: json['image'], // ← now accepts null
      estimatedDuration: json['estimated_duration'] ?? 'N/A',
      estimatedCalories: json['estimated_calories'] ?? 'N/A',
      exerciseCount: json['exercise_count'] ?? 0,
      difficulty: (json['difficulty'] ?? json['difficulty_display'] ?? 'beginner'),
      isFavorite: json['is_favorite'] as bool? ?? false,
      exercises: json['user_exercises'] != null
          ? (json['user_exercises'] as List)
                .map((e) => UserExercise.fromJson(e))
                .toList()
          : null,
      progress: json['workout_progress'] != null
          ? WorkoutProgress.fromJson(json['workout_progress'])
          : (json['user_progress'] != null
              ? WorkoutProgress.fromJson(json['user_progress'])
              : null),
    );
  }

  Workout copyWith({
    int? id,
    String? name,
    String? description,
    String? image,
    String? estimatedDuration,
    String? estimatedCalories,
    int? exerciseCount,
    String? difficulty,
    bool? isFavorite,
    List<UserExercise>? exercises,
    WorkoutProgress? progress,
  }) {
    return Workout(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      image: image ?? this.image,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      estimatedCalories: estimatedCalories ?? this.estimatedCalories,
      exerciseCount: exerciseCount ?? this.exerciseCount,
      difficulty: difficulty ?? this.difficulty,
      isFavorite: isFavorite ?? this.isFavorite,
      exercises: exercises ?? this.exercises,
      progress: progress ?? this.progress,
    );
  }
}
