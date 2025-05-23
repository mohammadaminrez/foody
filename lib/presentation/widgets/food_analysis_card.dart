import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:io';
import '../../data/models/food_analysis.dart';
import '../../../core/constants/app_colors.dart';
import 'food_analysis_shimmer.dart';

class FoodAnalysisCard extends StatelessWidget {
  final FoodAnalysis analysis;
  final VoidCallback? onDelete;
  final bool isLoading;

  const FoodAnalysisCard({
    Key? key,
    required this.analysis,
    this.onDelete,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const FoodAnalysisShimmer();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    AppColors.withOpacity(AppColors.grey800, 0.9),
                    AppColors.withOpacity(AppColors.grey600, 0.8),
                  ]
                : [
                    AppColors.withOpacity(AppColors.white, 0.9),
                    AppColors.withOpacity(AppColors.white, 0.8),
                  ],
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? AppColors.withOpacity(AppColors.black, 0.3)
                  : AppColors.withOpacity(AppColors.black, 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: AppColors.transparent,
              builder: (context) => DraggableScrollableSheet(
                initialChildSize: 0.9,
                maxChildSize: 0.9,
                minChildSize: 0.5,
                expand: false,
                builder: (context, scrollController) => Container(
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.grey800 : AppColors.white,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(32)),
                    boxShadow: [
                      BoxShadow(
                        color: isDark
                            ? AppColors.withOpacity(AppColors.black, 0.4)
                            : AppColors.withOpacity(AppColors.black, 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Column(
                      children: [
                        _buildContent(context),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildImage(context),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.withOpacity(
                                  Theme.of(context).primaryColor, 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '#${analysis.dateOrderNumber}',
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              analysis.name,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.5,
                                color:
                                    isDark ? AppColors.white : AppColors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color:
                                  AppColors.withOpacity(AppColors.orange, 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const FaIcon(
                                  FontAwesomeIcons.fire,
                                  size: 14,
                                  color: AppColors.orange,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${analysis.calories.toStringAsFixed(1)} cal',
                                  style: const TextStyle(
                                    color: AppColors.orange,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
                FaIcon(
                  FontAwesomeIcons.chevronRight,
                  color: isDark ? AppColors.grey400 : AppColors.grey400,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImage(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (analysis.imagePath != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.file(
          File(analysis.imagePath!),
          width: 80,
          height: 80,
          fit: BoxFit.cover,
        ),
      );
    }
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  AppColors.withOpacity(Theme.of(context).primaryColor, 0.3),
                  AppColors.withOpacity(Theme.of(context).primaryColor, 0.2),
                ]
              : [
                  AppColors.withOpacity(Theme.of(context).primaryColor, 0.2),
                  AppColors.withOpacity(Theme.of(context).primaryColor, 0.1),
                ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text(
          analysis.name[0].toUpperCase(),
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: const Text('Delete Food'),
        content: Text('Are you sure you want to delete ${analysis.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.of(context).pop();
              Future.delayed(const Duration(milliseconds: 300), () {
                onDelete?.call();
              });
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Image Section
              Stack(
                children: [
                  if (analysis.imagePath != null)
                    Container(
                      height: 300,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(32),
                          topRight: Radius.circular(32),
                        ),
                        image: DecorationImage(
                          image: FileImage(File(analysis.imagePath!)),
                          fit: BoxFit.cover,
                        ),
                      ),
                    )
                  else
                    Container(
                      height: 300,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Theme.of(context).primaryColor,
                            Theme.of(context).primaryColor.withOpacity(0.7),
                          ],
                        ),
                      ),
                      child: Center(
                        child: Text(
                          analysis.name[0].toUpperCase(),
                          style: const TextStyle(
                            fontSize: 72,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  // Swipe Indicator
                  Positioned(
                    top: 12,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 48,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Gradient Overlay
                  Container(
                    height: 300,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                  // Food Name and Order Number
                  Positioned(
                    bottom: 24,
                    left: 24,
                    right: 24,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '#${analysis.dateOrderNumber}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          analysis.name,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Content Section
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nutrition Section
                    const Text(
                      'Nutritional Information',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final cardWidth = (constraints.maxWidth - 48) /
                            4; // 48 = 3 * 16 (spacing between cards)
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: cardWidth,
                              child: _buildNutritionCard(
                                'Calories',
                                analysis.calories,
                                'cal',
                                AppColors.orange,
                                FontAwesomeIcons.fire,
                              ),
                            ),
                            SizedBox(
                              width: cardWidth,
                              child: _buildNutritionCard(
                                'Protein',
                                analysis.protein,
                                'g',
                                AppColors.blue,
                                FontAwesomeIcons.dumbbell,
                              ),
                            ),
                            SizedBox(
                              width: cardWidth,
                              child: _buildNutritionCard(
                                'Carbs',
                                analysis.carbs,
                                'g',
                                AppColors.green,
                                FontAwesomeIcons.carrot,
                              ),
                            ),
                            SizedBox(
                              width: cardWidth,
                              child: _buildNutritionCard(
                                'Fat',
                                analysis.fat,
                                'g',
                                AppColors.orange,
                                FontAwesomeIcons.water,
                              ),
                            ),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 32),

                    // Health Score Section
                    const Text(
                      'Health Score',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            _getHealthScoreColor(analysis.healthScore)
                                .withOpacity(0.1),
                            _getHealthScoreColor(analysis.healthScore)
                                .withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _getHealthScoreColor(analysis.healthScore)
                              .withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color:
                                      _getHealthScoreColor(analysis.healthScore)
                                          .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: FaIcon(
                                  FontAwesomeIcons.heart,
                                  color: _getHealthScoreColor(
                                      analysis.healthScore),
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${analysis.healthScore.toStringAsFixed(1)}/10',
                                      style: TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: _getHealthScoreColor(
                                            analysis.healthScore),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _getHealthScoreDescription(
                                          analysis.healthScore),
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withOpacity(0.7),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: LinearProgressIndicator(
                              value: analysis.healthScore / 10,
                              backgroundColor:
                                  _getHealthScoreColor(analysis.healthScore)
                                      .withOpacity(0.1),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _getHealthScoreColor(analysis.healthScore),
                              ),
                              minHeight: 8,
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (onDelete != null) const SizedBox(height: 100),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Delete Button
        if (onDelete != null)
          Positioned(
            left: 0,
            right: 0,
            bottom: 24,
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.error.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: AppColors.transparent,
                  child: InkWell(
                    onTap: () => _showDeleteDialog(context),
                    customBorder: const CircleBorder(),
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.error,
                            AppColors.error.withOpacity(0.8),
                          ],
                        ),
                      ),
                      child: const Center(
                        child: FaIcon(
                          FontAwesomeIcons.trash,
                          color: AppColors.white,
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Color _getHealthScoreColor(double score) {
    if (score >= 8) {
      return AppColors.green;
    } else if (score >= 5) {
      return AppColors.orange;
    } else {
      return AppColors.error;
    }
  }

  Widget _buildNutritionCard(
    String label,
    double value,
    String unit,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.withOpacity(color, 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FaIcon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '${value.toStringAsFixed(1)}$unit',
              style: TextStyle(
                color: color,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  String _getHealthScoreDescription(double score) {
    if (score >= 8) {
      return 'Excellent choice! This food is very healthy.';
    } else if (score >= 5) {
      return 'Moderate choice. Consider healthier alternatives.';
    } else {
      return 'Not recommended. Try to find a healthier option.';
    }
  }
}
