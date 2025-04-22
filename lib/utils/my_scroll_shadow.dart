import 'package:flutter/material.dart';
import 'package:flutter_scroll_shadow/flutter_scroll_shadow.dart';

/// A custom scroll shadow widget that provides a visual indication of scrollable content.
/// This widget wraps the ScrollShadow package to provide a consistent shadow effect
/// across the application.
class MyScrollShadow extends StatelessWidget {
  /// Creates a scroll shadow widget.
  ///
  /// [child] - The widget to be wrapped with the scroll shadow
  /// [size] - The size of the shadow effect (default: 10)
  /// [color] - Optional custom color for the shadow. If not provided,
  ///           uses a semi-transparent grey color
  const MyScrollShadow({
    super.key,
    required this.child,
    this.size = 10,
    this.color,
  });

  /// The widget to be wrapped with the scroll shadow
  final Widget child;

  /// The size of the shadow effect
  final double size;

  /// Optional custom color for the shadow
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return ScrollShadow(
      size: size,
      color: color ?? Colors.grey.shade300.withAlpha(120),
      child: child,
    );
  }
}
