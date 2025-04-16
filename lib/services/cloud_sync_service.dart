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
      print('DEBUG: No user found in _ensureUserDocument');
      return;
    }

    print('DEBUG: Ensuring document for user: ${user.uid}');
    final userRef = _firestore.collection('users').doc(user.uid);

    try {
      final userDoc = await userRef.get();
      print('DEBUG: User document exists: ${userDoc.exists}');

      if (!userDoc.exists) {
        print('DEBUG: Creating new user document');
        // Create initial user document with default values
        await userRef.set({
          'brainPoints': 0,
          'createdAt': FieldValue.serverTimestamp(),
        });

        // We don't create empty task documents here anymore
        // They will be created when data is uploaded
        print('DEBUG: Initial user setup complete');
      }
    } catch (e) {
      print('DEBUG: Error in _ensureUserDocument: $e');
      rethrow;
    }
  }

  static Future<void> uploadTasks(Box<dynamic> taskBox) async {
    final user = _auth.currentUser;
    if (user == null) {
      print('DEBUG: No user found in uploadTasks');
      return;
    }

    print('DEBUG: Starting task upload for user: ${user.uid}');
    final userRef = _firestore.collection('users').doc(user.uid);
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
        print('DEBUG: Uploading tasks for $category: ${tasks.length} items');
        final tasksRef = userRef.collection('tasks').doc(category);
        batch.set(tasksRef, {'items': tasks});
      }

      await batch.commit();
      print('DEBUG: Task upload complete');
    } catch (e) {
      print('DEBUG: Error in uploadTasks: $e');
      rethrow;
    }
  }

  static Future<void> uploadFilters(Box<dynamic> filterBox) async {
    final user = _auth.currentUser;
    if (user == null) {
      print('DEBUG: No user found in uploadFilters');
      return;
    }

    print('DEBUG: Starting filter upload for user: ${user.uid}');
    final userRef = _firestore.collection('users').doc(user.uid);
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
        print(
          'DEBUG: Uploading filters for $category: ${filters.length} items',
        );
        final filtersRef = userRef.collection('filters').doc(category);
        batch.set(filtersRef, {'items': filters});
      }

      await batch.commit();
      print('DEBUG: Filter upload complete');
    } catch (e) {
      print('DEBUG: Error in uploadFilters: $e');
      rethrow;
    }
  }

  static Future<void> uploadBrainPoints(Box<dynamic> brainBox) async {
    final user = _auth.currentUser;
    if (user == null) {
      print('DEBUG: No user found in uploadBrainPoints');
      return;
    }

    print('DEBUG: Starting brain points upload for user: ${user.uid}');
    final userRef = _firestore.collection('users').doc(user.uid);

    try {
      // Upload brain points
      final brainPoints = brainBox.get('points') ?? 0;
      print('DEBUG: Uploading brain points: $brainPoints');
      await userRef.update({'brainPoints': brainPoints});
      print('DEBUG: Brain points upload complete');
    } catch (e) {
      print('DEBUG: Error in uploadBrainPoints: $e');
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
      print('DEBUG: No user found in downloadTasks');
      return;
    }

    print('DEBUG: Starting download for user: ${user.uid}');

    try {
      // Ensure user document exists before downloading
      await _ensureUserDocument();

      final userRef = _firestore.collection('users').doc(user.uid);

      // Download tasks for each category
      for (final category in [
        Keys.actions,
        Keys.flows,
        Keys.moments,
        Keys.thoughts,
      ]) {
        print('DEBUG: Downloading tasks for $category');
        final tasksDoc = await userRef.collection('tasks').doc(category).get();
        if (tasksDoc.exists) {
          final data = tasksDoc.data();
          if (data != null && data['items'] != null) {
            // Check if local data exists
            final localTasks = taskBox.get(category) as List<dynamic>? ?? [];

            // Only update if cloud data is not empty or if local data is empty
            if (data['items'].isNotEmpty || localTasks.isEmpty) {
              await taskBox.put(category, data['items']);
              print(
                'DEBUG: Downloaded ${data['items'].length} tasks for $category',
              );
            } else {
              print(
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
        print('DEBUG: Downloading filters for $category');
        final filtersDoc =
            await userRef.collection('filters').doc(category).get();
        if (filtersDoc.exists) {
          final data = filtersDoc.data();
          if (data != null && data['items'] != null) {
            // Check if local data exists
            final localFilters =
                filterBox.get(category) as List<dynamic>? ?? [];

            // Only update if cloud data is not empty or if local data is empty
            if (data['items'].isNotEmpty || localFilters.isEmpty) {
              await filterBox.put(category, data['items']);
              print(
                'DEBUG: Downloaded ${data['items'].length} filters for $category',
              );
            } else {
              print(
                'DEBUG: Preserving local filters for $category (${localFilters.length} items)',
              );
            }
          }
        }
      }

      // Download brain points
      print('DEBUG: Downloading brain points');
      final userDoc = await userRef.get();
      if (userDoc.exists) {
        final data = userDoc.data();
        if (data != null && data['brainPoints'] != null) {
          // Only update if cloud data is greater than local data
          final localPoints = brainBox.get('points') ?? 0;
          if (data['brainPoints'] > localPoints) {
            await brainBox.put('points', data['brainPoints']);
            print('DEBUG: Downloaded brain points: ${data['brainPoints']}');
          } else {
            print('DEBUG: Preserving local brain points: $localPoints');
          }
        }
      }
      print('DEBUG: Download complete');
    } catch (e) {
      print('DEBUG: Error in downloadTasks: $e');
      rethrow;
    }
  }

  static Future<void> syncOnLogin(
    Box<dynamic> taskBox,
    Box<dynamic> filterBox,
    Box<dynamic> brainBox,
  ) async {
    print('DEBUG: Starting sync on login');
    try {
      // Check if this is a new user (just signed up)
      final user = _auth.currentUser;
      if (user == null) {
        print('DEBUG: No user found in syncOnLogin');
        return;
      }

      // Check if user document exists
      final userRef = _firestore.collection('users').doc(user.uid);
      final userDoc = await userRef.get();
      final isNewUser = !userDoc.exists;

      if (isNewUser) {
        print('DEBUG: New user detected, uploading local data to cloud');
        // For new users, first ensure the user document exists
        await _ensureUserDocument();
        // Then upload local data to cloud
        await uploadTasks(taskBox);
        await uploadFilters(filterBox);
        await uploadBrainPoints(brainBox);
      } else {
        print('DEBUG: Existing user, syncing with cloud');
        // For existing users, download from cloud
        await downloadTasks(taskBox, filterBox, brainBox);
        // Then upload any changes
        await uploadTasks(taskBox);
        await uploadFilters(filterBox);
        await uploadBrainPoints(brainBox);
      }
      print('DEBUG: Sync on login complete');
    } catch (e) {
      print('DEBUG: Error in syncOnLogin: $e');
      rethrow;
    }
  }

  static Future<void> clearLocalData(
    Box<dynamic> taskBox,
    Box<dynamic> filterBox,
    Box<dynamic> brainBox,
  ) async {
    print('DEBUG: Clearing local data');
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
      await brainBox.put('points', 0);

      print('DEBUG: Local data cleared successfully');
    } catch (e) {
      print('DEBUG: Error clearing local data: $e');
      rethrow;
    }
  }
}
