// meal_result_analysis.dart
class MealAnalysisResult {
  final int tempUploadId;
  final String mealName;
  final double estimatedCalories;
  final String overallHealthInsight;
  final Map<String, double> macronutrients;
  final Map<String, double> micronutrients;
  final String improvementSuggestion;
  final String imagePath;

  MealAnalysisResult({
    required this.tempUploadId,
    required this.mealName,
    required this.estimatedCalories,
    required this.overallHealthInsight,
    required this.macronutrients,
    required this.micronutrients,
    required this.improvementSuggestion,
    required this.imagePath,
  });

  factory MealAnalysisResult.fromJson(Map<String, dynamic> json) {
    // Helper to safely convert anything to double
    double _toDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    // Parse macronutrients
    Map<String, double> macroMap = {};
    final macros = json['analysis_data']?['macronutrients'];
    if (macros is List) {
      for (var item in macros) {
        String name = (item['name'] ?? '').toString().toLowerCase();
        double amount = _toDouble(item['amount']);
        macroMap[name] = amount;
      }
    }

    // Parse micronutrients
    Map<String, double> microMap = {};
    final micros = json['analysis_data']?['micronutrients'];
    if (micros is List) {
      for (var item in micros) {
        String name = (item['name'] ?? '').toString().toLowerCase();
        double amount = _toDouble(item['amount']);
        microMap[name] = amount;
      }
    }

    return MealAnalysisResult(
      tempUploadId: json['temp_upload_id'] ?? 0,
      mealName:
          json['analysis_data']?['meal_name']?.toString() ?? 'Unknown Meal',
      estimatedCalories: _toDouble(
        json['analysis_data']?['estimated_calories'],
      ),
      overallHealthInsight:
          json['analysis_data']?['overall_health_insight']?.toString() ?? '',
      macronutrients: macroMap,
      micronutrients: microMap,
      improvementSuggestion:
          json['analysis_data']?['improvement_suggestion']?.toString() ?? '',
      imagePath: json['image_path']?.toString() ?? '',
    );
  }
}
