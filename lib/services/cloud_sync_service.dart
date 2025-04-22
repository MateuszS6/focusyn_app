import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:focusyn_app/constants/keys.dart';
import 'package:hive/hive.dart';

/// A service class for managing cloud synchronization of app data.
/// This service provides:
/// - Firebase integration for data persistence
/// - Methods for uploading and downloading app data
/// - User profile management
/// - Data cleanup and reset functionality
class CloudSyncService {
  /// Firebase Auth instance for user authentication
  static final _auth = FirebaseAuth.instance;

  /// Firebase Firestore instance for data storage
  static final _firestore = FirebaseFirestore.instance;

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
    final userDataRef = _firestore.collection('user_data').doc(user.uid);
    final profileRef = _firestore.collection('profiles').doc(user.uid);
    final brainPointsRef = userDataRef.collection('brainPoints').doc('current');

    try {
      // Check if user documents exist
      final userDataDoc = await userDataRef.get();
      final profileDoc = await profileRef.get();

      // Create initial user data if it doesn't exist
      if (!userDataDoc.exists) {
        await userDataRef.set({'createdAt': FieldValue.serverTimestamp()});
        await brainPointsRef.set({
          'points': 100,
          'lastReset': DateTime.now().toIso8601String(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      // Create initial profile if it doesn't exist
      if (!profileDoc.exists) {
        await profileRef.set({
          'displayName': user.displayName ?? '',
          'email': user.email ?? '',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
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
  static Future<void> uploadTasks(Box<List> taskBox) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No user found in uploadTasks');
    }

    final userDataRef = _firestore.collection('user_data').doc(user.uid);
    final batch = _firestore.batch();

    try {
      // Upload tasks for each category in a single batch operation
      for (final category in [
        Keys.actions,
        Keys.flows,
        Keys.moments,
        Keys.thoughts,
      ]) {
        final tasks = taskBox.get(category) ?? [];
        final tasksRef = userDataRef.collection('tasks').doc(category);
        batch.set(tasksRef, {'items': tasks});
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
  /// [filterBox] - Hive box containing filter data
  ///
  /// Throws an exception if:
  /// - No user is authenticated
  /// - Upload fails
  static Future<void> uploadFilters(Box<dynamic> filterBox) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No user found in uploadFilters');
    }

    final userDataRef = _firestore.collection('user_data').doc(user.uid);
    final batch = _firestore.batch();

    try {
      // Upload filters for each category in a single batch operation
      for (final category in [
        Keys.actions,
        Keys.flows,
        Keys.moments,
        Keys.thoughts,
      ]) {
        final filters = filterBox.get(category) as List<dynamic>? ?? [];
        final filtersRef = userDataRef.collection('filters').doc(category);
        batch.set(filtersRef, {'items': filters});
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
  /// [brainBox] - Hive box containing brain points data
  ///
  /// Throws an exception if:
  /// - No user is authenticated
  /// - Upload fails
  static Future<void> uploadBrainPoints(Box<dynamic> brainBox) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No user found in uploadBrainPoints');
    }

    final brainPointsRef = _firestore
        .collection('user_data')
        .doc(user.uid)
        .collection('brainPoints')
        .doc('current');

    try {
      // Get current brain points data
      final brainPoints = brainBox.get(Keys.brainPoints) ?? 100;
      final lastReset =
          brainBox.get('lastReset') ?? DateTime.now().toIso8601String();

      // Update brain points in Firestore
      await brainPointsRef.set({
        'points': brainPoints,
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
  /// [historyBox] - Hive box containing flow history data
  ///
  /// Throws an exception if:
  /// - No user is authenticated
  /// - Upload fails
  static Future<void> uploadFlowHistory(Box<dynamic> historyBox) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No user found in uploadFlowHistory');
    }

    final historyRef = _firestore
        .collection('user_data')
        .doc(user.uid)
        .collection('history')
        .doc('flow');

    try {
      // Get current flow history
      final history = historyBox.get('flow_history') as List<dynamic>? ?? [];

      // Update flow history in Firestore
      await historyRef.set({
        'items': history,
        'updatedAt': FieldValue.serverTimestamp(),
      });
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
  /// [taskBox] - Hive box for storing downloaded tasks
  /// [filterBox] - Hive box for storing downloaded filters
  /// [brainBox] - Hive box for storing downloaded brain points
  ///
  /// Throws an exception if:
  /// - No user is authenticated
  /// - Download fails
  static Future<void> downloadTasks(
    Box<List> taskBox,
    Box<dynamic> filterBox,
    Box<dynamic> brainBox,
  ) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No user found in downloadTasks');
    }

    try {
      await _ensureUserDocument();
      final userDataRef = _firestore.collection('user_data').doc(user.uid);

      // Download and update brain points
      final brainPointsDoc =
          await userDataRef.collection('brainPoints').doc('current').get();

      if (brainPointsDoc.exists) {
        final data = brainPointsDoc.data();
        if (data != null) {
          final cloudPoints = data['points'] as int? ?? 100;
          final cloudLastReset =
              data['lastReset'] as String? ?? DateTime.now().toIso8601String();

          final lastResetDate = DateTime.parse(cloudLastReset);
          final now = DateTime.now();

          // Reset points if it's a new day
          if (now.year > lastResetDate.year ||
              now.month > lastResetDate.month ||
              now.day > lastResetDate.day) {
            await brainBox.put(Keys.brainPoints, 100);
            await brainBox.put('lastReset', now.toIso8601String());

            // Update cloud data to reflect reset
            await userDataRef.collection('brainPoints').doc('current').set({
              'points': 100,
              'lastReset': now.toIso8601String(),
              'updatedAt': FieldValue.serverTimestamp(),
            });
          } else {
            await brainBox.put(Keys.brainPoints, cloudPoints);
            await brainBox.put('lastReset', cloudLastReset);
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
            await userDataRef.collection('tasks').doc(category).get();
        if (tasksDoc.exists) {
          final data = tasksDoc.data();
          if (data != null && data['items'] != null) {
            final localTasks = taskBox.get(category) ?? [];

            // Only update if cloud data exists or local data is empty
            if (data['items'].isNotEmpty || localTasks.isEmpty) {
              await taskBox.put(category, data['items']);
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
            await userDataRef.collection('filters').doc(category).get();
        if (filtersDoc.exists) {
          final data = filtersDoc.data();
          if (data != null && data['items'] != null) {
            final localFilters =
                filterBox.get(category) as List<dynamic>? ?? [];

            // Only update if cloud data exists or local data is empty
            if (data['items'].isNotEmpty || localFilters.isEmpty) {
              await filterBox.put(category, data['items']);
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
  /// [historyBox] - Hive box for storing downloaded history
  ///
  /// Throws an exception if:
  /// - No user is authenticated
  /// - Download fails
  static Future<void> downloadFlowHistory(Box<dynamic> historyBox) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No user found in downloadFlowHistory');
    }

    final historyRef = _firestore
        .collection('user_data')
        .doc(user.uid)
        .collection('history')
        .doc('flow');

    try {
      final historyDoc = await historyRef.get();
      if (historyDoc.exists) {
        final data = historyDoc.data();
        if (data != null && data['items'] != null) {
          final localHistory =
              historyBox.get('flow_history') as List<dynamic>? ?? [];

          // Only update if cloud data exists or local data is empty
          if (data['items'].isNotEmpty || localHistory.isEmpty) {
            await historyBox.put('flow_history', data['items']);
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

  /// Performs initial synchronization on user login.
  /// This method:
  /// - For new users: uploads all local data
  /// - For existing users: downloads cloud data, then uploads local changes
  ///
  /// [taskBox] - Hive box containing task data
  /// [filterBox] - Hive box containing filter data
  /// [brainBox] - Hive box containing brain points data
  /// [historyBox] - Hive box containing flow history data
  ///
  /// Throws an exception if:
  /// - No user is authenticated
  /// - Synchronization fails
  static Future<void> syncOnLogin(
    Box<List> taskBox,
    Box<dynamic> filterBox,
    Box<dynamic> brainBox,
    Box<dynamic> historyBox,
  ) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No user found in syncOnLogin');
      }

      final userDataRef = _firestore.collection('user_data').doc(user.uid);
      final userDataDoc = await userDataRef.get();
      final isNewUser = !userDataDoc.exists;

      if (isNewUser) {
        await _ensureUserDocument();
        await uploadTasks(taskBox);
        await uploadFilters(filterBox);
        await uploadBrainPoints(brainBox);
        await uploadFlowHistory(historyBox);
      } else {
        await downloadTasks(taskBox, filterBox, brainBox);
        await downloadFlowHistory(historyBox);
        await uploadTasks(taskBox);
        await uploadFilters(filterBox);
        await uploadBrainPoints(brainBox);
        await uploadFlowHistory(historyBox);
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Clears all local data.
  /// This method:
  /// - Clears tasks for all categories
  /// - Clears filters for all categories
  /// - Resets brain points to default value
  /// - Clears flow history
  ///
  /// [taskBox] - Hive box containing task data
  /// [filterBox] - Hive box containing filter data
  /// [brainBox] - Hive box containing brain points data
  /// [historyBox] - Hive box containing flow history data
  ///
  /// Throws an exception if clearing fails
  static Future<void> clearLocalData(
    Box<List> taskBox,
    Box<dynamic> filterBox,
    Box<dynamic> brainBox,
    Box<dynamic> historyBox,
  ) async {
    try {
      // Clear all task categories
      for (final category in [
        Keys.actions,
        Keys.flows,
        Keys.moments,
        Keys.thoughts,
      ]) {
        await taskBox.put(category, []);
      }

      // Clear all filter categories
      for (final category in [
        Keys.actions,
        Keys.flows,
        Keys.moments,
        Keys.thoughts,
      ]) {
        await filterBox.put(category, []);
      }

      // Reset brain points to default values
      await brainBox.put(Keys.brainPoints, 100);
      await brainBox.put('lastReset', DateTime.now().toIso8601String());

      // Clear flow history
      await historyBox.put('flow_history', <String>[]);
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
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('No user found in deleteUserData');
      }

      final userRef = _firestore.collection('user_data').doc(user.uid);
      final profileRef = _firestore.collection('profiles').doc(user.uid);

      // Delete all subcollections
      await _deleteCollection(userRef.collection('brainPoints'));
      await _deleteCollection(userRef.collection('tasks'));
      await _deleteCollection(userRef.collection('filters'));
      await _deleteCollection(userRef.collection('history'));

      // Delete user documents
      await Future.wait([userRef.delete(), profileRef.delete()]);

      // Clear local data
      await clearLocalData(
        Hive.box<List>(Keys.taskBox),
        Hive.box(Keys.filterBox),
        Hive.box(Keys.brainBox),
        Hive.box(Keys.historyBox),
      );
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

    final userDataRef = _firestore.collection('user_data').doc(user.uid);

    try {
      // Reset brain points
      final brainPointsRef = userDataRef
          .collection('brainPoints')
          .doc('current');
      await brainPointsRef.set({
        'points': 100,
        'lastReset': DateTime.now().toIso8601String(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Clear all tasks
      final tasksRef = userDataRef.collection('tasks');
      final tasksDocs = await tasksRef.get();
      for (var doc in tasksDocs.docs) {
        await doc.reference.set({'items': []});
      }

      // Clear all filters
      final filtersRef = userDataRef.collection('filters');
      final filtersDocs = await filtersRef.get();
      for (var doc in filtersDocs.docs) {
        await doc.reference.set({'items': []});
      }

      // Clear flow history
      final historyRef = userDataRef.collection('history').doc('flow');
      await historyRef.set({
        'items': [],
        'updatedAt': FieldValue.serverTimestamp(),
      });
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
