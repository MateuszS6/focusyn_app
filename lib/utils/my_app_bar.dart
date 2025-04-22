import 'package:flutter/material.dart';

/// A custom app bar implementation that provides consistent styling
/// and behavior across the application.
///
/// This app bar:
/// - Uses the displayLarge text style for the title
/// - Provides proper padding based on leading widget presence
/// - Removes elevation and shadow effects
/// - Maintains consistent spacing
class MyAppBar extends AppBar {
  /// Creates a custom app bar with consistent styling.
  ///
  /// [title] - The text to display in the app bar
  /// [actions] - Optional list of widgets to display after the title
  /// [leading] - Optional widget to display before the title
  /// [backgroundColor] - Optional custom background color
  /// [elevation] - The elevation of the app bar (default: 0)
  MyAppBar({
    super.key,
    required String title,
    super.actions,
    super.leading,
    super.backgroundColor,
    double super.elevation = 0,
  }) : super(
         automaticallyImplyLeading: leading != null,
         title: Builder(
           builder:
               (context) => Padding(
                 padding:
                     leading == null
                         ? const EdgeInsets.only(left: 16)
                         : const EdgeInsets.all(0),
                 child: Text(
                   title,
                   style: Theme.of(context).textTheme.displayLarge,
                 ),
               ),
         ),
         actionsPadding: const EdgeInsets.only(right: 16),
         scrolledUnderElevation: 0.0,
         titleSpacing: 8.0,
       );
}
