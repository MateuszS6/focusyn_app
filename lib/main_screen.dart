import 'package:flutter/material.dart';
import 'package:focusyn_app/pages/profile_page.dart';

import 'pages/focuses_page.dart';
import 'pages/home_page.dart';
import 'pages/planner_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

enum _MainScreenIndex { home, focuses, planner }

class _MainScreenState extends State<MainScreen> {
  _MainScreenIndex _selectedIndex = _MainScreenIndex.home;

  final List<Widget> _pages = <Widget>[
    HomePage(),
    FocusesPage(),
    PlannerPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = _MainScreenIndex.values[index];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: _pages.elementAt(_selectedIndex.index),
      ),
      bottomNavigationBar: _buildNavBar(),
    );
  }

  /// Builds a dynamic AppBar based on the current page.
  AppBar _buildAppBar() {
    String title;
    List<Widget> actions = [];

    switch (_selectedIndex) {
      case _MainScreenIndex.home: // Dashboard
        title = 'Dashboard';
        actions = [
          IconButton(icon: Icon(Icons.notifications_rounded), onPressed: () {}),
          IconButton(
            icon: Icon(Icons.account_circle_rounded),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfilePage()),
              );
            },
          ),
        ];
        break;
      case _MainScreenIndex.focuses: // Focuses
        title = 'Focuses';
        break;
      case _MainScreenIndex.planner: // Planner
        title = 'Planner';
        break;
    }

    return AppBar(
      title: Text(
        title,
        style: TextStyle(fontSize: 32.0, fontWeight: FontWeight.w900),
      ),
      actions: actions,
    );
  }

  /// Builds the navigation bar widget.
  BottomNavigationBar _buildNavBar() {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard_rounded),
          label: 'Dash',
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
      currentIndex: _selectedIndex.index,
      onTap: _onItemTapped,
    );
  }
}
