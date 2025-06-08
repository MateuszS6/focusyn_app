import 'package:flutter/material.dart';
import 'package:focusyn_app/constants/theme_icons.dart';
import 'package:focusyn_app/pages/focuses_page.dart';
import 'package:focusyn_app/pages/dashboard.dart';
import 'package:focusyn_app/pages/planner_page.dart';
import 'package:focusyn_app/pages/ai_page.dart';
import 'package:focusyn_app/services/cloud_service.dart';
import 'package:focusyn_app/constants/keys.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// The main screen of the application that serves as the root container.
///
/// This screen provides:
/// - Bottom navigation for switching between main sections
/// - Cloud synchronization status indicator
/// - Container for displaying the current page
///
/// The main sections are:
/// 1. Today - Daily tasks and progress
/// 2. Focuses - Focus session management
/// 3. AI - AI-powered assistance
/// 4. Planner - Task planning and organization
///
/// The screen handles:
/// - Navigation state management
/// - Cloud synchronization
/// - UI updates and transitions
/// - Error handling for sync operations
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

/// The state class for [MainScreen].
///
/// This class manages:
/// - Current navigation index
/// - Cloud synchronization state
/// - Page transitions
/// - Error handling
///
/// It provides methods for:
/// - Initializing cloud sync
/// - Handling navigation changes
/// - Managing sync status display
///
/// The state is updated in response to:
/// - Navigation changes
/// - Sync completion
/// - Error conditions
class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0; // Current navigation index
  bool _isSyncing = false; // Sync operation status

  /// List of main application pages in navigation order.
  static const List<Widget> _pages = [
    TodayPage(),
    FocusesPage(),
    AIPage(),
    PlannerPage(),
  ];

  @override
  void initState() {
    super.initState();
    // Schedule initial sync after widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncData();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  /// Performs cloud synchronization of local data.
  ///
  /// This method:
  /// 1. Checks if sync is already in progress
  /// 2. Verifies Hive boxes are open
  /// 3. Calls CloudSyncService to sync data
  /// 4. Handles success and error cases
  /// 5. Updates sync status UI
  ///
  /// Error handling:
  /// - Shows error message if boxes aren't open
  /// - Displays sync failure notification
  /// - Ensures sync status is reset
  Future<void> _syncData() async {
    if (_isSyncing || !mounted) return;
    setState(() => _isSyncing = true);

    try {
      // Get references to all required Hive boxes
      final taskBox = Hive.box<List>(Keys.taskBox);
      final filterBox = Hive.box(Keys.filterBox);
      final brainBox = Hive.box(Keys.brainBox);
      final historyBox = Hive.box(Keys.historyBox);
      final settingBox = Hive.box(Keys.settingBox);

      // Verify all boxes are open
      if (!taskBox.isOpen ||
          !filterBox.isOpen ||
          !brainBox.isOpen ||
          !historyBox.isOpen ||
          !settingBox.isOpen) {
        throw Exception('One or more Hive boxes are not open');
      }

      // Perform cloud synchronization
      await CloudService.syncOnLogin(
        taskBox,
        filterBox,
        brainBox,
        historyBox,
        settingBox,
      );
    } catch (e) {
      if (!mounted) return;
      // Show error message
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

  /// Builds the main application screen.
  ///
  /// This method constructs:
  /// 1. Main content area with current page
  /// 2. Sync status indicator (when active)
  /// 3. Bottom navigation bar with:
  ///    - Custom styling
  ///    - Dynamic label behavior
  ///    - Navigation icons
  ///
  /// The layout features:
  /// - Clean white background
  /// - Stack layout for overlays
  /// - Responsive navigation
  /// - Visual feedback for sync status
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Main content area
          _pages[_selectedIndex],

          // Sync status indicator
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
      // Bottom navigation bar with dynamic label behavior
      bottomNavigationBar: ValueListenableBuilder(
        valueListenable: Hive.box(Keys.settingBox).listenable(),
        builder: (context, box, _) {
          // Get navigation label behavior from settings
          final labelBehavior = NavigationDestinationLabelBehavior.values
              .byName(
                box.get(
                  Keys.navigationBarTextBehaviour,
                  defaultValue:
                      NavigationDestinationLabelBehavior.alwaysShow.name,
                ),
              );
          return NavigationBar(
            height: 72,
            elevation: 0,
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            indicatorColor: Colors.blue.withAlpha(26),
            selectedIndex: _selectedIndex,
            onDestinationSelected:
                (index) => setState(() => _selectedIndex = index),
            labelBehavior: labelBehavior,
            destinations: const [
              NavigationDestination(
                icon: Icon(ThemeIcons.today),
                label: Keys.today,
              ),
              NavigationDestination(
                icon: Icon(ThemeIcons.focuses),
                label: Keys.focuses,
              ),
              NavigationDestination(
                icon: Icon(ThemeIcons.ai),
                label: Keys.aiName,
              ),
              NavigationDestination(
                icon: Icon(ThemeIcons.planner),
                label: Keys.planner,
              ),
            ],
          );
        },
      ),
    );
  }
}
