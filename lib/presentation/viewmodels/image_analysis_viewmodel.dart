import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/food_analysis.dart';
import '../../data/datasources/remote/openai_service.dart';
import '../../data/datasources/local/food_analysis_storage.dart';
import '../widgets/rating_dialog.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class ImageAnalysisViewModel extends ChangeNotifier {
  final OpenAIService _service = OpenAIService();
  final ImagePicker _picker = ImagePicker();
  final FoodAnalysisStorage _storage = FoodAnalysisStorage();

  File? _selectedImage;
  FoodAnalysis? _currentAnalysis;
  bool _isLoading = false;
  String? _error;
  List<FoodAnalysis> _savedAnalyses = [];
  DateTime? _firstUseDate;

  File? get selectedImage => _selectedImage;
  FoodAnalysis? get currentAnalysis => _currentAnalysis;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<FoodAnalysis> get savedAnalyses => List.unmodifiable(_savedAnalyses);

  ImageAnalysisViewModel() {
    _loadSavedAnalyses();
    _initializeFirstUseDate();
  }

  Future<void> _initializeFirstUseDate() async {
    final prefs = await SharedPreferences.getInstance();
    final firstUseTimestamp = prefs.getInt('first_use_date');
    if (firstUseTimestamp == null) {
      _firstUseDate = DateTime.now();
      await prefs.setInt(
          'first_use_date', _firstUseDate!.millisecondsSinceEpoch);
    } else {
      _firstUseDate = DateTime.fromMillisecondsSinceEpoch(firstUseTimestamp);
    }
  }

  Future<void> _loadSavedAnalyses() async {
    _savedAnalyses = await _storage.loadAnalyses();
    notifyListeners();
  }

  Future<void> _checkAndShowRating() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSubmittedRating = prefs.getBool('has_submitted_rating') ?? false;
    final maybeLaterTimestamp = prefs.getInt('maybe_later_timestamp');

    if (hasSubmittedRating) return;

    // Check if user has added at least 3 foods
    if (_savedAnalyses.length < 3) return;

    // If user clicked "Maybe Later", check if 2 days have passed
    if (maybeLaterTimestamp != null) {
      final daysSinceMaybeLater = DateTime.now()
          .difference(DateTime.fromMillisecondsSinceEpoch(maybeLaterTimestamp))
          .inDays;
      if (daysSinceMaybeLater < 2) return;
    }

    // Show rating dialog
    final context = navigatorKey.currentContext;
    if (context != null) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const RatingDialog(),
      );
    }
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? img = await _picker.pickImage(source: source);
      if (img != null) {
        _selectedImage = File(img.path);
        _currentAnalysis = null;
        _error = null;
        notifyListeners();
        await analyzeImage();
      }
    } catch (e) {
      _error = 'Failed to pick image';
      notifyListeners();
    }
  }

  Future<void> analyzeImage() async {
    if (_selectedImage == null) return;
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final analysis = await _service.analyzeImage(_selectedImage!);
      _currentAnalysis = FoodAnalysis(
        name: analysis.name,
        protein: analysis.protein,
        carbs: analysis.carbs,
        fat: analysis.fat,
        calories: analysis.calories,
        healthScore: analysis.healthScore,
        imagePath: _selectedImage!.path,
      );
      await _saveCurrentAnalysis();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveCurrentAnalysis() async {
    if (_currentAnalysis != null) {
      final analysis = FoodAnalysis(
        name: _currentAnalysis!.name,
        protein: _currentAnalysis!.protein,
        carbs: _currentAnalysis!.carbs,
        fat: _currentAnalysis!.fat,
        calories: _currentAnalysis!.calories,
        healthScore: _currentAnalysis!.healthScore,
        imagePath: _currentAnalysis!.imagePath,
        orderNumber: _savedAnalyses.length + 1,
      );
      _savedAnalyses.add(analysis);
      await _storage.saveAnalyses(_savedAnalyses);
      _currentAnalysis = null;
      _selectedImage = null;
      notifyListeners();

      // Check if it's a good time to show the rating dialog
      await _checkAndShowRating();
    }
  }

  Future<FoodAnalysis?> removeAnalysis(int index) async {
    if (index >= 0 && index < _savedAnalyses.length) {
      final removedAnalysis = _savedAnalyses[index];
      _savedAnalyses.removeAt(index);
      for (int i = 0; i < _savedAnalyses.length; i++) {
        _savedAnalyses[i] = FoodAnalysis(
          name: _savedAnalyses[i].name,
          protein: _savedAnalyses[i].protein,
          carbs: _savedAnalyses[i].carbs,
          fat: _savedAnalyses[i].fat,
          calories: _savedAnalyses[i].calories,
          healthScore: _savedAnalyses[i].healthScore,
          imagePath: _savedAnalyses[i].imagePath,
          orderNumber: i + 1,
        );
      }
      await _storage.saveAnalyses(_savedAnalyses);
      notifyListeners();
      return removedAnalysis;
    }
    return null;
  }

  Future<void> addAnalysis(FoodAnalysis analysis) async {
    if (analysis.orderNumber > 0) {
      _savedAnalyses.insert(analysis.orderNumber - 1, analysis);
      for (int i = analysis.orderNumber; i < _savedAnalyses.length; i++) {
        _savedAnalyses[i] = FoodAnalysis(
          name: _savedAnalyses[i].name,
          protein: _savedAnalyses[i].protein,
          carbs: _savedAnalyses[i].carbs,
          fat: _savedAnalyses[i].fat,
          calories: _savedAnalyses[i].calories,
          healthScore: _savedAnalyses[i].healthScore,
          imagePath: _savedAnalyses[i].imagePath,
          orderNumber: i + 1,
        );
      }
    } else {
      final newAnalysis = FoodAnalysis(
        name: analysis.name,
        protein: analysis.protein,
        carbs: analysis.carbs,
        fat: analysis.fat,
        calories: analysis.calories,
        healthScore: analysis.healthScore,
        imagePath: analysis.imagePath,
        orderNumber: _savedAnalyses.length + 1,
      );
      _savedAnalyses.add(newAnalysis);
    }
    await _storage.saveAnalyses(_savedAnalyses);
    notifyListeners();
  }

  void clearImage() {
    _selectedImage = null;
    _currentAnalysis = null;
    _error = null;
    notifyListeners();
  }

  // Add method to handle "Maybe Later" response
  Future<void> handleMaybeLater() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
        'maybe_later_timestamp', DateTime.now().millisecondsSinceEpoch);
  }
}
