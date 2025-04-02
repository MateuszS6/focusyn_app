import 'package:flutter/material.dart';
import 'package:focusyn_app/data/keys.dart';

import 'pages/focuses_page.dart';
import 'pages/home_page.dart';
import 'pages/planner_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final Set<StatefulWidget> _pages = {HomePage(), FocusesPage(), PlannerPage()};

  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _pages.elementAt(_selectedIndex),
      bottomNavigationBar: _buildNavBar(),
    );
  }

  /// Builds the navigation bar widget.
  BottomNavigationBar _buildNavBar() {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home_rounded),
          label: Keys.home,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.view_agenda_rounded),
          label: Keys.focuses,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.local_library_rounded),
          label: Keys.planner,
        ),
      ],
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}
