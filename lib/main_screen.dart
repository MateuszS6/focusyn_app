import 'package:flutter/material.dart';
import 'package:focusyn_app/data/keys.dart';
import 'package:focusyn_app/pages/focuses_page.dart';
import 'package:focusyn_app/pages/home_page.dart';
import 'package:focusyn_app/pages/planner_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = [HomePage(), FocusesPage(), PlannerPage()];

  static const List<BottomNavigationBarItem> _navItems = [
    BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: Keys.home),
    BottomNavigationBarItem(
      icon: Icon(Icons.view_agenda_rounded),
      label: Keys.focuses,
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.local_library_rounded),
      label: Keys.planner,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: _navItems,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}
