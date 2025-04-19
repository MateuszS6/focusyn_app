import 'package:flutter/material.dart';
import 'package:focusyn_app/constants/keys.dart';
import 'package:focusyn_app/constants/theme_icons.dart';
import 'package:focusyn_app/main_screen.dart';
import 'package:hive/hive.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = 5;

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
      title: 'Meet Synthe AI',
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

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _completeOnboarding() async {
    // Mark onboarding as completed
    final settingsBox = Hive.box(Keys.settingBox);
    await settingsBox.put('onboardingCompleted', true);

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
            _buildBottomSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingItem item) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
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
          Text(
            item.title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            item.description,
            style: const TextStyle(fontSize: 16, color: Colors.black54),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_totalPages, (index) => _buildDot(index)),
          ),
          const SizedBox(height: 24),
          if (_currentPage == _totalPages - 1)
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
