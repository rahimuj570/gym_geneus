// model/profile_model.dart

import 'package:kenzeno/app/constants/appconstants.dart';

class ProfileModel {
  String? id;
  String? email;
  String? phoneNumber;
  String? avatar; // "/media/avatars/profile.jpg"
  String? fullName; // new field from API
  String? gender;
  int? age;
  String? dateOfBirth;
  double? heightCm;
  double? weightKg;
  String? goal;
  String? activityLevel;
  int? coachType;
  String? preferredWorkoutTime;
  List<WorkoutDay>? preferredWorkoutDays;
  Rank? rank; // new nested rank object
  String? joinedAt;
  List<String>? missingProfileFields;

  ProfileModel({
    this.id,
    this.email,
    this.phoneNumber,
    this.avatar,
    this.fullName,
    this.gender,
    this.age,
    this.dateOfBirth,
    this.heightCm,
    this.weightKg,
    this.goal,
    this.activityLevel,
    this.coachType,
    this.preferredWorkoutTime,
    this.preferredWorkoutDays,
    this.rank,
    this.joinedAt,
    this.missingProfileFields,
  });

  bool get hasMissingProfileFields =>
      missingProfileFields != null && missingProfileFields!.isNotEmpty;

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as String?,
      email: json['email'] as String?,
      phoneNumber: json['phone_number'] as String?,
      avatar: _getFullImageUrl(json['avatar'] as String?), // Fixed here
      fullName: json['full_name'] as String?,
      gender: json['gender'] as String?,
      age: json['age'] is int
          ? json['age'] as int?
          : int.tryParse(json['age'].toString()),
      dateOfBirth: json['date_of_birth'] as String?,
      heightCm: _parseDouble(json['height_cm']),
      weightKg: _parseDouble(json['weight_kg']),
      goal: json['goal'] as String?,
      activityLevel: json['activity_level'] as String?,
      coachType: json['coach_type'] is int
          ? json['coach_type'] as int?
          : int.tryParse(json['coach_type'].toString()),
      preferredWorkoutTime: json['preferred_workout_time'] as String?,
      preferredWorkoutDays: json['preferred_workout_days'] == null
          ? null
          : (json['preferred_workout_days'] as List)
                .map((e) => WorkoutDay.fromJson(e as Map<String, dynamic>))
                .toList(),
      rank: json['rank'] == null
          ? null
          : Rank.fromJson(json['rank'] as Map<String, dynamic>),
      joinedAt: json['joined_at'] as String?,
      missingProfileFields: json['missing_profile_fields'] == null
          ? null
          : (json['missing_profile_fields'] is List
              ? (json['missing_profile_fields'] as List)
                  .map((e) => e.toString())
                  .toList()
              : null),
    );
  }

  // Add this static helper at the bottom of profile_model.dart
  static String _getFullImageUrl(String? path) {
    if (path == null || path.isEmpty || path == 'null') {
      return '';
    }

    if (path.startsWith('http')) return path;

    const String baseUrl = AppConstants.baseUrimage;

    return '$baseUrl$path';
  }

  // If you ever need to send updates back to the backend
  Map<String, dynamic> toJson() {
    return {
      if (fullName != null && fullName!.isNotEmpty) 'full_name': fullName,
      if (phoneNumber != null && phoneNumber!.isNotEmpty)
        'phone_number': phoneNumber,
      if (dateOfBirth != null && dateOfBirth!.isNotEmpty)
        'date_of_birth': dateOfBirth,
      if (gender != null) 'gender': gender,
      if (heightCm != null) 'height_cm': heightCm,
      if (weightKg != null) 'weight_kg': weightKg,
      if (goal != null) 'goal': goal,
      if (activityLevel != null) 'activity_level': activityLevel,
      if (coachType != null) 'coach_type': coachType,
      if (preferredWorkoutTime != null)
        'preferred_workout_time': preferredWorkoutTime,
      if (avatar != null && avatar!.isNotEmpty) 'avatar': avatar,
      // preferred_workout_days & rank are usually not editable here
    };
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString());
  }
}

// Rank model
class Rank {
  final int id;
  final String name; // e.g. "BRONZE"
  final int level;
  final String colorCode; // e.g. "#CD7F32"

  Rank({
    required this.id,
    required this.name,
    required this.level,
    required this.colorCode,
  });

  factory Rank.fromJson(Map<String, dynamic> json) {
    return Rank(
      id: json['id'] as int,
      name: json['name'] as String,
      level: json['level'] as int,
      colorCode: json['color_code'] as String,
    );
  }
}

// WorkoutDay stays the same
class WorkoutDay {
  final int id;
  final String name;

  WorkoutDay({required this.id, required this.name});

  factory WorkoutDay.fromJson(Map<String, dynamic> json) {
    return WorkoutDay(id: json['id'] as int, name: json['name'] as String);
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}
