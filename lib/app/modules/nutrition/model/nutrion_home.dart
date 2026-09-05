// nutrition_home_response.dart

class NutritionHomeResponse {
  final String message;
  final int totalMeals;
  final int streak;
  final int caloriesTarget;
  final int caloriesGain;
  final List<TodayMeal> todaysMeals;
  final List<NutrientBreakdown> nutritionBreakdown;

  NutritionHomeResponse({
    required this.message,
    required this.totalMeals,
    required this.streak,
    required this.caloriesTarget,
    required this.caloriesGain,
    required this.todaysMeals,
    required this.nutritionBreakdown,
  });

  factory NutritionHomeResponse.fromJson(Map<String, dynamic> json) {
    return NutritionHomeResponse(
      message: json['message'] ?? 'Welcome!',
      totalMeals: (json['total_meals'] as num?)?.toInt() ?? 0,
      streak: (json['streak'] as num?)?.toInt() ?? 0,
      caloriesTarget: (json['calories_target'] as num?)?.toInt() ?? 0,
      caloriesGain: (json['calories_gain'] as num?)?.toInt() ?? 0,
      todaysMeals:
          (json['todays_meals'] as List<dynamic>?)
              ?.map((e) => TodayMeal.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      nutritionBreakdown:
          ((json['nutrition_brackdown'] ?? json['nutrition_breakdown'])
                  as List<dynamic>?)
              ?.map(
                (e) => NutrientBreakdown.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }
}

class TodayMeal {
  final int id;
  final String mealName;
  final int estimatedCalories;
  final String imageUrl;
  final String aiAnalysis;
  final String improvements;
  final DateTime createdAt;

  TodayMeal({
    required this.id,
    required this.mealName,
    required this.estimatedCalories,
    required this.imageUrl,
    required this.aiAnalysis,
    required this.improvements,
    required this.createdAt,
  });

  factory TodayMeal.fromJson(Map<String, dynamic> json) {
    return TodayMeal(
      id: (json['id'] as num?)?.toInt() ?? 0,
      mealName: json['meal_name'] ?? 'Meal',
      estimatedCalories: (json['estimated_calories'] as num?)?.toInt() ?? 0,
      imageUrl: json['image'] ?? '',
      aiAnalysis: json['ai_analysis'] ?? 'Analysis unavailable',
      improvements: json['improvements'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at']) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

class NutrientBreakdown {
  final String name;
  final int amount;
  final String unit;

  NutrientBreakdown({
    required this.name,
    required this.amount,
    required this.unit,
  });

  factory NutrientBreakdown.fromJson(Map<String, dynamic> json) {
    return NutrientBreakdown(
      name: json['name'] ?? '',
      amount: (json['amount'] as num?)?.toInt() ?? 0,
      unit: json['unit'] ?? '',
    );
  }
}
