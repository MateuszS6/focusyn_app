import 'package:flutter/material.dart';
import 'package:focusyn_app/constants/keys.dart';
import 'package:focusyn_app/constants/theme_icons.dart';
import 'package:focusyn_app/main_screen.dart';
import 'package:focusyn_app/services/setting_service.dart';

/// A page that introduces new users to the app's features and functionality.
///
/// This page provides:
/// - Interactive onboarding experience with multiple slides
/// - Visual and textual explanations of key features
/// - Progress indicators and navigation controls
/// - Option to skip or complete the onboarding
/// - Automatic navigation to main screen after completion
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

/// Manages the state of the onboarding page, including:
/// - Page navigation and progress tracking
/// - Onboarding content and presentation
/// - User interaction handling
/// - Completion state management
class _OnboardingPageState extends State<OnboardingPage> {
  // Page controller for managing slide transitions
  final PageController _pageController = PageController();

  // Current page index and total number of pages
  int _currentPage = 0;
  final int _totalPages = 5;

  /// List of onboarding items, each representing a slide with:
  /// - Title and description
  /// - Visual element (icon or image)
  /// - Color theme
  final List<OnboardingItem> _items = [
    OnboardingItem(
      title: 'Welcome to Focusyn',
      description:
          'Your personal productivity companion that helps you stay focused, organized, and motivated.',
      imagePath: 'assets/logo_transparent.png',
      color: Colors.blue,
    ),
    OnboardingItem(
      title: 'Focus on What Matters',
      description:
          'Organize your tasks into Flows, Actions, Moments, and Thoughts to maintain clarity and focus.',
      icon: ThemeIcons.actions,
      color: Colors.orange,
    ),
    OnboardingItem(
      title: 'Track Brain Points',
      description:
          'Completing tasks uses Brain Points. Plan your day to maximize your productivity.',
      icon: ThemeIcons.brainPoints,
      color: Colors.purple,
    ),
    OnboardingItem(
      title: 'Meet ${Keys.aiName} AI',
      description:
          'Your AI assistant that helps you stay on track, answers questions, and provides personalized guidance.',
      icon: ThemeIcons.robot,
      color: Colors.teal,
    ),
    OnboardingItem(
      title: 'Ready to Get Started?',
      description:
          'Swipe to begin your journey with Focusyn and take control of your productivity today!',
      icon: ThemeIcons.play,
      color: Colors.green,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// Handles page change events and updates the current page index
  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  /// Completes the onboarding process by:
  /// 1. Marking onboarding as completed in settings
  /// 2. Navigating to the main screen
  void _completeOnboarding() async {
    // Mark onboarding as completed
    SettingService.setOnboardingDone(true);

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Onboarding Slides
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _totalPages,
                itemBuilder: (context, index) {
                  return _buildPage(_items[index]);
                },
              ),
            ),
            // Navigation Controls
            _buildBottomSection(),
          ],
        ),
      ),
    );
  }

  /// Builds a single onboarding page with:
  /// - Visual element (icon or image)
  /// - Title and description
  /// - Consistent styling and layout
  Widget _buildPage(OnboardingItem item) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Visual Element Container
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: item.color.withAlpha(13),
              shape: BoxShape.circle,
            ),
            child: Center(
              child:
                  item.imagePath != null
                      ? Image.asset(item.imagePath!, width: 100, height: 100)
                      : Icon(item.icon, size: 60, color: item.color),
            ),
          ),
          const SizedBox(height: 40),
          // Title
          Text(
            item.title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          // Description
          Text(
            item.description,
            style: const TextStyle(fontSize: 16, color: Colors.black54),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Builds the bottom section containing:
  /// - Page indicators
  /// - Navigation buttons (Next/Skip or Get Started)
  Widget _buildBottomSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          // Page Indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_totalPages, (index) => _buildDot(index)),
          ),
          const SizedBox(height: 24),
          // Navigation Buttons
          if (_currentPage == _totalPages - 1)
            // Get Started Button (on last page)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _completeOnboarding,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Get Started',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            )
          else
            // Next/Skip Buttons (on other pages)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: _completeOnboarding,
                  child: const Text('Skip'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Next'),
                ),
              ],
            ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  /// Builds a page indicator dot with:
  /// - Active state (filled)
  /// - Inactive state (outlined)
  Widget _buildDot(int index) {
    return Container(
      width: 10,
      height: 10,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _currentPage == index ? Colors.blue : Colors.grey.shade300,
      ),
    );
  }
}

/// Represents a single onboarding slide with:
/// - Title and description text
/// - Visual element (either icon or image)
/// - Color theme for consistent styling
class OnboardingItem {
  final String title;
  final String description;
  final IconData? icon;
  final String? imagePath;
  final Color color;

  const OnboardingItem({
    required this.title,
    required this.description,
    this.icon,
    this.imagePath,
    required this.color,
  });
}
