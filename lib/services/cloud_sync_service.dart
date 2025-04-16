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

    print('DEBUG: Ensuring documents for user: ${user.uid}');
    final userDataRef = _firestore.collection('user_data').doc(user.uid);
    final profileRef = _firestore.collection('profiles').doc(user.uid);
    final brainPointsRef = userDataRef.collection('brainPoints').doc('current');

    try {
      final userDataDoc = await userDataRef.get();
      final profileDoc = await profileRef.get();
      print('DEBUG: User data document exists: ${userDataDoc.exists}');
      print('DEBUG: Profile document exists: ${profileDoc.exists}');

      if (!userDataDoc.exists) {
        print('DEBUG: Creating new user data document');
        // Create initial user data document
        await userDataRef.set({'createdAt': FieldValue.serverTimestamp()});

        // Create initial brain points document
        await brainPointsRef.set({
          'points': 100,
          'lastReset': DateTime.now().toIso8601String(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        print('DEBUG: Initial user data setup complete');
      }

      if (!profileDoc.exists) {
        print('DEBUG: Creating new profile document');
        // Create initial profile document
        await profileRef.set({
          'displayName': user.displayName ?? '',
          'email': user.email ?? '',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        print('DEBUG: Initial profile setup complete');
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
        print('DEBUG: Uploading tasks for $category: ${tasks.length} items');
        final tasksRef = userDataRef.collection('tasks').doc(category);
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
        print(
          'DEBUG: Uploading filters for $category: ${filters.length} items',
        );
        final filtersRef = userDataRef.collection('filters').doc(category);
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
    final brainPointsRef = _firestore
        .collection('user_data')
        .doc(user.uid)
        .collection('brainPoints')
        .doc('current');

    try {
      final brainPoints = brainBox.get(Keys.brainPoints) ?? 100;
      final lastReset =
          brainBox.get('lastReset') ?? DateTime.now().toIso8601String();

      print(
        'DEBUG: Uploading brain points: $brainPoints, lastReset: $lastReset',
      );
      await brainPointsRef.set({
        'points': brainPoints,
        'lastReset': lastReset,
        'updatedAt': FieldValue.serverTimestamp(),
      });
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

      final userDataRef = _firestore.collection('user_data').doc(user.uid);

      // Download brain points from its collection
      print('DEBUG: Downloading brain points');
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
            print('DEBUG: Reset brain points to 100 (new day)');

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
            print('DEBUG: Downloaded brain points: $cloudPoints');
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
        print('DEBUG: Downloading tasks for $category');
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
      final userDataRef = _firestore.collection('user_data').doc(user.uid);
      final userDataDoc = await userDataRef.get();
      final isNewUser = !userDataDoc.exists;

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
      await brainBox.put(Keys.brainPoints, 100);
      await brainBox.put('lastReset', DateTime.now().toIso8601String());

      print('DEBUG: Local data cleared successfully');
    } catch (e) {
      print('DEBUG: Error clearing local data: $e');
      rethrow;
    }
  }

  static Future<void> deleteUserData() async {
    final user = _auth.currentUser;
    if (user == null) {
      print('DEBUG: No user found in deleteUserData');
      return;
    }

    print('DEBUG: Starting user data deletion for user: ${user.uid}');
    final userDataRef = _firestore.collection('user_data').doc(user.uid);
    final profileRef = _firestore.collection('profiles').doc(user.uid);

    try {
      // Delete brain points subcollection
      final brainPointsRef = userDataRef.collection('brainPoints');
      final brainPointsDocs = await brainPointsRef.get();
      for (var doc in brainPointsDocs.docs) {
        await doc.reference.delete();
      }

      // Delete tasks subcollection
      final tasksRef = userDataRef.collection('tasks');
      final tasksDocs = await tasksRef.get();
      for (var doc in tasksDocs.docs) {
        await doc.reference.delete();
      }

      // Delete filters subcollection
      final filtersRef = userDataRef.collection('filters');
      final filtersDocs = await filtersRef.get();
      for (var doc in filtersDocs.docs) {
        await doc.reference.delete();
      }

      // Delete the profile document
      await profileRef.delete();

      // Finally delete the user data document itself
      await userDataRef.delete();

      print('DEBUG: User data deletion complete');
    } catch (e) {
      print('DEBUG: Error in deleteUserData: $e');
      rethrow;
    }
  }

  static Future<void> updateUserProfile(String displayName) async {
    final user = _auth.currentUser;
    if (user == null) {
      print('DEBUG: No user found in updateUserProfile');
      return;
    }

    print('DEBUG: Updating user profile for user: ${user.uid}');
    final profileRef = _firestore.collection('profiles').doc(user.uid);

    try {
      await profileRef.set({
        'displayName': displayName,
        'email': user.email,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      print('DEBUG: User profile updated successfully');
    } catch (e) {
      print('DEBUG: Error in updateUserProfile: $e');
      rethrow;
    }
  }
}
