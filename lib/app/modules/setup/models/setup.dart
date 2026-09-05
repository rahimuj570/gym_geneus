class UserCreateModel {
  final String email;
  final String phoneNumber;
  final String avatar;
  final String firstName;
  final String lastName;
  final String gender;
  final int age;
  final String dateOfBirth;
  final int heightCm;
  final int weightKg;
  final String goal;
  final String activityLevel;
  final int coachType;
  final String preferredWorkoutTime;
  final List<int> preferredWorkoutDayIds;

  UserCreateModel({
    required this.email,
    required this.phoneNumber,
    required this.avatar,
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.age,
    required this.dateOfBirth,
    required this.heightCm,
    required this.weightKg,
    required this.goal,
    required this.activityLevel,
    required this.coachType,
    required this.preferredWorkoutTime,
    required this.preferredWorkoutDayIds,
  });

  factory UserCreateModel.fromJson(Map<String, dynamic> json) {
    return UserCreateModel(
      email: json['email'],
      phoneNumber: json['phone_number'],
      avatar: json['avatar'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      gender: json['gender'],
      age: json['age'],
      dateOfBirth: json['date_of_birth'],
      heightCm: json['height_cm'],
      weightKg: json['weight_kg'],
      goal: json['goal'],
      activityLevel: json['activity_level'],
      coachType: json['coach_type'],
      preferredWorkoutTime: json['preferred_workout_time'],
      preferredWorkoutDayIds: List<int>.from(json['preferred_workout_day_ids']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "email": email,
      "phone_number": phoneNumber,
      "avatar": avatar,
      "first_name": firstName,
      "last_name": lastName,
      "gender": gender,
      "age": age,
      "date_of_birth": dateOfBirth,
      "height_cm": heightCm,
      "weight_kg": weightKg,
      "goal": goal,
      "activity_level": activityLevel,
      "coach_type": coachType,
      "preferred_workout_time": preferredWorkoutTime,
      "preferred_workout_day_ids": preferredWorkoutDayIds,
    };
  }
}
