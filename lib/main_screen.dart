import 'package:flutter/material.dart';

import 'pages/focuses_page.dart';
import 'pages/hub_page.dart';
import 'pages/planner_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final Set<StatefulWidget> _pages = {HubPage(), FocusesPage(), PlannerPage()};

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
          icon: Icon(Icons.dashboard_rounded),
          label: 'Hub',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.view_agenda_rounded),
          label: 'Focuses',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.local_library_rounded),
          label: 'Planner',
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
