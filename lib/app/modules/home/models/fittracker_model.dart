// lib/app/modules/gallery/models/gallery_dashboard_model.dart

import '../views/calender.dart';

class GalleryDashboardResponse {
  final int totalImages;
  final int imagesLastWeek;
  final int consecutiveDaysStreak;
  final Map<String, List<String>>
  dateImageTypes; // "2025-11-28": ["Back", "Front"]
  final List<GalleryImage> latestImages;

  GalleryDashboardResponse({
    required this.totalImages,
    required this.imagesLastWeek,
    required this.consecutiveDaysStreak,
    required this.dateImageTypes,
    required this.latestImages,
  });

  factory GalleryDashboardResponse.fromJson(Map<String, dynamic> json) {
    var typesMap = <String, List<String>>{};
    if (json['date_image_types'] != null) {
      json['date_image_types'].forEach((key, value) {
        typesMap[key] = List<String>.from(value);
      });
    }

    var images = <GalleryImage>[];
    if (json['latest_images'] != null) {
      images = List<GalleryImage>.from(
        json['latest_images'].map((x) => GalleryImage.fromJson(x)),
      );
    }

    return GalleryDashboardResponse(
      totalImages: json['total_images'] ?? 0,
      imagesLastWeek: json['images_last_week'] ?? 0,
      consecutiveDaysStreak: json['consecutive_days_streak'] ?? 0,
      dateImageTypes: typesMap,
      latestImages: images,
    );
  }
}

class GalleryImage {
  final int id;
  final String imageUrl;
  final String imageType; // "front", "side", "back"
  final bool aiDetected;
  final String? aiSummary;
  final DateTime uploadedAt;

  GalleryImage({
    required this.id,
    required this.imageUrl,
    required this.imageType,
    required this.aiDetected,
    this.aiSummary,
    required this.uploadedAt,
  });

  factory GalleryImage.fromJson(Map<String, dynamic> json) {
    return GalleryImage(
      id: json['id'],
      imageUrl: json['image'],
      imageType: json['image_type'],
      aiDetected: json['ai_detected'] ?? false,
      aiSummary: json['ai_summary'],
      uploadedAt: DateTime.parse(json['uploaded_at']),
    );
  }

  ProgressType get progressType {
    switch (imageType.toLowerCase()) {
      case 'front':
        return ProgressType.front;
      case 'side':
        return ProgressType.side;
      case 'back':
        return ProgressType.back;
      default:
        return ProgressType.front;
    }
  }
}
