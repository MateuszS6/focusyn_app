import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../mocks/mock_focuses_page.dart';
import 'package:focusyn_app/constants/keys.dart';
import 'package:focusyn_app/constants/theme_colours.dart';

void main() {
  group('FocusesPage UI Tests', () {
    testWidgets('FocusesPage shows all focus categories', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: MockFocusesPage()));

      // Verify that all focus categories are present
      expect(find.text(Keys.actions), findsOneWidget);
      expect(find.text(Keys.flows), findsOneWidget);
      expect(find.text(Keys.moments), findsOneWidget);
      expect(find.text(Keys.thoughts), findsOneWidget);
    });

    testWidgets('FocusesPage shows correct category descriptions', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: MockFocusesPage()));

      // Verify that category descriptions are present
      expect(find.text('Your unscheduled to-do list'), findsOneWidget);
      expect(find.text('Your routines and habits'), findsOneWidget);
      expect(find.text('Your events and deadlines'), findsOneWidget);
      expect(find.text('Your reflections for later'), findsOneWidget);
    });

    testWidgets('FocusesPage shows correct category colors', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: MockFocusesPage()));

      // Verify that each category has the correct color
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Material && widget.color == ThemeColours.actionsMain,
        ),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Material && widget.color == ThemeColours.flowsMain,
        ),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Material && widget.color == ThemeColours.momentsMain,
        ),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Material && widget.color == ThemeColours.thoughtsMain,
        ),
        findsOneWidget,
      );
    });

    testWidgets('FocusesPage cards are tappable', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: MockFocusesPage()));

      // Test that each category card is tappable
      await tester.tap(find.text(Keys.actions));
      await tester.pumpAndSettle();

      await tester.tap(find.text(Keys.flows));
      await tester.pumpAndSettle();

      await tester.tap(find.text(Keys.moments));
      await tester.pumpAndSettle();

      await tester.tap(find.text(Keys.thoughts));
      await tester.pumpAndSettle();
    });
  });
}
