import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:focusyn_app/constants/keys.dart';
import 'package:hive/hive.dart';

class CloudSyncService {
  static final _auth = FirebaseAuth.instance;
  static final _firestore = FirebaseFirestore.instance;

  static Future<void> _ensureUserDocument() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No user found in _ensureUserDocument');
    }

    // Ensure documents for user
    final userDataRef = _firestore.collection('user_data').doc(user.uid);
    final profileRef = _firestore.collection('profiles').doc(user.uid);
    final brainPointsRef = userDataRef.collection('brainPoints').doc('current');

    try {
      final userDataDoc = await userDataRef.get();
      // DEBUG: User data document exists
      final profileDoc = await profileRef.get();
      // DEBUG: Profile document exists

      if (!userDataDoc.exists) {
        // Create initial user data document
        await userDataRef.set({'createdAt': FieldValue.serverTimestamp()});

        // Create initial brain points document
        await brainPointsRef.set({
          'points': 100,
          'lastReset': DateTime.now().toIso8601String(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // DEBUG: Initial user data setup complete
      }

      if (!profileDoc.exists) {
        // Create initial profile document
        await profileRef.set({
          'displayName': user.displayName ?? '',
          'email': user.email ?? '',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // DEBUG: Initial profile setup complete
      }
    } catch (e) {
      // Error in _ensureUserDocument
      rethrow;
    }
  }

  static Future<void> uploadTasks(Box<dynamic> taskBox) async {
    final user = _auth.currentUser;
    if (user == null) {
      // No user found in uploadTasks
      throw Exception('No user found in uploadTasks');
    }

    // Starting task upload for user
    final userDataRef = _firestore.collection('user_data').doc(user.uid);
    final batch = _firestore.batch();

    try {
      // Upload tasks for each category
      for (final category in [
        Keys.actions,
        Keys.flows,
        Keys.moments,
        Keys.thoughts,
      ]) {
        final tasks = taskBox.get(category) as List<dynamic>? ?? [];
        // Uploading tasks for $category: ${tasks.length} items
        final tasksRef = userDataRef.collection('tasks').doc(category);
        batch.set(tasksRef, {'items': tasks});
      }

      await batch.commit();
      // DEBUG: Task upload complete
    } catch (e) {
      // Error in uploadTasks
      rethrow;
    }
  }

  static Future<void> uploadFilters(Box<dynamic> filterBox) async {
    final user = _auth.currentUser;
    if (user == null) {
      // No user found in uploadFilters
      throw Exception('No user found in uploadFilters');
    }

    // Starting filter upload for user
    final userDataRef = _firestore.collection('user_data').doc(user.uid);
    final batch = _firestore.batch();

    try {
      // Upload filters for each category
      for (final category in [
        Keys.actions,
        Keys.flows,
        Keys.moments,
        Keys.thoughts,
      ]) {
        final filters = filterBox.get(category) as List<dynamic>? ?? [];
        // Uploading filters for $category: ${filters.length} items
        final filtersRef = userDataRef.collection('filters').doc(category);
        batch.set(filtersRef, {'items': filters});
      }

      await batch.commit();
      // DEBUG: Filter upload complete
    } catch (e) {
      // Error in uploadFilters
      rethrow;
    }
  }

  static Future<void> uploadBrainPoints(Box<dynamic> brainBox) async {
    final user = _auth.currentUser;
    if (user == null) {
      // No user found in uploadBrainPoints
      throw Exception('No user found in uploadBrainPoints');
    }

    // Starting brain points upload for user
    final brainPointsRef = _firestore
        .collection('user_data')
        .doc(user.uid)
        .collection('brainPoints')
        .doc('current');

    try {
      final brainPoints = brainBox.get(Keys.brainPoints) ?? 100;
      final lastReset =
          brainBox.get('lastReset') ?? DateTime.now().toIso8601String();

      // Uploading brain points
      await brainPointsRef.set({
        'points': brainPoints,
        'lastReset': lastReset,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      // DEBUG: Brain points upload complete
    } catch (e) {
      // Error in uploadBrainPoints
      rethrow;
    }
  }

  static Future<void> uploadFlowHistory(Box<dynamic> historyBox) async {
    final user = _auth.currentUser;
    if (user == null) {
      // No user found in uploadFlowHistory
      throw Exception('No user found in uploadFlowHistory');
    }

    // Starting flow history upload for user
    final historyRef = _firestore
        .collection('user_data')
        .doc(user.uid)
        .collection('history')
        .doc('flow');

    try {
      final history = historyBox.get('flow_history') as List<dynamic>? ?? [];
      // Uploading flow history
      await historyRef.set({
        'items': history,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      // DEBUG: Flow history upload complete
    } catch (e) {
      // Error in uploadFlowHistory
      rethrow;
    }
  }

  static Future<void> downloadTasks(
    Box<dynamic> taskBox,
    Box<dynamic> filterBox,
    Box<dynamic> brainBox,
  ) async {
    final user = _auth.currentUser;
    if (user == null) {
      // No user found in downloadTasks
      throw Exception('No user found in downloadTasks');
    }

    // Starting download for user
    try {
      // Ensure user document exists before downloading
      await _ensureUserDocument();

      final userDataRef = _firestore.collection('user_data').doc(user.uid);

      // Download brain points from its collection
      final brainPointsDoc =
          await userDataRef.collection('brainPoints').doc('current').get();

      if (brainPointsDoc.exists) {
        final data = brainPointsDoc.data();
        if (data != null) {
          final cloudPoints = data['points'] as int? ?? 100;
          final cloudLastReset =
              data['lastReset'] as String? ?? DateTime.now().toIso8601String();

          // Check if we need to reset points based on date
          final lastResetDate = DateTime.parse(cloudLastReset);
          final now = DateTime.now();

          if (now.year > lastResetDate.year ||
              now.month > lastResetDate.month ||
              now.day > lastResetDate.day) {
            // Reset points if it's a new day
            await brainBox.put(Keys.brainPoints, 100);
            await brainBox.put('lastReset', now.toIso8601String());
            // DEBUG: Reset brain points to 100 (new day)

            // Update cloud with reset values
            await userDataRef.collection('brainPoints').doc('current').set({
              'points': 100,
              'lastReset': now.toIso8601String(),
              'updatedAt': FieldValue.serverTimestamp(),
            });
          } else {
            // Use cloud points if it's the same day
            await brainBox.put(Keys.brainPoints, cloudPoints);
            await brainBox.put('lastReset', cloudLastReset);
            // DEBUG: Downloaded brain points: $cloudPoints
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
        // Downloading tasks for $category
        final tasksDoc =
            await userDataRef.collection('tasks').doc(category).get();
        if (tasksDoc.exists) {
          final data = tasksDoc.data();
          if (data != null && data['items'] != null) {
            // Check if local data exists
            final localTasks = taskBox.get(category) as List<dynamic>? ?? [];

            // Only update if cloud data is not empty or if local data is empty
            if (data['items'].isNotEmpty || localTasks.isEmpty) {
              await taskBox.put(category, data['items']);
              // DEBUG: Downloaded ${data['items'].length} tasks for $category
            } else {
              throw Exception(
                'DEBUG: Preserving local tasks for $category (${localTasks.length} items)',
              );
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
        // Downloading filters for $category
        final filtersDoc =
            await userDataRef.collection('filters').doc(category).get();
        if (filtersDoc.exists) {
          final data = filtersDoc.data();
          if (data != null && data['items'] != null) {
            // Check if local data exists
            final localFilters =
                filterBox.get(category) as List<dynamic>? ?? [];

            // Only update if cloud data is not empty or if local data is empty
            if (data['items'].isNotEmpty || localFilters.isEmpty) {
              await filterBox.put(category, data['items']);
              // DEBUG: Downloaded ${data['items'].length} filters for $category
            } else {
              throw Exception(
                'DEBUG: Preserving local filters for $category (${localFilters.length} items)',
              );
            }
          }
        }
      }

      // DEBUG: Download complete
    } catch (e) {
      // Error in downloadTasks
      rethrow;
    }
  }

  static Future<void> downloadFlowHistory(Box<dynamic> historyBox) async {
    final user = _auth.currentUser;
    if (user == null) {
      // No user found in downloadFlowHistory
      throw Exception('No user found in downloadFlowHistory');
    }

    // Starting flow history download for user
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
          // Check if local data exists
          final localHistory =
              historyBox.get('flow_history') as List<dynamic>? ?? [];

          // Only update if cloud data is not empty or if local data is empty
          if (data['items'].isNotEmpty || localHistory.isEmpty) {
            await historyBox.put('flow_history', data['items']);
            // DEBUG: Downloaded ${data['items'].length} flow history items
          } else {
            throw Exception(
              'DEBUG: Preserving local flow history (${localHistory.length} items)',
            );
          }
        }
      }
      // DEBUG: Flow history download complete
    } catch (e) {
      // Error in downloadFlowHistory
      rethrow;
    }
  }

  static Future<void> syncOnLogin(
    Box<dynamic> taskBox,
    Box<dynamic> filterBox,
    Box<dynamic> brainBox,
    Box<dynamic> historyBox,
  ) async {
    // Starting sync on login
    try {
      // Check if this is a new user (just signed up)
      final user = _auth.currentUser;
      if (user == null) {
        // No user found in syncOnLogin
        throw Exception('No user found in syncOnLogin');
      }

      // Check if user document exists
      final userDataRef = _firestore.collection('user_data').doc(user.uid);
      final userDataDoc = await userDataRef.get();
      final isNewUser = !userDataDoc.exists;

      if (isNewUser) {
        // For new users, first ensure the user document exists
        await _ensureUserDocument();
        // Then upload local data to cloud
        await uploadTasks(taskBox);
        await uploadFilters(filterBox);
        await uploadBrainPoints(brainBox);
        await uploadFlowHistory(historyBox);
      } else {
        // For existing users, download from cloud
        await downloadTasks(taskBox, filterBox, brainBox);
        await downloadFlowHistory(historyBox);
        // Then upload any changes
        await uploadTasks(taskBox);
        await uploadFilters(filterBox);
        await uploadBrainPoints(brainBox);
        await uploadFlowHistory(historyBox);
      }
      // DEBUG: Sync on login complete
    } catch (e) {
      // Error in syncOnLogin
      rethrow;
    }
  }

  static Future<void> clearLocalData(
    Box<dynamic> taskBox,
    Box<dynamic> filterBox,
    Box<dynamic> brainBox,
    Box<dynamic> historyBox,
  ) async {
    // Clearing local data
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

      // Reset brain points
      await brainBox.put(Keys.brainPoints, 100);
      await brainBox.put('lastReset', DateTime.now().toIso8601String());

      // Clear flow history
      await historyBox.put('flow_history', <String>[]);

      // DEBUG: Local data cleared successfully
    } catch (e) {
      // Error clearing local data
      rethrow;
    }
  }

  static Future<void> deleteUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        // No user found in deleteUserData
        throw Exception('No user found in deleteUserData');
      }

      // Starting user data deletion for user
      final userRef = _firestore.collection('user_data').doc(user.uid);
      final profileRef = _firestore.collection('profiles').doc(user.uid);

      // Delete all subcollections
      await _deleteCollection(userRef.collection('brainPoints'));
      await _deleteCollection(userRef.collection('tasks'));
      await _deleteCollection(userRef.collection('filters'));
      await _deleteCollection(userRef.collection('history'));

      // Delete the user document and profile
      await Future.wait([userRef.delete(), profileRef.delete()]);
      // DEBUG: User data and profile deleted successfully from Firestore

      // Clear local data
      await clearLocalData(
        Hive.box(Keys.taskBox),
        Hive.box(Keys.filterBox),
        Hive.box(Keys.brainBox),
        Hive.box(Keys.historyBox),
      );
      // DEBUG: Local data cleared successfully
    } catch (e) {
      // Error in deleteUserData
      rethrow;
    }
  }

  static Future<void> updateUserProfile(
    String displayName, {
    String? newEmail,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      // No user found in updateUserProfile
      throw Exception('No user found in updateUserProfile');
    }

    // Updating user profile for user
    final profileRef = _firestore.collection('profiles').doc(user.uid);

    try {
      await profileRef.set({
        'displayName': displayName,
        'email': newEmail ?? user.email,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      // DEBUG: User profile updated successfully
    } catch (e) {
      // Error in updateUserProfile
      rethrow;
    }
  }

  static Future<void> clearAppData() async {
    final user = _auth.currentUser;
    if (user == null) {
      // No user found in clearAppData
      throw Exception('No user found in clearAppData');
    }

    // Starting app data clearing for user
    final userDataRef = _firestore.collection('user_data').doc(user.uid);

    try {
      // Clear brain points
      final brainPointsRef = userDataRef
          .collection('brainPoints')
          .doc('current');
      await brainPointsRef.set({
        'points': 100,
        'lastReset': DateTime.now().toIso8601String(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Clear tasks
      final tasksRef = userDataRef.collection('tasks');
      final tasksDocs = await tasksRef.get();
      for (var doc in tasksDocs.docs) {
        await doc.reference.set({'items': []});
      }

      // Clear filters
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

      // DEBUG: App data cleared successfully
    } catch (e) {
      // Error in clearAppData
      rethrow;
    }
  }

  static Future<void> _deleteCollection(
    CollectionReference collectionRef,
  ) async {
    final snapshot = await collectionRef.get();
    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }
}
