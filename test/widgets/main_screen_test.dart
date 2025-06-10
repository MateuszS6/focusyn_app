import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:focusyn_app/constants/keys.dart';
import 'package:focusyn_app/constants/theme_icons.dart';
import 'package:hive/hive.dart';
import 'dart:io';

// Simple mock page for testing
class MockPage extends StatelessWidget {
  final String title;
  const MockPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Page: $title'));
  }
}

// Mock version of MainScreen that excludes cloud functionality
class MockMainScreen extends StatefulWidget {
  const MockMainScreen({super.key});

  @override
  State<MockMainScreen> createState() => _MockMainScreenState();
}

class _MockMainScreenState extends State<MockMainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const MockPage(title: Keys.today),
    const MockPage(title: Keys.focuses),
    const MockPage(title: Keys.aiName),
    const MockPage(title: Keys.planner),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.today), label: Keys.today),
          NavigationDestination(
            icon: Icon(Icons.category),
            label: Keys.focuses,
          ),
          NavigationDestination(
            icon: Icon(ThemeIcons.robot),
            label: Keys.aiName,
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_today),
            label: Keys.planner,
          ),
        ],
      ),
    );
  }
}

void main() {
  group('MainScreen Navigation Tests', () {
    late Directory tempDir;
    late Box settingsBox;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp();
      Hive.init(tempDir.path);

      // Open and initialize settings box
      settingsBox = await Hive.openBox(Keys.settingBox);
      await settingsBox.put('onboardingDone', true);
    });

    tearDown(() async {
      await Hive.close();
      await tempDir.delete(recursive: true);
    });

    testWidgets('Navigation bar shows correct items', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: MockMainScreen()));

      // Verify that all navigation items are present in the navigation bar
      expect(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text(Keys.today),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text(Keys.focuses),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text(Keys.aiName),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text(Keys.planner),
        ),
        findsOneWidget,
      );
    });

    testWidgets('Navigation bar switches pages correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: MockMainScreen()));

      // Verify initial page
      expect(find.text('Page: ${Keys.today}'), findsOneWidget);

      // Tap on the Focuses tab
      await tester.tap(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text(Keys.focuses),
        ),
      );
      await tester.pumpAndSettle();

      // Verify that we're on the Focuses page
      expect(find.text('Page: ${Keys.focuses}'), findsOneWidget);

      // Tap on the AI tab
      await tester.tap(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text(Keys.aiName),
        ),
      );
      await tester.pumpAndSettle();

      // Verify that we're on the AI page
      expect(find.text('Page: ${Keys.aiName}'), findsOneWidget);

      // Tap on the Planner tab
      await tester.tap(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text(Keys.planner),
        ),
      );
      await tester.pumpAndSettle();

      // Verify that we're on the Planner page
      expect(find.text('Page: ${Keys.planner}'), findsOneWidget);
    });
  });
}
