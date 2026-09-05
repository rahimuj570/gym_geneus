// lib/app/data/models/workout_video.dart

class WorkoutVideo {
  final int id;
  final String videoUrl;
  final String title;
  final String description;
  final int durationMinutes;
  final DateTime createdAt;

  WorkoutVideo({
    required this.id,
    required this.videoUrl,
    required this.title,
    required this.description,
    required this.durationMinutes,
    required this.createdAt,
  });

  factory WorkoutVideo.fromJson(Map<String, dynamic> json) {
    return WorkoutVideo(
      id: json['id'],
      videoUrl: json['video_url'],
      title: json['title'],
      description: json['description'],
      durationMinutes: json['duration_minutes'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
