import 'package:flutter/material.dart';

import 'pages/focuses_page.dart';
import 'pages/home_page.dart';
import 'pages/schedule_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = <Widget>[
    HomePage(),
    FocusesPage(),
    SchedulePage(),
  ];

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
      body: _pages.elementAt(_selectedIndex),
      bottomNavigationBar: _buildNavBar(),
    );
  }

  /// Builds a dynamic AppBar based on the current page.
  AppBar _buildAppBar() {
    String title;
    List<Widget> actions = [];

    switch (_selectedIndex) {
      case 0: // Home (Dashboard)
        title = 'Home';
        actions = [
          IconButton(
            icon: Icon(Icons.notifications_rounded),
            onPressed: () {
              // Implement notifications functionality here
            },
          ),
          IconButton(
            icon: Icon(Icons.account_circle_rounded),
            onPressed: () {
              // Implement profile functionality here
            },
          )
        ];
        break;
      case 1: // Focuses
        title = 'Focuses';
        actions = [
          IconButton(
            icon: Icon(Icons.add_circle_rounded),
            onPressed: () {
              // Implement add new focus functionality here
            },
          )
        ];
        break;
      case 2:
        title = 'Schedule';
        break;
      default:
        title = 'Focusyn [Alpha]';
    }

    return AppBar(
      title: Text(
        title,
        style: TextStyle(
          fontSize: 32.0,
          fontWeight: FontWeight.w900,
        ),
      ),
      actions: actions,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
    );
  }

  /// Builds the navigation bar widget.
  BottomNavigationBar _buildNavBar() {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home_rounded),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.category_rounded),
          label: 'Focuses',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.today_rounded),
          label: 'Schedule',
        ),
      ],
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      backgroundColor: Colors.white,
    );
  }

  // Search bar widget
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: TextField(
        onChanged: (value) {
          // Implement search functionality here
        },
        decoration: InputDecoration(
          hintText: 'Search...',
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey[200],
          contentPadding: const EdgeInsets.symmetric(vertical: 0.0),
        ),
      ),
    );
  }
}
