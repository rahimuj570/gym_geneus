// lib/app/data/models/favorite_models.dart

import '../../../res/assets/asset.dart';

class FavoriteItem {
  final int id;
  final String type; // "article" or "userworkout"
  final FavoriteObject object;
  final DateTime createdAt;

  FavoriteItem({
    required this.id,
    required this.type,
    required this.object,
    required this.createdAt,
  });

  factory FavoriteItem.fromJson(Map<String, dynamic> json) {
    return FavoriteItem(
      id: json['id'],
      type: json['type'],
      object: FavoriteObject.fromJson(json['object']),
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class FavoriteObject {
  // Common fields
  final int id;
  final String title;

  // Article only
  final String? content;
  final String? image; // can be null
  final String? category;

  // Workout only
  final String? name;
  final String? description;
  final String? imagePath; // e.g. "/media/workout_images/..."
  final String? estimatedDuration;
  final String? estimatedCalories;
  final int? exerciseCount;
  final String? difficulty;

  FavoriteObject({
    required this.id,
    required this.title,
    this.content,
    this.image,
    this.category,
    this.name,
    this.description,
    this.imagePath,
    this.estimatedDuration,
    this.estimatedCalories,
    this.exerciseCount,
    this.difficulty,
  });

  factory FavoriteObject.fromJson(Map<String, dynamic> json) {
    return FavoriteObject(
      id: json['id'],
      title: json['title'] ?? json['name'] ?? 'Untitled',
      content: json['content'],
      image: json['image'],
      category: json['category'],
      name: json['name'],
      description: json['description'],
      imagePath: json['image'],
      estimatedDuration: json['estimated_duration'],
      estimatedCalories: json['estimated_calories'],
      exerciseCount: json['exercise_count'],
      difficulty: json['difficulty'],
    );
  }

  bool get isArticle => content != null;
  String get displayImage => imagePath ?? ImageAssets.img_16; // fallback
}
