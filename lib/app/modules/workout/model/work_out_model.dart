import 'package:get/get.dart';

class ExerciseStep {
  final String name;
  final String duration;
  final String repetitions;

  ExerciseStep({
    required this.name,
    required this.duration,
    required this.repetitions,
  });
}

class WorkoutData {
  final String title;
  final String duration;
  final String calories;
  final String exercises;
  final String imagePath;
  final bool isVideo;
  final Map<String, List<ExerciseStep>> steps; // Rounds and Steps

  WorkoutData({
    required this.title,
    required this.duration,
    required this.calories,
    required this.exercises,
    required this.imagePath,
    this.isVideo = false,
    required this.steps,
  });
}

class WorkoutSection {
  final String title;
  final String subtitle;
  final List<WorkoutData> cards;

  WorkoutSection({
    required this.title,
    required this.subtitle,
    required this.cards,
  });
}

// --- Placeholder Exercise Data ---
final Map<String, List<ExerciseStep>> beginnerWorkoutSteps = {
  'Round 1': [
    ExerciseStep(name: 'Dumbbell Rows', duration: '00:30', repetitions: '3x'),
    ExerciseStep(name: 'Russian Twists', duration: '00:15', repetitions: '2x'),
    ExerciseStep(name: 'Squats', duration: '00:30', repetitions: '3x'),
  ],
  'Round 2': [
    ExerciseStep(
      name: 'Tabata Intervals',
      duration: '00:10',
      repetitions: '2x',
    ),
    ExerciseStep(
      name: 'Bicycle Crunches',
      duration: '00:10',
      repetitions: '4x',
    ),
  ],
};
