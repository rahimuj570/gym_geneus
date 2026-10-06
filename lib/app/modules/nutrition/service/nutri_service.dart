// nutrition_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../../../constants/appconstants.dart';
import '../../../services/api_client.dart';
import '../model/meal_result_analysis.dart';
import '../model/nutrion_home.dart';

class NutritionService {
  final box = GetStorage();

  // Step 1: Upload image and get analysis
  Future<MealAnalysisResult> uploadMealImage(File imageFile) async {
    final url = '${AppConstants.baseUrl}/nutrition/upload-meal/';

    final response = await ApiClient.sendMultipartRequest(
      Uri.parse(url),
      method: 'POST',
      tag: 'Nutrition-UploadMeal',
      buildRequest: (token) async {
        final request = http.MultipartRequest('POST', Uri.parse(url));
        if (token != null) {
          request.headers['Authorization'] = 'Bearer $token';
        }
        request.files.add(
          await http.MultipartFile.fromPath(
            'image',
            imageFile.path,
            filename: 'meal.jpg',
            contentType: MediaType('image', 'jpeg'),
          ),
        );
        return request;
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return MealAnalysisResult.fromJson(
        jsonDecode(utf8.decode(response.bodyBytes)),
      );
    } else {
      try {
        final error = jsonDecode(utf8.decode(response.bodyBytes));
        throw Exception(
          error['error'] ??
              error['message'] ??
              error['detail'] ??
              'Analysis failed',
        );
      } catch (e) {
        if (e is Exception && !e.toString().contains('FormatException')) rethrow;
        throw Exception(
          'Server error (${response.statusCode}): ${response.body}',
        );
      }
    }
  }

  // Step 2: Save meal upload
  Future<bool> saveMealUpload(int tempUploadId) async {
    final url = Uri.parse('${AppConstants.baseUrl}/nutrition/save-meal-upload/');
    final payload = {"temp_upload_id": tempUploadId};

    final response = await ApiClient.post(
      url,
      body: payload,
      tag: 'Nutrition-SaveMeal',
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      try {
        final error = jsonDecode(utf8.decode(response.bodyBytes));
        throw Exception(
          error['error'] ??
              error['message'] ??
              error['detail'] ??
              'Failed to save meal',
        );
      } catch (e) {
        if (e is Exception && !e.toString().contains('FormatException')) rethrow;
        throw Exception(
          'Server error (${response.statusCode}): ${response.body}',
        );
      }
    }
  }

  // Step 3: Fetch home/daily nutrition breakdown data
  Future<NutritionHomeResponse> fetchNutritionHome() async {
    final url = Uri.parse('${AppConstants.baseUrl}/nutrition/');

    final response = await ApiClient.get(
      url,
      tag: 'Nutrition-Home',
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(
        utf8.decode(response.bodyBytes),
      );
      return NutritionHomeResponse.fromJson(data);
    } else {
      try {
        final error = jsonDecode(utf8.decode(response.bodyBytes));
        throw Exception(
          error['error'] ??
              error['message'] ??
              error['detail'] ??
              'Failed to fetch nutrition data (${response.statusCode})',
        );
      } catch (e) {
        if (e is Exception && !e.toString().contains('FormatException')) rethrow;
        throw Exception(
          'Server error (${response.statusCode}): ${response.body}',
        );
      }
    }
  }
}
