// mealplancontroller.dart

import 'package:get/get.dart';

// NOTE: Ensure your asset paths match your project structure
import '../../../res/assets/asset.dart';

class MealPlanController extends GetxController {
  // Step One selections
  var selectedPreferences = <String>{}.obs;
  var selectedAllergies = <String>{}.obs;
  var selectedMealTypes = <String>{}.obs;

  // Step Two selections
  var selectedCaloricGoal = <String>{}.obs;
  var selectedCookingTime = <String>{}.obs;
  var selectedServings = <String>{}.obs;

  // Step One toggles
  void togglePreference(String option) {
    selectedPreferences.contains(option)
        ? selectedPreferences.remove(option)
        : selectedPreferences.add(option);
  }

  void toggleAllergy(String option) {
    selectedAllergies.contains(option)
        ? selectedAllergies.remove(option)
        : selectedAllergies.add(option);
  }

  void toggleMealType(String option) {
    selectedMealTypes.contains(option)
        ? selectedMealTypes.remove(option)
        : selectedMealTypes.add(option);
  }

  // Step Two toggles
  void toggleCaloricGoal(String option) {
    selectedCaloricGoal.contains(option)
        ? selectedCaloricGoal.remove(option)
        : selectedCaloricGoal.add(option);
  }

  void toggleCookingTime(String option) {
    selectedCookingTime.contains(option)
        ? selectedCookingTime.remove(option)
        : selectedCookingTime.add(option);
  }

  void toggleServings(String option) {
    selectedServings.contains(option)
        ? selectedServings.remove(option)
        : selectedServings.add(option);
  }

  // =======================================================
  // MEAL SELECTION LOGIC
  // =======================================================

  RxInt selectedMealIndex = (-1).obs;

  // Dummy Data for Meal Plans (Updated imagePaths for realism)
  final List<Map<String, String>> mealPlans = [
    {
      'title': 'Delights With Greek Yogurt',
      'duration': '6 Minutes',
      'calories': '200 Cal',
      'imagePath': ImageAssets.img_26,
    },
    {
      'title': 'Spinach And Tomato Omelette',
      'duration': '10 Minutes',
      'calories': '220 Cal',
      'imagePath': ImageAssets.img_26,
    },
    {
      'title': 'Avocado And Egg Toast',
      'duration': '15 Minutes',
      'calories': '150 Cal',
      'imagePath': ImageAssets.img_26,
    },
    {
      'title': 'Protein Shake With Fruits',
      'duration': '9 Minutes',
      'calories': '180 Cal',
      'imagePath': ImageAssets.img_26,
    },
  ];

  void selectMeal(int index) {
    selectedMealIndex.value = index;
  }

  /**
   * Retrieves the full meal details for the selected meal,
   * including ingredients and preparation text required by MealDetailPage.
   */
  Map<String, dynamic> getSelectedMealDetails() {
    if (selectedMealIndex.value == -1) return {};

    final selectedMeal = mealPlans[selectedMealIndex.value];

    // Logic to return specific detailed content based on the title (or meal ID in a real app)
    final Map<String, dynamic> detailContent;

    if (selectedMeal['title'] == 'Avocado And Egg Toast') {
      detailContent = {
        'ingredients': [
          'Wholemeal bread',
          'Ripe avocado slices',
          'Fried or poached egg',
        ],
        'preparation':
            'Sed earum sequi est magnam doloremque aut porro dolores sit molestiae fuga. Et rerum inventore ut perspiciatis dolorum sed internos porro aut labore dolorem At quia reiciendis in consequuntur possimus.',
        'tag': 'Meal Plan Item',
      };
    } else if (selectedMeal['title'] == 'Spinach And Tomato Omelette') {
      detailContent = {
        'ingredients': [
          '2-3 eggs',
          'A handful of fresh spinach',
          '1 small tomato',
          'Salt and pepper to taste',
          'Olive oil or butter',
        ],
        'preparation':
            'Whisk eggs with salt and pepper. Sauté spinach and tomato lightly. Pour eggs over vegetables and cook until set. Fold and serve.',
        'tag': 'Protein Packed',
      };
    } else {
      // Default content for other meals
      detailContent = {
        'ingredients': ['Base Ingredient', 'Flavoring Agent', 'Topping'],
        'preparation':
            'Mix all ingredients in a blender/bowl and serve immediately for a quick and nutritious meal.',
        'tag': 'Quick Recipe',
      };
    }

    // Combine summary data with detailed content
    return {...selectedMeal, ...detailContent};
  }
}
