// lib/app/models/track_progress.dart

class TrackProgress {
  final int progressPercentage;
  final int caloriesBurned;
  final int totalTrainingTime; // in minutes

  const TrackProgress({
    required this.progressPercentage,
    required this.caloriesBurned,
    required this.totalTrainingTime,
  });

  factory TrackProgress.fromJson(Map<String, dynamic> json) {
    return TrackProgress(
      progressPercentage: (json['progress_percentage'] as num?)?.toInt() ?? 0,
      caloriesBurned: (json['calories_burned'] as num?)?.toInt() ?? 0,
      totalTrainingTime: (json['total_training_time'] as num?)?.toInt() ?? 0,
    );
  }

  @override
  String toString() {
    return 'TrackProgress(progress: $progressPercentage%, calories: $caloriesBurned, time: $totalTrainingTime mins)';
  }
}
