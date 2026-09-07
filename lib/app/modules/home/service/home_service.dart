import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_debug_logger/flutter_debug_logger.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:intl/intl.dart';
import 'package:kenzeno/app/modules/home/models/leaderboard_model.dart';

import '../../../constants/appconstants.dart';
import '../../workout/model/workoutmodel.dart';
import '../models/activity_model.dart';
import '../models/app_notification.dart';
import '../models/article.dart';
import '../models/challenge_model.dart';
import '../models/fittracker_model.dart';
import '../models/trackprogress.dart';
import '../models/workout_model.dart';

class HomeService extends GetxService {
  final box = GetStorage();

  /// Fetch all articles
  Future<List<Article>> fetchArticles() async {
    try {
      final token = box.read("loginToken");
      final url = Uri.parse("${AppConstants.baseUrl}/articles/");

      final headers = <String, String>{
        "Accept": "application/json",
      };
      if (token != null && token.toString().isNotEmpty) {
        headers["Authorization"] = "Bearer $token";
      }

      var response = await http.get(url, headers: headers);

      FlutterDebugLogger.printJsonResponse(
        url: url.toString(),
        method: Method.GET,
        tag: 'Home-Articles',
        statusCode: response.statusCode,
        responseBody: response.body,
      );

      // Fallback: If user-specific fetch failed (e.g. status code 400/403 due to missing DOB),
      // fetch general public articles without token
      if (response.statusCode != 200 && token != null) {
        response = await http.get(url, headers: {"Accept": "application/json"});
        FlutterDebugLogger.printJsonResponse(
          url: url.toString(),
          method: Method.GET,
          tag: 'Home-Articles (Public Fallback)',
          statusCode: response.statusCode,
          responseBody: response.body,
        );
      }

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((json) => Article.fromJson(json)).toList();
      }
    } catch (e) {
      print("Error fetching articles: $e");
    }
    return [];
  }

  /// NEW: Fetch single article by ID
  Future<Article> fetchArticleById(int id) async {
    final token = box.read("loginToken");
    final url = Uri.parse("${AppConstants.baseUrl}/articles/$id");

    final response = await http.get(
      url,
      headers: {"Authorization": "Bearer $token", "Accept": "application/json"},
    );

    FlutterDebugLogger.printJsonResponse(
      url: url.toString(),
      method: Method.GET,
      tag: 'Home-ArticleById',
      statusCode: response.statusCode,
      responseBody: response.body,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return Article.fromJson(data);
    } else if (response.statusCode == 404) {
      throw Exception("Article not found");
    } else {
      throw Exception("Failed to fetch article: ${response.statusCode}");
    }
  }

  Future<List<WorkoutVideo>> fetchWorkoutVideos() async {
    final token = box.read("loginToken");
    final url = Uri.parse("${AppConstants.baseUrl}/articles/workout-videos/");

    try {
      final response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      FlutterDebugLogger.printJsonResponse(
        url: url.toString(),
        method: Method.GET,
        tag: 'Home-WorkoutVideos',
        statusCode: response.statusCode,
        responseBody: response.body,
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((json) => WorkoutVideo.fromJson(json)).toList();
      } else {
        throw Exception(
          "Failed to load workout videos: ${response.statusCode}",
        );
      }
    } catch (e) {
      print("Error fetching workout videos: $e");
      rethrow;
    }
  }

  Future<List<AppNotification>> fetchNotifications({
    String? notificationType, // "reminder" or "system"
  }) async {
    final token = box.read("loginToken");
    if (token == null) throw Exception("Login required");

    final params = <String, String>{};
    if (notificationType != null && notificationType.isNotEmpty) {
      params['notification_type'] = notificationType;
    }

    final uri = Uri.parse(
      '${AppConstants.baseUrl}/utils/notifications/',
    ).replace(queryParameters: params);

    final response = await http.get(
      uri,
      headers: {"Authorization": "Bearer $token", "Accept": "application/json"},
    );

    FlutterDebugLogger.printJsonResponse(
      url: uri.toString(),
      method: Method.GET,
      tag: 'Home-Notifications',
      statusCode: response.statusCode,
      responseBody: response.body,
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(utf8.decode(response.bodyBytes));
      return data.map((json) => AppNotification.fromJson(json)).toList();
    } else {
      throw Exception("Failed to load notifications");
    }
  }

  Future<List<WorkoutActivity>> fetchTodayActivities() async {
    final token = box.read("loginToken");
    if (token == null) throw Exception("Login required");

    final url = '${AppConstants.baseUrl}/workouts/activities/';
    final response = await http.get(
      Uri.parse(url),
      headers: {"Authorization": "Bearer $token", "Accept": "application/json"},
    );

    FlutterDebugLogger.printJsonResponse(
      url: url,
      method: Method.GET,
      tag: 'Home-TodayActivities',
      statusCode: response.statusCode,
      responseBody: response.body,
    );

    if (response.statusCode == 200) {
      try {
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        final activities = data
            .map(
              (json) => WorkoutActivity.fromJson(json as Map<String, dynamic>),
            )
            .toList();

        // Sort newest first
        activities.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return activities;
      } catch (e) {
        print('Parsing Error: $e');
        throw Exception("Failed to parse activities: $e");
      }
    } else {
      throw Exception(
        "Failed to load activities – ${response.statusCode}: ${response.body}",
      );
    }
  }

  Future<List<Challenge>> fetchChallenges({
    required String challengeType, // "DAILY" or "WEEKLY"
    bool availableOnly = true,
  }) async {
    final token = box.read('loginToken');
    if (token == null) throw Exception('Login required');

    final queryParams = {
      'challenge_type': challengeType,
      if (availableOnly) 'available_only': 'true',
    };

    final uri = Uri.parse(
      '${AppConstants.baseUrl}/gamification/challenges/',
    ).replace(queryParameters: queryParams);

    final response = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    FlutterDebugLogger.printJsonResponse(
      url: uri.toString(),
      method: Method.GET,
      tag: 'Home-Challenges',
      statusCode: response.statusCode,
      responseBody: response.body,
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final List<dynamic> data = json['data'];
      return data.map((item) => Challenge.fromJson(item)).toList();
    } else {
      final error = jsonDecode(response.body);
      throw Exception(
        error['message'] ?? error['detail'] ?? 'Failed to load challenges',
      );
    }
  }

  /// Start Challenge: POST /api/gamification/challenges/start/
  /// Body: {"challenge_id": 3}
  Future<Map<String, dynamic>> startChallenge(int challengeId) async {
    final token = box.read('loginToken');
    if (token == null) throw Exception('Login required');

    final uri = Uri.parse(
      '${AppConstants.baseUrl}/gamification/challenges/start/',
    );
    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({'challenge_id': challengeId}),
    );

    FlutterDebugLogger.printJsonResponse(
      url: uri.toString(),
      method: Method.POST,
      tag: 'Gamification-StartChallenge',
      statusCode: response.statusCode,
      responseBody: response.body,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(utf8.decode(response.bodyBytes))
          as Map<String, dynamic>;
    } else {
      final error = jsonDecode(utf8.decode(response.bodyBytes));
      throw Exception(
        error['message'] ?? error['detail'] ?? 'Failed to start challenge',
      );
    }
  }

  /// Get Challenge Details & Progress: GET /api/gamification/challenges/{id}/
  Future<Challenge> fetchChallengeDetail(int challengeId) async {
    final token = box.read('loginToken');
    if (token == null) throw Exception('Login required');

    final uri = Uri.parse(
      '${AppConstants.baseUrl}/gamification/challenges/$challengeId/',
    );
    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    FlutterDebugLogger.printJsonResponse(
      url: uri.toString(),
      method: Method.GET,
      tag: 'Gamification-ChallengeDetail',
      statusCode: response.statusCode,
      responseBody: response.body,
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(utf8.decode(response.bodyBytes));
      final data = json['data'] as Map<String, dynamic>;
      return Challenge.fromJson(data);
    } else {
      final error = jsonDecode(utf8.decode(response.bodyBytes));
      throw Exception(
        error['message'] ??
            error['detail'] ??
            'Failed to load challenge details',
      );
    }
  }

  /// Complete Exercise in Challenge: POST /api/gamification/challenges/complete-exercise/
  /// Body: {"challenge_id": 3, "exercise_index": 1}
  Future<Map<String, dynamic>> completeChallengeExercise({
    required int challengeId,
    required int exerciseIndex,
  }) async {
    final token = box.read('loginToken');
    if (token == null) throw Exception('Login required');

    final uri = Uri.parse(
      '${AppConstants.baseUrl}/gamification/challenges/complete-exercise/',
    );
    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'challenge_id': challengeId,
        'exercise_index': exerciseIndex,
      }),
    );

    FlutterDebugLogger.printJsonResponse(
      url: uri.toString(),
      method: Method.POST,
      tag: 'Gamification-CompleteExercise',
      statusCode: response.statusCode,
      responseBody: response.body,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(utf8.decode(response.bodyBytes))
          as Map<String, dynamic>;
    } else {
      final error = jsonDecode(utf8.decode(response.bodyBytes));
      throw Exception(
        error['message'] ?? error['detail'] ?? 'Failed to complete exercise',
      );
    }
  }

  /// Claim Reward: POST /api/gamification/challenges/claim-reward/
  /// Body: {"challenge_progress_id": 0}
  Future<Map<String, dynamic>> claimChallengeReward(
    int challengeProgressId,
  ) async {
    final token = box.read('loginToken');
    if (token == null) throw Exception('Login required');

    final uri = Uri.parse(
      '${AppConstants.baseUrl}/gamification/challenges/claim-reward/',
    );
    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({'challenge_progress_id': challengeProgressId}),
    );

    FlutterDebugLogger.printJsonResponse(
      url: uri.toString(),
      method: Method.POST,
      tag: 'Gamification-ClaimReward',
      statusCode: response.statusCode,
      responseBody: response.body,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(utf8.decode(response.bodyBytes))
          as Map<String, dynamic>;
    } else {
      final error = jsonDecode(utf8.decode(response.bodyBytes));
      throw Exception(
        error['message'] ?? error['detail'] ?? 'Failed to claim reward',
      );
    }
  }

  // In your WorkoutService class
  Future<TrackProgress> fetchDailyProgress({String? date}) async {
    final token = GetStorage().read("loginToken");
    if (token == null) throw Exception("Login required");

    final todayFormatted = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final queryDate = (date != null && date.trim().isNotEmpty) ? date.trim() : todayFormatted;

    final uri = Uri.parse(
      "${AppConstants.baseUrl}/workouts/daily-progress/",
    ).replace(queryParameters: {'date': queryDate});

    final response = await http.get(
      uri,
      headers: {"Authorization": "Bearer $token", "Accept": "application/json"},
    );

    FlutterDebugLogger.printJsonResponse(
      url: uri.toString(),
      method: Method.GET,
      tag: 'Home-DailyProgress',
      statusCode: response.statusCode,
      responseBody: response.body,
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(utf8.decode(response.bodyBytes));
      return TrackProgress.fromJson(json);
    } else {
      throw Exception("Failed to load daily progress");
    }
  }

  /// NEW: Fetch Gallery Dashboard (FitTracker) – Calendar dots + Latest images
  Future<GalleryDashboardResponse> fetchGalleryDashboard({
    int? month,
    int? year,
  }) async {
    final token = box.read("loginToken");
    if (token == null) throw Exception("Login required");

    final Map<String, dynamic> queryParams = {};
    if (month != null) queryParams['month'] = month.toString();
    if (year != null) queryParams['year'] = year.toString();

    final uri = Uri.parse(
      "${AppConstants.baseUrl}/gallery/dashboard/",
    ).replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);

    final response = await http.get(
      uri,
      headers: {"Authorization": "Bearer $token", "Accept": "application/json"},
    );

    FlutterDebugLogger.printJsonResponse(
      url: uri.toString(),
      method: Method.GET,
      tag: 'Gallery-Dashboard',
      statusCode: response.statusCode,
      responseBody: response.body,
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(utf8.decode(response.bodyBytes));
      return GalleryDashboardResponse.fromJson(json);
    } else {
      try {
        final error = jsonDecode(response.body);
        throw Exception(
          error['detail'] ??
              error['message'] ??
              "Failed to load gallery dashboard (${response.statusCode})",
        );
      } catch (e) {
        if (e is Exception && !e.toString().contains('FormatException')) rethrow;
        throw Exception("Server error (${response.statusCode}): ${response.body}");
      }
    }
  }

  // In your HomeService class
  // HomeService.dart — FINAL VERSION
  Future<bool> uploadProgressPhoto({required Uint8List imageBytes}) async {
    final token = box.read("loginToken");
    if (token == null) throw Exception("Login required");

    final url = "${AppConstants.baseUrl}/gallery/";

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(url),
      );

      request.headers['Authorization'] = 'Bearer $token';

      request.files.add(
        http.MultipartFile.fromBytes(
          'image', // ← exact field name your DRF serializer uses
          imageBytes,
          filename: 'photo.jpg',
          contentType: MediaType('image', 'jpeg'),
        ),
      );

      // DO NOT send progress_type → your AI detects it automatically

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      FlutterDebugLogger.printJsonResponse(
        url: url,
        method: Method.POST,
        tag: 'Gallery-UploadPhoto',
        statusCode: response.statusCode,
        responseBody: response.body,
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("Upload error: $e");
      return false;
    }
  }

  // Add this if not exists — fetches ALL gallery images (for ProgressGalleryPage)
  Future<List<GalleryImage>> fetchAllGalleryImages() async {
    final token = box.read("loginToken");
    if (token == null) throw Exception("Login required");

    final url = "${AppConstants.baseUrl}/gallery/";

    final response = await http.get(
      Uri.parse(url),
      headers: {"Authorization": "Bearer $token", "Accept": "application/json"},
    );

    FlutterDebugLogger.printJsonResponse(
      url: url,
      method: Method.GET,
      tag: 'Gallery-AllImages',
      statusCode: response.statusCode,
      responseBody: response.body,
    );

    if (response.statusCode == 200) {
      final dynamic decoded = jsonDecode(utf8.decode(response.bodyBytes));
      List<dynamic> results = [];
      if (decoded is List) {
        results = decoded;
      } else if (decoded is Map<String, dynamic>) {
        results = decoded['results'] ?? decoded['data'] ?? [];
      }
      return results.map((item) => GalleryImage.fromJson(item as Map<String, dynamic>)).toList();
    } else {
      try {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? error['message'] ?? "Failed to load gallery images (${response.statusCode})");
      } catch (e) {
        if (e is Exception && !e.toString().contains('FormatException')) rethrow;
        throw Exception("Server error (${response.statusCode}): ${response.body}");
      }
    }
  }

  Future<LeaderboardResponse> fetchLeaderboard({int limit = 50}) async {
    final token = GetStorage().read("loginToken");
    if (token == null) throw Exception("Login required");

    final uri = Uri.parse(
      "${AppConstants.baseUrl}/gamification/leaderboard/",
    ).replace(queryParameters: {'limit': limit.toString()});

    final response = await http.get(
      uri,
      headers: {"Authorization": "Bearer $token", "Accept": "application/json"},
    );

    FlutterDebugLogger.printJsonResponse(
      url: uri.toString(),
      method: Method.GET,
      tag: 'Home-Leaderboard',
      statusCode: response.statusCode,
      responseBody: response.body,
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(utf8.decode(response.bodyBytes));
      return LeaderboardResponse.fromJson(json);
    } else {
      throw Exception("Failed to load leaderboard");
    }
  }

  Future<List<Workout>> fetchRecommendedWorkouts() async {
    final token = box.read("loginToken");
    if (token == null) throw Exception("Not logged in");

    final url = Uri.parse("${AppConstants.baseUrl}/workouts/recommendation/");

    final response = await http.get(
      url,
      headers: {"Authorization": "Bearer $token", "Accept": "application/json"},
    );

    FlutterDebugLogger.printJsonResponse(
      url: url.toString(),
      method: Method.GET,
      tag: 'Home-RecommendedWorkouts',
      statusCode: response.statusCode,
      responseBody: response.body,
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(
        utf8.decode(response.bodyBytes),
      );
      return jsonList.map((json) => Workout.fromJson(json)).toList();
    } else {
      throw Exception("Failed to load workouts: ${response.statusCode}");
    }
  }

  Future<Map<String, List<dynamic>>> search(String query) async {
    final token = box.read("loginToken");
    final uri = Uri.parse("${AppConstants.baseUrl}/utils/search/").replace(
      queryParameters: {'q': query},
    );

    final response = await http.get(
      uri,
      headers: {"Authorization": "Bearer $token", "Accept": "application/json"},
    );

    FlutterDebugLogger.printJsonResponse(
      url: uri.toString(),
      method: Method.GET,
      tag: 'Home-Search',
      statusCode: response.statusCode,
      responseBody: response.body,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(
        utf8.decode(response.bodyBytes),
      );
      final List<dynamic> workoutsJson = data['workouts'] ?? [];
      final List<dynamic> articlesJson = data['articles'] ?? [];

      return {
        'workouts': workoutsJson.map((json) => Workout.fromJson(json)).toList(),
        'articles': articlesJson.map((json) => Article.fromJson(json)).toList(),
      };
    } else {
      throw Exception("Failed to perform search: ${response.statusCode}");
    }
  }

  /// NEW: Toggle Favorite for Workout or Article
  Future<bool> toggleFavorite({
    required String contentType,
    required int objectId,
  }) async {
    try {
      final token = box.read("loginToken");
      if (token == null) return false;

      final url = Uri.parse("${AppConstants.baseUrl}/utils/favorites/toggle/");

      final response = await http.post(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({
          "content_type": contentType,
          "object_id": objectId,
        }),
      );

      FlutterDebugLogger.printJsonResponse(
        url: url.toString(),
        method: Method.POST,
        tag: 'Home-ToggleFavorite',
        statusCode: response.statusCode,
        responseBody: response.body,
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("Toggle favorite service error: $e");
      return false;
    }
  }

  /// Fetch Home Overview (Daily Workout Session, Daily Challenge, Workouts, Articles)
  Future<Map<String, dynamic>> fetchHomeOverview() async {
    try {
      final token = box.read("loginToken");
      final url = Uri.parse("${AppConstants.baseUrl}/accounts/home/");

      final headers = <String, String>{
        "Accept": "application/json",
      };
      if (token != null && token.toString().isNotEmpty) {
        headers["Authorization"] = "Bearer $token";
      }

      final response = await http.get(url, headers: headers);

      FlutterDebugLogger.printJsonResponse(
        url: url.toString(),
        method: Method.GET,
        tag: 'Home-Overview',
        statusCode: response.statusCode,
        responseBody: response.body,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> json =
            jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;

        Workout? dailyWorkout;
        if (json['daily_workout_session'] != null &&
            json['daily_workout_session'] is Map<String, dynamic>) {
          dailyWorkout = Workout.fromJson(
            json['daily_workout_session'] as Map<String, dynamic>,
          );
        }

        Challenge? dailyChallenge;
        if (json['daily_challenge'] != null &&
            json['daily_challenge'] is Map<String, dynamic>) {
          dailyChallenge = Challenge.fromJson(
            json['daily_challenge'] as Map<String, dynamic>,
          );
        }

        return {
          'daily_workout_session': dailyWorkout,
          'daily_challenge': dailyChallenge,
        };
      } else {
        throw Exception(
          "Failed to load home data (${response.statusCode}): ${response.body}",
        );
      }
    } catch (e) {
      print("Error in fetchHomeOverview: $e");
      rethrow;
    }
  }
}

