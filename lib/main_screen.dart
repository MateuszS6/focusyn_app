import 'package:flutter/material.dart';
import 'package:focusyn_app/pages/account_page.dart';

import 'pages/focuses_page.dart';
import 'pages/home_page.dart';
import 'pages/planner_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final Map<Widget, String> _pages = {
    HomePage(): 'Dashboard',
    FocusesPage(): 'Focuses',
    PlannerPage(): 'Planner',
  };

  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.only(left: 16, top: 16, right: 16),
        child: _pages.keys.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: _buildNavBar(),
    );
  }

  /// Builds a dynamic AppBar based on the current page.
  AppBar _buildAppBar() {
    List<Widget> actions = [];

    switch (_selectedIndex) {
      case 0: // HomePage
        actions = [
          IconButton(icon: Icon(Icons.notifications_rounded), onPressed: () {}),
          IconButton(
            icon: Icon(Icons.account_circle_rounded),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AccountPage()),
              );
            },
          ),
        ];
        break;
    }

    return AppBar(
      title: Text(
        _pages.values.elementAt(_selectedIndex),
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
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
    );
  }
}
