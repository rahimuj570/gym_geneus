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
    );
  }
}
