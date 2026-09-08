// lib/services/workout_service.dart
// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../constants/appconstants.dart';
import '../../../services/api_client.dart';
import '../model/workoutmodel.dart';

class WorkoutService extends GetxService {
  final box = GetStorage();

  /// Fetch all workouts with optional difficulty filter
  Future<List<Workout>> fetchWorkouts({String? difficulty}) async {
    final uri = Uri.parse("${AppConstants.baseUrl}/workouts/").replace(
      queryParameters: difficulty != null ? {'difficulty': difficulty} : null,
    );

    try {
      final response = await ApiClient.get(uri, tag: 'Workout-List');

      if (response.statusCode == 200) {
        final body = response.body.trim();
        if (body.startsWith('[') || body.startsWith('{')) {
          final List data = jsonDecode(utf8.decode(response.bodyBytes));
          return data.map((json) => Workout.fromJson(json)).toList();
        } else {
          throw Exception(
            "Server returned HTML instead of JSON (likely login page)",
          );
        }
      }
      // Handle common errors
      else if (response.statusCode == 401) {
        throw Exception(
          "Unauthorized: Token expired or invalid. Please login again.",
        );
      } else if (response.statusCode == 403) {
        throw Exception("Forbidden: You don't have access to workouts.");
      } else {
        final errorBody = response.body;
        if (errorBody.contains("html") || errorBody.contains("<body")) {
          throw Exception(
            "Received HTML page. Token likely invalid or missing.",
          );
        }
        throw Exception("HTTP ${response.statusCode}: ${response.body}");
      }
    } catch (e) {
      if (e is FormatException) {
        print("JSON PARSE ERROR! Response was not JSON: $e");
        throw Exception(
          "Invalid response from server (not JSON). Check your token!",
        );
      }
      rethrow;
    }
  }

  // Add this method to your existing WorkoutService
  Future<Workout> fetchWorkoutDetail(int workoutId) async {
    final url = Uri.parse("${AppConstants.baseUrl}/workouts/$workoutId/");

    final response = await ApiClient.get(url, tag: 'Workout-Detail');
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(
        utf8.decode(response.bodyBytes),
      );
      return Workout.fromJson(data);
    } else if (response.statusCode == 404) {
      throw Exception("Workout not found");
    } else {
      throw Exception("Failed to load workout details");
    }
  }

  Future<WorkoutProgressResponse?> getWorkoutProgress({
    required int userWorkoutId,
  }) async {
    final uri = Uri.parse("${AppConstants.baseUrl}/workouts/track-progress/").replace(
      queryParameters: {
        "user_workout_id": userWorkoutId.toString(),
      },
    );

    try {
      final response = await ApiClient.get(uri, tag: 'Workout-GetProgress');

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        if (data is Map<String, dynamic>) {
          return WorkoutProgressResponse.fromJson(data);
        }
        return null;
      } else if (response.statusCode == 404) {
        return null;
      } else if (response.statusCode == 401) {
        throw Exception("Unauthorized – Please login again");
      } else {
        return null;
      }
    } catch (e) {
      print("Error fetching workout progress: $e");
      return null;
    }
  }

  Future<WorkoutProgressResponse?> trackProgress({
    required int userWorkoutId,
    int? userExerciseId, // optional – if tracking a specific exercise
  }) async {
    final url = Uri.parse("${AppConstants.baseUrl}/workouts/track-progress/");

    final Map<String, dynamic> payload = {
      "user_workout_id": userWorkoutId,
      if (userExerciseId != null) "user_exercise_id": userExerciseId,
    };

    final response = await ApiClient.post(
      url,
      body: jsonEncode(payload),
      tag: 'Workout-TrackProgress',
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      if (data is Map<String, dynamic>) {
        return WorkoutProgressResponse.fromJson(data);
      }
      return null;
    } else if (response.statusCode == 401) {
      throw Exception("Unauthorized – Please login again");
    } else if (response.statusCode == 400) {
      final error = jsonDecode(response.body);
      throw Exception(error['detail'] ?? error['error'] ?? "Invalid request");
    } else {
      throw Exception("Failed to track progress: ${response.statusCode}");
    }
  }
}
