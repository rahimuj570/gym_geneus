// redesigned_scanned_meal_page.dart
import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:kenzeno/app/modules/home/views/navbar.dart';
import 'package:kenzeno/app/modules/nutrition/controllers/nutri_controller.dart';
import '../../../res/assets/asset.dart';
import '../../../res/colors/colors.dart';
import '../../../res/fonts/textstyle.dart';
import '../../../widgets/backbutton_widget.dart';
import '../../../widgets/custom_button.dart';
import '../model/meal_result_analysis.dart';

extension StringCasing on String {
  String toTitleCase() => split(' ')
      .map(
        (word) => word.isNotEmpty
            ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
            : '',
      )
      .join(' ');
}

/// Full page: polished Dark Glass + Gradient UI
class RedesignedScannedMealPage extends StatelessWidget {
  final File imageFile;
  final MealAnalysisResult analysisResult;
  NutritionController get controller => Get.isRegistered<NutritionController>()
      ? Get.find<NutritionController>()
      : Get.put(NutritionController());

  RedesignedScannedMealPage({
    super.key,
    required this.imageFile,
    required this.analysisResult,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.black111214,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButtonBox(),
        title: Text(
          'Meal Analysis',
          style: AppTextStyles.poppinsBold.copyWith(
            color: Colors.white,
            fontSize: 20.sp,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMealHeader(),
              SizedBox(height: 18.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCalorieMacroSummary(),
                    SizedBox(height: 20.h),
                    _buildHealthInsight(),
                    if (analysisResult.micronutrients.isNotEmpty) ...[
                      SizedBox(height: 20.h),
                      _buildMicronutrientsSection(),
                    ],
                    if (analysisResult.improvementSuggestion.isNotEmpty) ...[
                      SizedBox(height: 20.h),
                      _buildImprovementSuggestion(),
                    ],
                    SizedBox(height: 36.h),
                    Obx(
                      () => CustomButton(
                        onPress: () async {
                          await controller.saveCurrentMeal();
                          Get.offAll(
                            Navbar(),
                            transition: Transition.rightToLeft,
                          );
                        },
                        title: "Save",
                        loading: controller.isSaving.value,
                        fontSize: 18.sp,
                        height: 45.h,
                        fontFamily: 'WorkSans',
                        radius: 20.r,
                        fontWeight: FontWeight.w700,
                        textColor: AppColor.white,
                        borderColor: AppColor.customPurple,
                        buttonColor: AppColor.customPurple,
                      ),
                    ),
                    SizedBox(height: 36.h),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMealHeader() {
    return Stack(
      children: [
        // Hero image with beautiful rounded bottom + subtle overlay
        ClipRRect(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30.r)),
          child: SizedBox(
            height: 320.h,
            width: double.infinity,
            child: Stack(
              children: [
                Image.file(
                  imageFile,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
                // soft radial glow to lift subject
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment(-0.2, -0.6),
                        radius: 1.2,
                        colors: [Colors.transparent, Colors.black26],
                      ),
                    ),
                  ),
                ),
                // bottom fade for text readability
                Positioned.fill(
                  child: ShaderMask(
                    shaderCallback: (rect) => const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black87],
                      stops: [0.55, 1.0],
                    ).createShader(rect),
                    blendMode: BlendMode.darken,
                    child: Container(color: Colors.transparent),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Title + subtitle
        Positioned(
          bottom: 24.h,
          left: 20.w,
          right: 20.w,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                analysisResult.mealName.isNotEmpty
                    ? analysisResult.mealName
                    : 'Detected Meal',
                style: AppTextStyles.poppinsBold.copyWith(
                  color: Colors.white,
                  fontSize: 30.sp,
                  height: 1.05,
                  shadows: [
                    Shadow(
                      blurRadius: 18,
                      color: Colors.black.withOpacity(0.7),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 6.h),
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white12,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Text(
                      '1 serving',
                      style: AppTextStyles.poppinsMedium.copyWith(
                        color: Colors.white70,
                        fontSize: 13.sp,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    '• AI Detected',
                    style: AppTextStyles.poppinsMedium.copyWith(
                      color: Colors.white70,
                      fontSize: 13.sp,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCalorieMacroSummary() {
    final protein = (analysisResult.macronutrients['protein'] ?? 0).toDouble();
    final fat = (analysisResult.macronutrients['fat'] ?? 0).toDouble();
    final carbs = (analysisResult.macronutrients['carbs'] ?? 0).toDouble();
    final total = (protein + fat + carbs) > 0 ? protein + fat + carbs : 1.0;

    final proteinFraction = (protein / total).clamp(0.0, 1.0);
    final fatFraction = (fat / total).clamp(0.0, 1.0);
    final carbsFraction = (carbs / total).clamp(0.0, 1.0);

    return Container(
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF7F00FF).withOpacity(0.85), // Neon Purple
            Color(0xFFE100FF).withOpacity(0.75), // Electric Pink
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.35),
            blurRadius: 22,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Nutritional Breakdown',
                  style: AppTextStyles.poppinsSemiBold.copyWith(
                    color: Colors.white.withOpacity(0.95),
                    fontSize: 16.sp,
                  ),
                ),
              ),
              Icon(Icons.fitness_center, color: Colors.white70, size: 20.sp),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              // Macro Wheel
              Expanded(
                flex: 4,
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        height: 150.h,
                        width: 150.h,
                        child: CustomPaint(
                          painter: _MacroWheelPainter(
                            proteinFraction: proteinFraction,
                            fatFraction: fatFraction,
                            carbsFraction: carbsFraction,
                            proteinColor: Color(0xFF00FFA3), // Neon Teal
                            fatColor: Color(0xFFFF3C3C), // Neon Red
                            carbsColor: Color(0xFFFFB800), // Neon Orange
                          ),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${analysisResult.estimatedCalories.toInt()}',
                            style: AppTextStyles.poppinsBold.copyWith(
                              color: Colors.white,
                              fontSize: 36.sp,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'kCal',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13.sp,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(width: 12.w),

              // Macro Pills
              Expanded(
                flex: 6,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _macroNeonRow(
                      'Protein',
                      '${protein.toInt()}g',
                      Color(0xFF00FFA3),
                    ),
                    SizedBox(height: 10.h),
                    _macroNeonRow('Fat', '${fat.toInt()}g', Color(0xFFFF3C3C)),
                    SizedBox(height: 10.h),
                    _macroNeonRow(
                      'Carbs',
                      '${carbs.toInt()}g',
                      Color(0xFFFFB800),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _macroNeonRow(String title, String value, Color color) {
    return Row(
      children: [
        Container(
          width: 36.w,
          height: 36.h,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [color.withOpacity(0.95), color.withOpacity(0.55)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.35),
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            value.replaceAll(RegExp(r'[^0-9]'), ''),
            style: AppTextStyles.poppinsBold.copyWith(
              color: Colors.white,
              fontSize: 12.sp,
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTextStyles.poppinsSemiBold.copyWith(
                color: Colors.white,
                fontSize: 14.sp,
              ),
            ),
            Text(
              value,
              style: TextStyle(color: Colors.white70, fontSize: 13.sp),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHealthInsight() {
    return _infoCard(
      icon: Icons.health_and_safety_outlined,
      title: 'Health Insight',
      color: AppColor.customPurple,
      child: Text(
        analysisResult.overallHealthInsight.isNotEmpty
            ? analysisResult.overallHealthInsight
            : 'No health insights available.',
        style: TextStyle(
          color: AppColor.gray9CA3AF,
          fontSize: 15.sp,
          height: 1.6,
        ),
      ),
    );
  }

  Widget _buildMicronutrientsSection() {
    final entries = analysisResult.micronutrients.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Key Micronutrients',
          style: AppTextStyles.poppinsSemiBold.copyWith(
            color: Colors.white,
            fontSize: 18.sp,
          ),
        ),
        SizedBox(height: 12.h),

        Wrap(
          spacing: 12.w,
          runSpacing: 12.h,
          children: entries.take(10).map((e) {
            final key = e.key;
            final name = key.replaceAll('_', ' ').toTitleCase();
            final icon = _getMicroIcon(key);
            final unit = _getUnit(key);
            final value = (e.value ?? 0).toDouble();
            final accent = _getAccentForNutrient(key);

            return _nutrientGradientCard(
              name: name,
              icon: icon,
              value: value,
              unit: unit,
              accent: accent,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _nutrientGradientCard({
    required String name,
    required IconData icon,
    required double value,
    required String unit,
    required Color accent,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accent.withOpacity(0.22),
            accent.withOpacity(0.10),
            accent.withOpacity(0.05),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: accent.withOpacity(0.25),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // icon container
          Container(
            width: 34.w,
            height: 34.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accent.withOpacity(0.25),
            ),
            child: Icon(icon, color: Colors.white, size: 18.sp),
          ),
          SizedBox(width: 10.w),

          // labels
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 3.h),
              Text(
                '${value.toStringAsFixed(1)} $unit',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.82),
                  fontSize: 12.sp,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImprovementSuggestion() {
    return _infoCard(
      icon: Icons.lightbulb_outline,
      title: 'Pro Tip',
      color: AppColor.green22C55E,
      child: Text(
        analysisResult.improvementSuggestion,
        style: TextStyle(color: Colors.white, fontSize: 15.sp, height: 1.5),
      ),
    );
  }

  Widget _infoCard({
    required IconData icon,
    required String title,
    required Color color,
    double backgroundOpacity = 0.12,
    double borderOpacity = 0.35,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(backgroundOpacity),
            color.withOpacity(backgroundOpacity * 0.5),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: color.withOpacity(borderOpacity)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.22),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.22),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(icon, color: color, size: 20.sp),
              ),
              SizedBox(width: 12.w),
              Text(
                title,
                style: AppTextStyles.poppinsSemiBold.copyWith(
                  color: color,
                  fontSize: 15.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          child,
        ],
      ),
    );
  }

  String _getUnit(String key) {
    final map = {
      'vitamin_c': 'mg',
      'vitamin_d': 'IU',
      'iron': 'mg',
      'calcium': 'mg',
      'potassium': 'mg',
      'fiber': 'g',
      'magnesium': 'mg',
      'zinc': 'mg',
      'sodium': 'mg',
    };
    return map[key.toLowerCase()] ?? 'mg';
  }

  IconData _getMicroIcon(String key) {
    switch (key.toLowerCase()) {
      case 'vitamin_c':
      case 'vitaminc':
        return Icons.local_florist;
      case 'vitamin_d':
      case 'vitamind':
        return Icons.wb_sunny;
      case 'iron':
        return Icons.bloodtype;
      case 'calcium':
        return Icons
            .medical_services; // use medication or custom svg for better Ca
      case 'fiber':
        return Icons.eco;
      case 'potassium':
        return Icons.bolt;
      case 'magnesium':
        return Icons.auto_awesome;
      case 'zinc':
        return Icons.shield;
      case 'sodium':
        return Icons.opacity;
      default:
        return Icons.star_border;
    }
  }

  Color _getAccentForNutrient(String key) {
    switch (key.toLowerCase()) {
      case 'vitamin_c':
      case 'vitaminc':
        return AppColor.orangeF97316;
      case 'vitamin_d':
      case 'vitamind':
        return AppColor.vividAmber;
      case 'iron':
        return AppColor.redDC2626;
      case 'calcium':
        return AppColor.teal10B981;
      case 'fiber':
        return AppColor.green22C55E;
      case 'potassium':
        return AppColor.deepPurple673AB7;
      case 'magnesium':
        return AppColor.customPurple;
      default:
        return AppColor.customPurple;
    }
  }
}

/// Custom painter draws three arcs for protein/fat/carbs
class _MacroWheelPainter extends CustomPainter {
  final double proteinFraction;
  final double fatFraction;
  final double carbsFraction;
  final Color proteinColor;
  final Color fatColor;
  final Color carbsColor;

  _MacroWheelPainter({
    required this.proteinFraction,
    required this.fatFraction,
    required this.carbsFraction,
    required this.proteinColor,
    required this.fatColor,
    required this.carbsColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final thickness = size.width * 0.12;
    final rect = Rect.fromCircle(
      center: center,
      radius: size.width / 2 - thickness / 2,
    );
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = thickness;

    double start = -pi / 2;

    // draw protein
    paint.color = proteinColor;
    final sweepProtein = 2 * pi * proteinFraction;
    canvas.drawArc(rect, start, sweepProtein, false, paint);
    start += sweepProtein;

    // draw fat
    paint.color = fatColor;
    final sweepFat = 2 * pi * fatFraction;
    canvas.drawArc(rect, start, sweepFat, false, paint);
    start += sweepFat;

    // draw carbs
    paint.color = carbsColor;
    final sweepCarbs = 2 * pi * carbsFraction;
    canvas.drawArc(rect, start, sweepCarbs, false, paint);
  }

  @override
  bool shouldRepaint(covariant _MacroWheelPainter oldDelegate) {
    return oldDelegate.proteinFraction != proteinFraction ||
        oldDelegate.fatFraction != fatFraction ||
        oldDelegate.carbsFraction != carbsFraction;
  }
}
