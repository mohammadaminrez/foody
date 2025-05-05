import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/user_profile_viewmodel.dart';
import 'health_info_card.dart';
import 'nutrition_recommendations_card.dart';
import '../../data/datasources/remote/openai_service.dart';
import '../../data/datasources/local/nutrition_recommendations_storage.dart';

class HealthAnalysisContent extends StatefulWidget {
  final Widget? additionalContent;

  const HealthAnalysisContent({
    super.key,
    this.additionalContent,
  });

  @override
  State<HealthAnalysisContent> createState() => _HealthAnalysisContentState();
}

class _HealthAnalysisContentState extends State<HealthAnalysisContent> {
  Map<String, dynamic>? _recommendations;
  bool _isLoading = true;
  final _storage = NutritionRecommendationsStorage();

  @override
  void initState() {
    super.initState();
    _loadRecommendations();
  }

  Future<void> _loadRecommendations() async {
    try {
      // First try to load from shared preferences
      final savedRecommendations = await _storage.loadRecommendations();

      if (savedRecommendations != null) {
        if (mounted) {
          setState(() {
            _recommendations = savedRecommendations;
            _isLoading = false;
          });
        }
        return;
      }

      // If no saved recommendations, fetch new ones
      final profileVM =
          Provider.of<UserProfileViewModel>(context, listen: false);
      final profile = profileVM.profile!;

      final openAIService = OpenAIService();
      final recommendations = await openAIService.getNutritionRecommendations(
        gender: profile.gender,
        age: profile.age,
        weight: profile.weightKg,
        height: profile.heightCm,
        activityLevel: profile.activityLevel.toString(),
      );

      if (mounted) {
        setState(() {
          _recommendations = recommendations;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load recommendations: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileVM = Provider.of<UserProfileViewModel>(context);
    final profile = profileVM.profile!;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            HealthInfoCard(
              profile: profile,
              isMetric: profileVM.isMetric,
            ),
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_recommendations != null)
              NutritionRecommendationsCard(
                recommendations: _recommendations!,
              ),
            if (widget.additionalContent != null) ...[
              const SizedBox(height: 24),
              widget.additionalContent!,
            ],
          ],
        ),
      ),
    );
  }
}
