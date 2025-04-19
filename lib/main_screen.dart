import 'package:flutter/material.dart';
import 'package:focusyn_app/constants/theme_icons.dart';
import 'package:focusyn_app/pages/focuses_page.dart';
import 'package:focusyn_app/pages/today_page.dart';
import 'package:focusyn_app/pages/planner_page.dart';
import 'package:focusyn_app/pages/ai_page.dart';
import 'package:focusyn_app/services/cloud_sync_service.dart';
import 'package:focusyn_app/constants/keys.dart';
import 'package:hive/hive.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  bool _isSyncing = false;

  static const List<Widget> _pages = [
    TodayPage(),
    FocusesPage(),
    AiPage(),
    PlannerPage(),
  ];

  @override
  void initState() {
    super.initState();
    _syncData();
  }

  Future<void> _syncData() async {
    if (_isSyncing) return;
    setState(() => _isSyncing = true);

    try {
      final taskBox = Hive.box(Keys.taskBox);
      final filterBox = Hive.box(Keys.filterBox);
      final brainBox = Hive.box(Keys.brainBox);
      final historyBox = Hive.box(Keys.historyBox);

      if (!taskBox.isOpen ||
          !filterBox.isOpen ||
          !brainBox.isOpen ||
          !historyBox.isOpen) {
        throw Exception('One or more Hive boxes are not open');
      }

      await CloudSyncService.syncOnLogin(
        taskBox,
        filterBox,
        brainBox,
        historyBox,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sync failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSyncing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          _pages[_selectedIndex],
          if (_isSyncing)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue[300],
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(26),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Syncing...',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        height: 72,
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        indicatorColor: Colors.blue.withAlpha(26),
        selectedIndex: _selectedIndex,
        onDestinationSelected:
            (index) => setState(() => _selectedIndex = index),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const [
          NavigationDestination(
            icon: Icon(ThemeIcons.today),
            label: Keys.today,
          ),
          NavigationDestination(
            icon: Icon(ThemeIcons.focuses),
            label: Keys.focuses,
          ),
          NavigationDestination(icon: Icon(ThemeIcons.ai), label: Keys.aiName),
          NavigationDestination(
            icon: Icon(ThemeIcons.planner),
            label: Keys.planner,
          ),
        ],
      ),
    );
  }
}
