import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:focusyn_app/constants/keys.dart';
import 'package:focusyn_app/services/setting_service.dart';
import 'package:hive/hive.dart';

/// A service class for managing cloud synchronization of app data.
/// This service provides:
/// - Firebase integration for data persistence
/// - Methods for uploading and downloading app data
/// - User profile management
/// - Data cleanup and reset functionality
class CloudService {
  /// Firebase Auth instance for user authentication
  static final _auth = FirebaseAuth.instance;

  /// Firebase Firestore instance for data storage
  static final _firestore = FirebaseFirestore.instance;

  static final _taskBox = Hive.box<List>(Keys.taskBox);
  static final _filterBox = Hive.box(Keys.filterBox);
  static final _brainBox = Hive.box(Keys.brainBox);
  static final _historyBox = Hive.box(Keys.historyBox);
  static final _settingBox = Hive.box(Keys.settingBox);

  static final _userTasksRoot = _firestore.collection('user_tasks');
  static final _userFiltersRoot = _firestore.collection('user_filters');
  static final _userBrainPointsRoot = _firestore.collection('user_points');
  static final _userHistoryRoot = _firestore.collection('user_history');
  static final _userSettingsRoot = _firestore.collection('user_settings');

  /// Ensures user documents exist in Firestore.
  /// This method:
  /// - Creates user data document if missing
  /// - Creates profile document if missing
  /// - Initializes brain points with default values
  ///
  /// Throws an exception if:
  /// - No user is authenticated
  /// - Document creation fails
  static Future<void> _ensureUserDocument() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No user found in _ensureUserDocument');
    }

    // Initialize Firestore references for user data
    final profileRef = _firestore.collection('profiles').doc(user.uid);
    final userTasksRef = _firestore.collection('user_tasks').doc(user.uid);
    final userFiltersRef = _firestore.collection('user_filters').doc(user.uid);
    final userPointsRef = _firestore.collection('user_points').doc(user.uid);
    final userHistoryRef = _firestore.collection('user_history').doc(user.uid);
    final userSettingsRef = _firestore
        .collection('user_settings')
        .doc(user.uid);

    try {
      // Check if user documents exist
      final profileDoc = await profileRef.get();
      final userTasksDoc = await userTasksRef.get();
      final userFiltersDoc = await userFiltersRef.get();
      final userPointsDoc = await userPointsRef.get();
      final userHistoryDoc = await userHistoryRef.get();
      final userSettingsDoc = await userSettingsRef.get();

      // Create initial profile if it doesn't exist
      if (!profileDoc.exists) {
        await profileRef.set({
          'displayName': user.displayName ?? '',
          'email': user.email ?? '',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      // Create initial user data if it doesn't exist
      if (!userTasksDoc.exists) {
        await userTasksRef.set({'createdAt': FieldValue.serverTimestamp()});
      }

      // Create initial filters if it doesn't exist
      if (!userFiltersDoc.exists) {
        await userFiltersRef.set({'createdAt': FieldValue.serverTimestamp()});
      }

      // Create initial brain points if it doesn't exist
      if (!userPointsDoc.exists) {
        await userPointsRef.set({
          Keys.brainPoints: 100,
          'lastReset': DateTime.now().toIso8601String(),
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      // Create initial history if it doesn't exist
      if (!userHistoryDoc.exists) {
        await userHistoryRef.set({'createdAt': FieldValue.serverTimestamp()});
      }

      // Create initial settings if it doesn't exist
      if (!userSettingsDoc.exists) {
        await userSettingsRef.set({
          Keys.general: SettingService.getGeneralSettings(),
          Keys.notifications: SettingService.getNotificationSettings(),
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Uploads task data to Firestore.
  /// This method:
  /// - Uploads tasks for all categories (actions, flows, moments, thoughts)
  /// - Uses batch operations for atomic updates
  ///
  /// [taskBox] - Hive box containing task data
  ///
  /// Throws an exception if:
  /// - No user is authenticated
  /// - Upload fails
  static Future<void> uploadTasks() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No user found in uploadTasks');
    }

    final userTasksRef = _userTasksRoot.doc(user.uid);
    final batch = _firestore.batch();

    try {
      // Upload tasks for each category in a single batch operation
      for (final category in [
        Keys.actions,
        Keys.flows,
        Keys.moments,
        Keys.thoughts,
      ]) {
        final tasks = _taskBox.get(category) ?? [];
        batch.set(userTasksRef, {category: tasks});
      }

      await batch.commit();
    } catch (e) {
      rethrow;
    }
  }

  /// Uploads filter data to Firestore.
  /// This method:
  /// - Uploads filters for all categories
  /// - Uses batch operations for atomic updates
  ///
  /// Throws an exception if:
  /// - No user is authenticated
  /// - Upload fails
  static Future<void> uploadFilters() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No user found in uploadFilters');
    }

    final userFiltersRef = _userFiltersRoot.doc(user.uid);
    final batch = _firestore.batch();

    try {
      // Upload filters for each category in a single batch operation
      for (final category in [
        Keys.actions,
        Keys.flows,
        Keys.moments,
        Keys.thoughts,
      ]) {
        final filters = _filterBox.get(category) as List<dynamic>? ?? [];
        batch.set(userFiltersRef, {category: filters});
      }

      await batch.commit();
    } catch (e) {
      rethrow;
    }
  }

  /// Uploads brain points data to Firestore.
  /// This method:
  /// - Uploads current points value
  /// - Uploads last reset timestamp
  ///
  /// Throws an exception if:
  /// - No user is authenticated
  /// - Upload fails
  static Future<void> uploadBrainPoints() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No user found in uploadBrainPoints');
    }

    final brainPointsRef = _userBrainPointsRoot.doc(user.uid);

    try {
      // Get current brain points data
      final brainPoints = _brainBox.get(Keys.brainPoints) ?? 100;
      final lastReset =
          _brainBox.get('lastReset') ?? DateTime.now().toIso8601String();

      // Update brain points in Firestore
      await brainPointsRef.set({
        'brainPoints': brainPoints,
        'lastReset': lastReset,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }

  /// Uploads flow history data to Firestore.
  /// This method:
  /// - Uploads list of flow completion dates
  /// - Updates the last modification timestamp
  ///
  /// Throws an exception if:
  /// - No user is authenticated
  /// - Upload fails
  static Future<void> uploadFlowHistory() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No user found in uploadFlowHistory');
    }

    final historyRef = _userHistoryRoot.doc(user.uid);

    try {
      // Get current flow history
      final history = _historyBox.get('flow_history') as List<dynamic>? ?? [];

      // Update flow history in Firestore
      await historyRef.set({
        'flows': history,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> uploadSettings() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No user found in uploadSettings');
    }

    final settingsRef = _userSettingsRoot.doc(user.uid);

    try {
      // Get current settings using SettingService
      final general = SettingService.getGeneralSettings();
      final notis = SettingService.getNotificationSettings();


      // Update settings in Firestore
      await settingsRef.set({
        Keys.general: general,
        Keys.notifications: notis,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      rethrow;
    }
  }

  /// Downloads all user data from Firestore.
  /// This method:
  /// - Downloads tasks for all categories
  /// - Downloads filters for all categories
  /// - Downloads brain points data
  /// - Handles daily reset of brain points
  ///
  /// Throws an exception if:
  /// - No user is authenticated
  /// - Download fails
  static Future<void> downloadTasks() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No user found in downloadTasks');
    }

    try {
      await _ensureUserDocument();
      final userTasksRef = _userTasksRoot.doc(user.uid);
      final userFiltersRef = _userFiltersRoot.doc(user.uid);
      final userBrainPointsRef = _userBrainPointsRoot.doc(user.uid);

      // Download and update brain points
      final brainPointsDoc = await userBrainPointsRef.get();

      if (brainPointsDoc.exists) {
        final data = brainPointsDoc.data();
        if (data != null) {
          final cloudPoints = data[Keys.brainPoints] as int? ?? 100;
          final cloudLastReset =
              data['lastReset'] as String? ?? DateTime.now().toIso8601String();

          final lastResetDate = DateTime.parse(cloudLastReset);
          final now = DateTime.now();

          // Reset points if it's a new day
          if (now.year > lastResetDate.year ||
              now.month > lastResetDate.month ||
              now.day > lastResetDate.day) {
            await _brainBox.put(Keys.brainPoints, 100);
            await _brainBox.put('lastReset', now.toIso8601String());

            // Update cloud data to reflect reset
            await userBrainPointsRef.set({
              Keys.brainPoints: 100,
              'lastReset': now.toIso8601String(),
              'updatedAt': FieldValue.serverTimestamp(),
            });
          } else {
            await _brainBox.put(Keys.brainPoints, cloudPoints);
            await _brainBox.put('lastReset', cloudLastReset);
          }
        }
      }

      // Download tasks for each category
      for (final category in [
        Keys.actions,
        Keys.flows,
        Keys.moments,
        Keys.thoughts,
      ]) {
        final tasksDoc =
            await userTasksRef.get();
        if (tasksDoc.exists) {
          final data = tasksDoc.data();
          if (data != null && data[category] != null) {
            final localTasks = _taskBox.get(category) ?? [];

            // Only update if cloud data exists or local data is empty
            if (data[category].isNotEmpty || localTasks.isEmpty) {
              await _taskBox.put(category, data[category]);
            }
          }
        }
      }

      // Download filters for each category
      for (final category in [
        Keys.actions,
        Keys.flows,
        Keys.moments,
        Keys.thoughts,
      ]) {
        final filtersDoc =
            await userFiltersRef.get();
        if (filtersDoc.exists) {
          final data = filtersDoc.data();
          if (data != null && data[category] != null) {
            final localFilters =
                _filterBox.get(category) as List<dynamic>? ?? [];

            // Only update if cloud data exists or local data is empty
            if (data[category].isNotEmpty || localFilters.isEmpty) {
              await _filterBox.put(category, data[category]);
            }
          }
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Downloads flow history data from Firestore.
  /// This method:
  /// - Downloads list of flow completion dates
  /// - Preserves local data if it exists and cloud data is empty
  ///
  /// Throws an exception if:
  /// - No user is authenticated
  /// - Download fails
  static Future<void> downloadFlowHistory() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No user found in downloadFlowHistory');
    }

    final historyRef = _userHistoryRoot.doc(user.uid);

    try {
      final historyDoc = await historyRef.get();
      if (historyDoc.exists) {
        final data = historyDoc.data();
        if (data != null && data['flows'] != null) {
          final localHistory =
              _historyBox.get('flow_history') as List<dynamic>? ?? [];

          // Only update if cloud data exists or local data is empty
          if (data['flows'].isNotEmpty || localHistory.isEmpty) {
            await _historyBox.put('flow_history', data['flows']);
          } else {
            throw Exception(
              'DEBUG: Preserving local flow history (${localHistory.length} items)',
            );
          }
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> downloadSettings() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No user found in downloadSettings');
    }

    final settingsRef = _userSettingsRoot.doc(user.uid);

    try {
      final settingsDoc = await settingsRef.get();
      if (settingsDoc.exists) {
        final data = settingsDoc.data();
        if (data != null && data[Keys.general] != null && 
            data[Keys.notifications] != null) {
          // Update settings using SettingService
          await SettingService.updateAllSettings(
            Map<String, dynamic>.from(data[Keys.general]),
            Map<String, dynamic>.from(data[Keys.notifications]),
          );
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Performs initial synchronization on user login.
  /// This method:
  /// - For new users: uploads all local data
  /// - For existing users: downloads cloud data, then uploads local changes
  ///
  /// Throws an exception if:
  /// - No user is authenticated
  /// - Synchronization fails
  static Future<void> syncOnLogin() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No user found in syncOnLogin');
      }

      final profileRef = _firestore.collection('profiles').doc(user.uid);
      final profileDoc = await profileRef.get();
      final isNewUser = !profileDoc.exists;

      if (isNewUser) {
        await _ensureUserDocument();
        await uploadTasks();
        await uploadFilters();
        await uploadBrainPoints();
        await uploadFlowHistory();
        await uploadSettings();
      } else {
        await downloadTasks();
        await downloadFlowHistory();
        await downloadSettings();
        await uploadTasks();
        await uploadFilters();
        await uploadBrainPoints();
        await uploadFlowHistory();
        await uploadSettings();
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Clears all local data.
  /// This method:
  /// - Clears tasks and filters for all categories
  /// - Resets brain points to default value
  /// - Clears flow history
  /// - Clears settings
  ///
  /// Throws an exception if clearing fails
  static Future<void> clearLocalData() async {
    try {
      // Clear all task categories
      await _taskBox.clear();
      await _filterBox.clear();

      // Reset brain points
      await _brainBox.clear();

      // Clear flow history
      await _historyBox.clear();

      // Clear settings
      await _settingBox.clear();
    } catch (e) {
      rethrow;
    }
  }

  /// Deletes all user data from Firestore and local storage.
  /// This method:
  /// - Deletes all subcollections (brainPoints, tasks, filters, history)
  /// - Deletes user document and profile
  /// - Clears all local data
  ///
  /// Throws an exception if:
  /// - No user is authenticated
  /// - Deletion fails
  static Future<void> deleteUserData() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No user found in deleteUserData');
      }

      final profileRef = _firestore.collection('profiles').doc(user.uid);

      // Delete user data from root collections
      final userTasksRef = _userTasksRoot.doc(user.uid);
      final userFiltersRef = _userFiltersRoot.doc(user.uid);
      final userPointsRef = _userBrainPointsRoot.doc(user.uid);
      final userHistoryRef = _userHistoryRoot.doc(user.uid);
      final userSettingsRef = _userSettingsRoot.doc(user.uid);

      // Delete all category subcollections
      for (final category in [
        Keys.actions,
        Keys.flows,
        Keys.moments,
        Keys.thoughts,
      ]) {
        await _deleteCollection(userTasksRef.collection(category));
        await _deleteCollection(userFiltersRef.collection(category));
      }

      // Delete user documents from root collections
      await Future.wait([
        userTasksRef.delete(),
        userFiltersRef.delete(),
        userPointsRef.delete(),
        userHistoryRef.delete(),
        userSettingsRef.delete(),
        profileRef.delete(),
      ]);

      // Clear local data
      await clearLocalData();
    } catch (e) {
      rethrow;
    }
  }

  /// Updates user profile information in Firestore.
  /// This method:
  /// - Updates display name
  /// - Optionally updates email address
  /// - Updates modification timestamp
  ///
  /// [displayName] - New display name for the user
  /// [newEmail] - Optional new email address
  ///
  /// Throws an exception if:
  /// - No user is authenticated
  /// - Update fails
  static Future<void> updateUserProfile(
    String displayName, {
    String? newEmail,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No user found in updateUserProfile');
    }

    final profileRef = _firestore.collection('profiles').doc(user.uid);

    try {
      // Update profile with merge option to preserve existing fields
      await profileRef.set({
        'displayName': displayName,
        'email': newEmail ?? user.email,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      rethrow;
    }
  }

  /// Clears all app data in Firestore.
  /// This method:
  /// - Resets brain points to default value
  /// - Clears all tasks
  /// - Clears all filters
  /// - Clears flow history
  ///
  /// Throws an exception if:
  /// - No user is authenticated
  /// - Clearing fails
  static Future<void> clearAppData() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No user found in clearAppData');
    }

    try {
      // Get references to user's root documents
      final userTasksRef = _userTasksRoot.doc(user.uid);
      final userFiltersRef = _userFiltersRoot.doc(user.uid);
      final userPointsRef = _userBrainPointsRoot.doc(user.uid);
      final userHistoryRef = _userHistoryRoot.doc(user.uid);
      final userSettingsRef = _userSettingsRoot.doc(user.uid);

      // Clear tasks and filters for each category
      for (final category in [
        Keys.actions,
        Keys.flows,
        Keys.moments,
        Keys.thoughts,
      ]) {
        await userTasksRef.set({category: []});
        await userFiltersRef.set({category: []});
      }

      // Reset brain points
      await userPointsRef.set({
        Keys.brainPoints: 100,
        'lastReset': DateTime.now().toIso8601String(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Clear flow history
      await userHistoryRef.set({
        'flows': [],
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Reset settings to defaults
      await userSettingsRef.set({
        Keys.general: SettingService.getGeneralSettings(),
        Keys.notifications: SettingService.getNotificationSettings(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      rethrow;
    }
  }

  /// Deletes all documents in a Firestore collection.
  /// This method:
  /// - Retrieves all documents in the collection
  /// - Deletes each document
  ///
  /// [collectionRef] - Reference to the collection to delete
  ///
  /// Throws an exception if deletion fails
  static Future<void> _deleteCollection(
    CollectionReference collectionRef,
  ) async {
    final snapshot = await collectionRef.get();
    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }
}
