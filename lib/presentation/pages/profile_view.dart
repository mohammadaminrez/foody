import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/user_profile_viewmodel.dart';
import '../viewmodels/theme_viewmodel.dart';
import '../../domain/entities/user_profile.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/profile_inputs.dart';
import '../../core/constants/app_colors.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileVM = Provider.of<UserProfileViewModel>(context);
    final profile = profileVM.profile!;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Profile',
        icon: FontAwesomeIcons.user,
      ),
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.darkBackground
                  : colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: colorScheme.primary,
              unselectedLabelColor: colorScheme.onSurface.withOpacity(0.6),
              indicatorColor: colorScheme.primary,
              tabs: const [
                Tab(
                  icon: FaIcon(FontAwesomeIcons.user),
                  text: 'Personal',
                ),
                Tab(
                  icon: FaIcon(FontAwesomeIcons.dumbbell),
                  text: 'Activity',
                ),
                Tab(
                  icon: FaIcon(FontAwesomeIcons.bullseye),
                  text: 'Goals',
                ),
                Tab(
                  icon: FaIcon(FontAwesomeIcons.gear),
                  text: 'Settings',
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPersonalTab(context, profileVM, profile),
                _buildActivityTab(context, profileVM, profile),
                _buildGoalsTab(context, profileVM, profile),
                _buildSettingsTab(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalTab(BuildContext context, UserProfileViewModel profileVM,
      UserProfile profile) {
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Measurement Units',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  UnitSwitchButton(
                    isMetric: profileVM.isMetric,
                    onChanged: (value) {
                      final newWeight = value
                          ? profileVM.displayWeight * 0.453592
                          : profileVM.displayWeight * 2.20462;
                      final newHeight = value
                          ? profileVM.displayHeight * 2.54
                          : profileVM.displayHeight / 2.54;
                      profileVM.saveProfile(
                        gender: profileVM.profile!.gender,
                        age: profileVM.profile!.age,
                        weight: newWeight,
                        weightUnit: value ? 'kg' : 'lbs',
                        height: newHeight,
                        heightUnit: value ? 'cm' : 'inch',
                        activityLevel: profileVM.profile!.activityLevel,
                        isMetric: value,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.5,
            children: [
              _buildInfoCard(
                context,
                FontAwesomeIcons.user,
                'Gender',
                profile.gender,
                colorScheme.primary,
                () => _showGenderDialog(context, profileVM),
              ),
              _buildInfoCard(
                context,
                FontAwesomeIcons.cakeCandles,
                'Age',
                '${profile.age} years',
                colorScheme.secondary,
                () => _showAgeDialog(context, profileVM),
              ),
              _buildInfoCard(
                context,
                FontAwesomeIcons.weightScale,
                'Weight',
                '${profileVM.displayWeight.toStringAsFixed(1)} ${profileVM.weightUnit}',
                colorScheme.tertiary,
                () => _showWeightDialog(context, profileVM),
              ),
              _buildInfoCard(
                context,
                FontAwesomeIcons.rulerVertical,
                'Height',
                profileVM.isMetric
                    ? '${profileVM.displayHeight.toStringAsFixed(1)} cm'
                    : '${(profileVM.displayHeight / 12).floor()}′${(profileVM.displayHeight % 12).round()}″',
                colorScheme.error,
                () => _showHeightDialog(context, profileVM),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    IconData icon,
    String title,
    String value,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.1),
                color.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FaIcon(
                icon,
                color: color,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  color: color.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityTab(BuildContext context, UserProfileViewModel profileVM,
      UserProfile profile) {
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Activity Level',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'How active are you in your daily life?',
                    style: TextStyle(
                      fontSize: 16,
                      color: colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 32),
                  ...ActivityLevel.values.map((level) {
                    final isSelected = profile.activityLevel == level;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: InkWell(
                        onTap: () {
                          profileVM.saveProfile(
                            gender: profile.gender,
                            age: profile.age,
                            weight: profileVM.displayWeight,
                            weightUnit: profileVM.weightUnit,
                            height: profileVM.displayHeight,
                            heightUnit: profileVM.heightUnit,
                            activityLevel: level,
                            isMetric: profileVM.isMetric,
                            weightGoal: profile.weightGoal,
                          );
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? colorScheme.primary.withOpacity(0.1)
                                : colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? colorScheme.primary
                                  : colorScheme.outline.withOpacity(0.5),
                              width: 2,
                            ),
                          ),
                          child: Row(
                            children: [
                              FaIcon(
                                _getActivityIcon(level),
                                color: isSelected
                                    ? colorScheme.primary
                                    : colorScheme.onSurface,
                                size: 32,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      level.displayName,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: isSelected
                                            ? colorScheme.primary
                                            : colorScheme.onSurface,
                                      ),
                                    ),
                                    Text(
                                      _getActivityDescription(level),
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: colorScheme.onSurface
                                            .withOpacity(0.7),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                FaIcon(
                                  FontAwesomeIcons.circleCheck,
                                  color: colorScheme.primary,
                                  size: 24,
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalsTab(BuildContext context, UserProfileViewModel profileVM,
      UserProfile profile) {
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Weight Goal',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'What would you like to achieve?',
                    style: TextStyle(
                      fontSize: 16,
                      color: colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 32),
                  ...WeightGoal.values.map((goal) {
                    final isSelected = profile.weightGoal == goal;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: InkWell(
                        onTap: () {
                          profileVM.saveProfile(
                            gender: profile.gender,
                            age: profile.age,
                            weight: profileVM.displayWeight,
                            weightUnit: profileVM.weightUnit,
                            height: profileVM.displayHeight,
                            heightUnit: profileVM.heightUnit,
                            activityLevel: profile.activityLevel,
                            isMetric: profileVM.isMetric,
                            weightGoal: goal,
                          );
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? colorScheme.primary.withOpacity(0.1)
                                : colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? colorScheme.primary
                                  : colorScheme.outline.withOpacity(0.5),
                              width: 2,
                            ),
                          ),
                          child: Row(
                            children: [
                              FaIcon(
                                _getWeightGoalIcon(goal),
                                color: isSelected
                                    ? colorScheme.primary
                                    : colorScheme.onSurface,
                                size: 32,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      goal.displayName,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: isSelected
                                            ? colorScheme.primary
                                            : colorScheme.onSurface,
                                      ),
                                    ),
                                    Text(
                                      _getWeightGoalDescription(goal),
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: colorScheme.onSurface
                                            .withOpacity(0.7),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                FaIcon(
                                  FontAwesomeIcons.circleCheck,
                                  color: colorScheme.primary,
                                  size: 24,
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTab(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Appearance',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Customize your app experience',
                    style: TextStyle(
                      fontSize: 16,
                      color: colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Consumer<ThemeViewModel>(
                    builder: (context, themeVM, _) {
                      return Column(
                        children: [
                          _buildThemeOption(
                            context,
                            FontAwesomeIcons.sun,
                            'Light Theme',
                            'Use light colors',
                            themeVM.themeMode == ThemeMode.light,
                            () {
                              themeVM.setThemeMode(ThemeMode.light);
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildThemeOption(
                            context,
                            FontAwesomeIcons.moon,
                            'Dark Theme',
                            'Use dark colors',
                            themeVM.themeMode == ThemeMode.dark,
                            () {
                              themeVM.setThemeMode(ThemeMode.dark);
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildThemeOption(
                            context,
                            FontAwesomeIcons.circleHalfStroke,
                            'System Theme',
                            'Follow system settings',
                            themeVM.themeMode == ThemeMode.system,
                            () {
                              themeVM.setThemeMode(ThemeMode.system);
                            },
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    bool isSelected,
    VoidCallback onTap,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary.withOpacity(0.1)
              : colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.outline.withOpacity(0.5),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            FaIcon(
              icon,
              color: isSelected ? colorScheme.primary : colorScheme.onSurface,
              size: 32,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              FaIcon(
                FontAwesomeIcons.circleCheck,
                color: colorScheme.primary,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  IconData _getActivityIcon(ActivityLevel level) {
    switch (level) {
      case ActivityLevel.sedentary:
        return FontAwesomeIcons.couch;
      case ActivityLevel.lightlyActive:
        return FontAwesomeIcons.personWalking;
      case ActivityLevel.moderatelyActive:
        return FontAwesomeIcons.personRunning;
      case ActivityLevel.veryActive:
        return FontAwesomeIcons.dumbbell;
      case ActivityLevel.extraActive:
        return FontAwesomeIcons.personBiking;
    }
  }

  String _getActivityDescription(ActivityLevel level) {
    switch (level) {
      case ActivityLevel.sedentary:
        return 'Little or no exercise';
      case ActivityLevel.lightlyActive:
        return 'Light exercise 1-3 days/week';
      case ActivityLevel.moderatelyActive:
        return 'Moderate exercise 3-5 days/week';
      case ActivityLevel.veryActive:
        return 'Hard exercise 6-7 days/week';
      case ActivityLevel.extraActive:
        return 'Very hard exercise & physical job';
    }
  }

  String _getWeightGoalDescription(WeightGoal goal) {
    switch (goal) {
      case WeightGoal.lose:
        return 'Reduce body weight';
      case WeightGoal.maintain:
        return 'Keep current weight';
      case WeightGoal.gain:
        return 'Increase body weight';
    }
  }

  void _showGenderDialog(BuildContext context, UserProfileViewModel vm) {
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Select Gender',
          style: TextStyle(
            color: colorScheme.onSurface,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: FaIcon(
                FontAwesomeIcons.mars,
                color: colorScheme.primary,
              ),
              title: Text(
                'Male',
                style: TextStyle(
                  color: colorScheme.onSurface,
                ),
              ),
              trailing: FaIcon(
                vm.profile!.gender == 'Male'
                    ? FontAwesomeIcons.circleCheck
                    : FontAwesomeIcons.circle,
                color: vm.profile!.gender == 'Male'
                    ? colorScheme.primary
                    : colorScheme.onSurface.withOpacity(0.5),
              ),
              onTap: () {
                vm.saveProfile(
                  gender: 'Male',
                  age: vm.profile!.age,
                  weight: vm.displayWeight,
                  weightUnit: vm.weightUnit,
                  height: vm.displayHeight,
                  heightUnit: vm.heightUnit,
                  activityLevel: vm.profile!.activityLevel,
                  isMetric: vm.isMetric,
                );
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: FaIcon(
                FontAwesomeIcons.venus,
                color: colorScheme.primary,
              ),
              title: Text(
                'Female',
                style: TextStyle(
                  color: colorScheme.onSurface,
                ),
              ),
              trailing: FaIcon(
                vm.profile!.gender == 'Female'
                    ? FontAwesomeIcons.circleCheck
                    : FontAwesomeIcons.circle,
                color: vm.profile!.gender == 'Female'
                    ? colorScheme.primary
                    : colorScheme.onSurface.withOpacity(0.5),
              ),
              onTap: () {
                vm.saveProfile(
                  gender: 'Female',
                  age: vm.profile!.age,
                  weight: vm.displayWeight,
                  weightUnit: vm.weightUnit,
                  height: vm.displayHeight,
                  heightUnit: vm.heightUnit,
                  activityLevel: vm.profile!.activityLevel,
                  isMetric: vm.isMetric,
                );
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAgeDialog(BuildContext context, UserProfileViewModel vm) {
    final colorScheme = Theme.of(context).colorScheme;
    int selectedAge = vm.profile!.age;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Select Age',
          style: TextStyle(
            color: colorScheme.onSurface,
          ),
        ),
        content: AgeInput(
          age: selectedAge,
          onChanged: (age) {
            selectedAge = age;
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: colorScheme.primary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              vm.saveProfile(
                gender: vm.profile!.gender,
                age: selectedAge,
                weight: vm.displayWeight,
                weightUnit: vm.weightUnit,
                height: vm.displayHeight,
                heightUnit: vm.heightUnit,
                activityLevel: vm.profile!.activityLevel,
                isMetric: vm.isMetric,
              );
              Navigator.pop(context);
            },
            child: Text(
              'Save',
              style: TextStyle(
                color: colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showWeightDialog(BuildContext context, UserProfileViewModel vm) {
    final colorScheme = Theme.of(context).colorScheme;
    double selectedWeight = vm.displayWeight;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Edit Weight',
          style: TextStyle(
            color: colorScheme.onSurface,
          ),
        ),
        content: WeightInput(
          weight: selectedWeight,
          unit: vm.weightUnit,
          onChanged: (weight) {
            selectedWeight = weight;
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: colorScheme.primary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              vm.saveProfile(
                gender: vm.profile!.gender,
                age: vm.profile!.age,
                weight: selectedWeight,
                weightUnit: vm.weightUnit,
                height: vm.displayHeight,
                heightUnit: vm.heightUnit,
                activityLevel: vm.profile!.activityLevel,
                isMetric: vm.isMetric,
              );
              Navigator.pop(context);
            },
            child: Text(
              'Save',
              style: TextStyle(
                color: colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showHeightDialog(BuildContext context, UserProfileViewModel vm) {
    final colorScheme = Theme.of(context).colorScheme;
    double selectedHeight = vm.displayHeight;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Edit Height',
          style: TextStyle(
            color: colorScheme.onSurface,
          ),
        ),
        content: HeightInput(
          height: selectedHeight,
          isMetric: vm.isMetric,
          onChanged: (height) {
            selectedHeight = height;
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: colorScheme.primary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              vm.saveProfile(
                gender: vm.profile!.gender,
                age: vm.profile!.age,
                weight: vm.displayWeight,
                weightUnit: vm.weightUnit,
                height: selectedHeight,
                heightUnit: vm.heightUnit,
                activityLevel: vm.profile!.activityLevel,
                isMetric: vm.isMetric,
              );
              Navigator.pop(context);
            },
            child: Text(
              'Save',
              style: TextStyle(
                color: colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getWeightGoalIcon(WeightGoal goal) {
    switch (goal) {
      case WeightGoal.lose:
        return FontAwesomeIcons.arrowDown;
      case WeightGoal.maintain:
        return FontAwesomeIcons.arrowRight;
      case WeightGoal.gain:
        return FontAwesomeIcons.arrowUp;
    }
  }
}
