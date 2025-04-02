import 'package:flutter/material.dart';

class TapEffectCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color backgroundColor;
  final double borderRadius;
  final EdgeInsets margin;
  final EdgeInsets padding;
  final AlignmentGeometry? alignment;
  final double? height;

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
        child: InkResponse(
          onTap: onTap,
          containedInkWell: true,
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
