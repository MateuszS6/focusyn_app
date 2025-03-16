import 'package:flutter/material.dart';

class PageWrapper extends StatelessWidget {
  final Widget child;

  const PageWrapper({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: child,
        ),
      ),
    );
  }
}