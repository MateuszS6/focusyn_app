import 'package:flutter/material.dart';
import 'package:flutter_scroll_shadow/flutter_scroll_shadow.dart';

class MyScrollShadow extends StatelessWidget {
  const MyScrollShadow({
    super.key,
    required this.child,
    this.size = 10,
    this.color,
  });

  final Widget child;
  final double size;
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
