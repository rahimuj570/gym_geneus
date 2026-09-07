// lib/app/data/models/workout_video.dart

class WorkoutVideo {
  final int id;
  final String videoUrl;
  final String title;
  final String description;
  final int durationMinutes;
  final DateTime createdAt;
  final bool isFavorite;

  WorkoutVideo({
    required this.id,
    required this.videoUrl,
    required this.title,
    required this.description,
    required this.durationMinutes,
    required this.createdAt,
    this.isFavorite = false,
  });

  factory WorkoutVideo.fromJson(Map<String, dynamic> json) {
    int parsedId = 0;
    if (json['id'] is int) {
      parsedId = json['id'];
    } else if (json['id'] != null) {
      parsedId = int.tryParse(json['id'].toString()) ?? 0;
    }

    int parsedDuration = 0;
    final dur =
        json['duration_minutes'] ?? json['duration'] ?? json['durationMinutes'];
    if (dur is int) {
      parsedDuration = dur;
    } else if (dur != null) {
      parsedDuration = int.tryParse(dur.toString()) ?? 0;
    }

    final rawVideoUrl =
        json['video_url'] ??
        json['video'] ??
        json['media_url'] ??
        json['url'] ??
        json['file'] ??
        '';

    return WorkoutVideo(
      id: parsedId,
      videoUrl: rawVideoUrl.toString(),
      title: (json['title'] ?? json['name'] ?? 'Workout Video').toString(),
      description: (json['description'] ?? json['desc'] ?? '').toString(),
      durationMinutes: parsedDuration,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      isFavorite: json['is_favorite'] as bool? ?? false,
    );
  }

  WorkoutVideo copyWith({
    int? id,
    String? videoUrl,
    String? title,
    String? description,
    int? durationMinutes,
    DateTime? createdAt,
    bool? isFavorite,
  }) {
    return WorkoutVideo(
      id: id ?? this.id,
      videoUrl: videoUrl ?? this.videoUrl,
      title: title ?? this.title,
      description: description ?? this.description,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      createdAt: createdAt ?? this.createdAt,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
