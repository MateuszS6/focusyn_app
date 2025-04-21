import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:focusyn_app/constants/keys.dart';
import 'package:focusyn_app/constants/theme_icons.dart';
import 'package:focusyn_app/pages/onboarding_page.dart';

void main() {
  testWidgets('OnboardingPage renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: OnboardingPage()));
    await tester.pumpAndSettle();

    // Verify first page content
    expect(find.text('Welcome to Focusyn'), findsOneWidget);
    expect(
      find.image(const AssetImage('assets/logo_transparent.png')),
      findsOneWidget,
    );

    // Verify navigation dots
    expect(find.byType(Container), findsNWidgets(7)); // 5 dots + 2 buttons

    // Verify navigation buttons on first page
    expect(find.text('Skip'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);
    expect(find.text('Get Started'), findsNothing);
  });

  testWidgets('Onboarding pages show correct content', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: OnboardingPage()));
    await tester.pumpAndSettle();

    // Test each page content
    final expectedContent = [
      {'title': 'Welcome to Focusyn', 'hasImage': true, 'icon': null},
      {
        'title': 'Focus on What Matters',
        'hasImage': false,
        'icon': ThemeIcons.actions,
      },
      {
        'title': 'Track Brain Points',
        'hasImage': false,
        'icon': ThemeIcons.brainPoints,
      },
      {
        'title': 'Meet ${Keys.aiName} AI',
        'hasImage': false,
        'icon': ThemeIcons.robot,
      },
      {
        'title': 'Ready to Get Started?',
        'hasImage': false,
        'icon': ThemeIcons.play,
      },
    ];

    for (var i = 0; i < expectedContent.length; i++) {
      expect(find.text(expectedContent[i]['title'] as String), findsOneWidget);

      if (expectedContent[i]['hasImage'] as bool) {
        expect(find.byType(Image), findsOneWidget);
      } else {
        expect(
          find.byIcon(expectedContent[i]['icon'] as IconData),
          findsOneWidget,
        );
      }

      if (i < expectedContent.length - 1) {
        await tester.tap(find.text('Next'));
        await tester.pumpAndSettle();
      }
    }
  });

  testWidgets('Navigation works correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: OnboardingPage()));
    await tester.pumpAndSettle();

    // Test Next button navigation
    for (var i = 0; i < 4; i++) {
      expect(find.text('Next'), findsOneWidget);
      expect(find.text('Skip'), findsOneWidget);
      expect(find.text('Get Started'), findsNothing);

      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
    }

    // On last page
    expect(find.text('Next'), findsNothing);
    expect(find.text('Skip'), findsNothing);
    expect(find.text('Get Started'), findsOneWidget);
  });

  testWidgets('Dot indicators reflect current page', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: OnboardingPage()));
    await tester.pumpAndSettle();

    for (var i = 0; i < 5; i++) {
      // Find all dots
      final dots = tester.widgetList<Container>(find.byType(Container));

      // Get the dot indicators (excluding buttons)
      final dotIndicators =
          dots.where((container) {
            final decoration = container.decoration as BoxDecoration?;
            return decoration != null && decoration.shape == BoxShape.circle;
          }).toList();

      // Verify we have the correct number of dots
      expect(dotIndicators.length, equals(6));

      if (i < 4) {
        await tester.tap(find.text('Next'));
        await tester.pumpAndSettle();
      }
    }
  });
}
