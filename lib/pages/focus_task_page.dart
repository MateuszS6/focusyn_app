import 'package:flutter/material.dart';

class FocusTaskPage extends StatefulWidget {
  final String category;
  final List<Map<String, dynamic>> initialTasks;

  const FocusTaskPage({
    super.key,
    required this.category,
    required this.initialTasks,
  });

  @override
  State<FocusTaskPage> createState() => _FocusTaskPageState();
}
