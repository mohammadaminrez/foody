import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class NutritionRecommendationsStorage {
  static const String _storageKey = 'nutrition_recommendations';

  Future<void> saveRecommendations(Map<String, dynamic> recommendations) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(recommendations));
  }

  Future<Map<String, dynamic>?> loadRecommendations() async {
    final prefs = await SharedPreferences.getInstance();
    final recommendationsJson = prefs.getString(_storageKey);

    if (recommendationsJson == null) return null;

    return jsonDecode(recommendationsJson) as Map<String, dynamic>;
  }

  Future<void> clearRecommendations() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }
}
