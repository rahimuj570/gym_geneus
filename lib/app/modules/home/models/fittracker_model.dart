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
      imageUrl: _formatImageUrl(json['image'] ?? json['image_url'] ?? json['photo']),
      imageType: (json['image_type'] ?? json['progress_type'] ?? json['type'] ?? json['pose'] ?? json['photo_type'])?.toString() ?? 'front',
      aiDetected: json['ai_detected'] == true || json['is_ai_detected'] == true,
      aiSummary: (json['ai_summary'] ?? json['summary'])?.toString(),
      uploadedAt: json['uploaded_at'] != null
          ? (DateTime.tryParse(json['uploaded_at'].toString()) ?? DateTime.now())
          : (json['created_at'] != null
              ? (DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now())
              : DateTime.now()),
    );
  }

  ProgressType get progressType {
    final t = imageType.toLowerCase().trim();
    if (t.contains('back') || t.contains('rear')) {
      return ProgressType.back;
    } else if (t.contains('side') || t.contains('lateral') || t.contains('left') || t.contains('right')) {
      return ProgressType.side;
    } else {
      return ProgressType.front;
    }
  }
}

class ComparisonPhoto {
  final int id;
  final String image;
  final String imageType;
  final String date;
  final DateTime uploadedAt;
  final bool aiDetected;
  final String? aiSummary;

  ComparisonPhoto({
    required this.id,
    required this.image,
    required this.imageType,
    required this.date,
    required this.uploadedAt,
    required this.aiDetected,
    this.aiSummary,
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

  factory ComparisonPhoto.fromJson(Map<String, dynamic> json) {
    return ComparisonPhoto(
      id: (json['id'] as num?)?.toInt() ?? 0,
      image: _formatImageUrl(json['image'] ?? json['image_url'] ?? json['photo']),
      imageType: (json['image_type'] ?? json['progress_type'] ?? json['type'] ?? json['pose'] ?? json['photo_type'])?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      uploadedAt: json['uploaded_at'] != null
          ? (DateTime.tryParse(json['uploaded_at'].toString()) ?? DateTime.now())
          : (json['created_at'] != null
              ? (DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now())
              : DateTime.now()),
      aiDetected: json['ai_detected'] == true || json['is_ai_detected'] == true,
      aiSummary: (json['ai_summary'] ?? json['summary'])?.toString(),
    );
  }
}

class TypeComparison {
  final ComparisonPhoto? first;
  final ComparisonPhoto? last;

  TypeComparison({this.first, this.last});

  factory TypeComparison.fromJson(Map<String, dynamic> json) {
    return TypeComparison(
      first: json['first'] != null && json['first'] is Map<String, dynamic>
          ? ComparisonPhoto.fromJson(json['first'] as Map<String, dynamic>)
          : null,
      last: json['last'] != null && json['last'] is Map<String, dynamic>
          ? ComparisonPhoto.fromJson(json['last'] as Map<String, dynamic>)
          : null,
    );
  }

  bool get hasAny => first != null || last != null;
  bool get hasBoth => first != null && last != null;
}

class GalleryComparisonResponse {
  final TypeComparison? front;
  final TypeComparison? back;
  final TypeComparison? side;

  GalleryComparisonResponse({
    this.front,
    this.back,
    this.side,
  });

  factory GalleryComparisonResponse.fromJson(Map<String, dynamic> json) {
    return GalleryComparisonResponse(
      front: json['front'] != null && json['front'] is Map<String, dynamic>
          ? TypeComparison.fromJson(json['front'] as Map<String, dynamic>)
          : null,
      back: json['back'] != null && json['back'] is Map<String, dynamic>
          ? TypeComparison.fromJson(json['back'] as Map<String, dynamic>)
          : null,
      side: json['side'] != null && json['side'] is Map<String, dynamic>
          ? TypeComparison.fromJson(json['side'] as Map<String, dynamic>)
          : null,
    );
  }

  TypeComparison? getForType(String type) {
    switch (type.toLowerCase()) {
      case 'front':
        return front;
      case 'back':
        return back;
      case 'side':
        return side;
      default:
        return front;
    }
  }
}

