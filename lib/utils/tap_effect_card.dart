import 'package:flutter/material.dart';

/// A custom card widget that provides a tap effect and consistent styling.
/// This widget combines Material and InkWell to create a card with:
/// - Tap feedback effect
/// - Customizable background color
/// - Rounded corners
/// - Flexible padding and margin
/// - Optional height constraint
class TapEffectCard extends StatelessWidget {
  /// The child widget to be displayed inside the card
  final Widget child;

  /// Optional callback function when the card is tapped
  final VoidCallback? onTap;

  /// The background color of the card (default: light grey)
  final Color backgroundColor;

  /// The border radius of the card corners (default: 20)
  final double borderRadius;

  /// The margin around the card (default: zero)
  final EdgeInsets margin;

  /// The padding inside the card (default: zero)
  final EdgeInsets padding;

  /// The alignment of the child widget (default: center)
  final AlignmentGeometry? alignment;

  /// Optional fixed height for the card
  final double? height;

  /// Creates a tap effect card with customizable properties.
  ///
  /// [child] - Required widget to display inside the card
  /// [onTap] - Optional callback for tap events
  /// [backgroundColor] - Card background color (default: light grey)
  /// [borderRadius] - Corner radius (default: 20)
  /// [margin] - Outer spacing (default: zero)
  /// [padding] - Inner spacing (default: zero)
  /// [alignment] - Child alignment (default: center)
  /// [height] - Optional fixed height
  const TapEffectCard({
    super.key,
    required this.child,
    this.onTap,
    this.backgroundColor = const Color(0xFFF5F5F5),
    this.borderRadius = 20,
    this.margin = EdgeInsets.zero,
    this.padding = EdgeInsets.zero,
    this.alignment = Alignment.center,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin,
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Container(
            alignment: alignment,
            height: height,
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}
