// meal_selection_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:kenzeno/app/modules/nutrition/controllers/mealplancontroller.dart';
import '../../../res/colors/colors.dart';
import '../../setting/widgets/trainnigstep.dart'; // The provided card widget

class MealSelectionCard extends StatelessWidget {
  final int index;
  final String title;
  final String duration;
  final String calories;
  final String imagePath;
  final MealPlanController controller;

  const MealSelectionCard({
    super.key,
    required this.index,
    required this.title,
    required this.duration,
    required this.calories,
    required this.imagePath,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    // Obx reacts to changes in selectedMealIndex in the controller
    return Obx(() {
      final isSelected = controller.selectedMealIndex.value == index;

      return GestureDetector(
        onTap: () => controller.selectMeal(index),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 1. Radio Button (Custom design)
            Padding(
              padding: EdgeInsets.only(left: 20.w, right: 10.w),
              child: Container(
                width: 24.r,
                height: 24.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? AppColor.customPurple
                        : AppColor.gray9CA3AF,
                    width: isSelected ? 3.w : 2.w,
                  ),
                ),
                child: isSelected
                    ? Center(
                        child: Container(
                          width: 12.r,
                          height: 12.r,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColor.customPurple,
                          ),
                        ),
                      )
                    : null,
              ),
            ),
            // 2. Meal Card (TrainingCardWidget without outer padding)
            Expanded(
              child: TrainingCardWidget(
                title: title,
                // Using calories as subtitle
                subtitle: calories,
                imagePath: imagePath,
                type: 'article', // Forces subtitle/info row layout for meals
                isVideo: false,
                duration: duration,
                calories: calories,
                exercises: '',
                // Ensure the card's internal padding is removed by setting onTap to null
                onTap: () {},
              ),
            ),
          ],
        ),
      );
    });
  }
}
