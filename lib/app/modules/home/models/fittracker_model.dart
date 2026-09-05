// lib/app/modules/gallery/models/gallery_dashboard_model.dart

import '../../../constants/appconstants.dart';
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
    if (json['date_image_types'] != null && json['date_image_types'] is Map) {
      (json['date_image_types'] as Map).forEach((key, value) {
        if (value is List) {
          typesMap[key.toString()] = List<String>.from(value.map((e) => e.toString()));
        }
      });
    }

    var images = <GalleryImage>[];
    if (json['latest_images'] != null && json['latest_images'] is List) {
      images = List<GalleryImage>.from(
        (json['latest_images'] as List).map((x) => GalleryImage.fromJson(x as Map<String, dynamic>)),
      );
    }

    return GalleryDashboardResponse(
      totalImages: (json['total_images'] as num?)?.toInt() ?? 0,
      imagesLastWeek: (json['images_last_week'] as num?)?.toInt() ?? 0,
      consecutiveDaysStreak: (json['consecutive_days_streak'] as num?)?.toInt() ?? 0,
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

  static String _formatImageUrl(dynamic path) {
    if (path == null) return '';
    final str = path.toString();
    if (str.isEmpty) return '';
    if (str.startsWith('http://') || str.startsWith('https://')) {
      return str;
    }
    return '${AppConstants.baseUrimage}$str';
  }

  factory GalleryImage.fromJson(Map<String, dynamic> json) {
    return GalleryImage(
      id: (json['id'] as num?)?.toInt() ?? 0,
      imageUrl: _formatImageUrl(json['image']),
      imageType: json['image_type']?.toString() ?? 'front',
      aiDetected: json['ai_detected'] == true,
      aiSummary: json['ai_summary']?.toString(),
      uploadedAt: json['uploaded_at'] != null
          ? (DateTime.tryParse(json['uploaded_at'].toString()) ?? DateTime.now())
          : DateTime.now(),
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

