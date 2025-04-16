import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:focusyn_app/models/task_model.dart';
import 'package:focusyn_app/constants/keys.dart';
import 'package:hive/hive.dart';

class CloudSyncService {
  static final _auth = FirebaseAuth.instance;
  static final _firestore = FirebaseFirestore.instance;

  static Future<void> uploadTasks(
    Box<dynamic> taskBox,
    Box<dynamic> filterBox,
    Box<dynamic> brainBox,
  ) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final userRef = _firestore.collection('users').doc(user.uid);
    final batch = _firestore.batch();

    // Upload tasks for each category
    for (final category in [
      Keys.actions,
      Keys.flows,
      Keys.moments,
      Keys.thoughts,
    ]) {
      final tasks = taskBox.get(category) as List<dynamic>? ?? [];
      final tasksRef = userRef.collection('tasks').doc(category);
      batch.set(tasksRef, {'items': tasks});
    }

    // Upload filters for each category
    for (final category in [
      Keys.actions,
      Keys.flows,
      Keys.moments,
      Keys.thoughts,
    ]) {
      final filters = filterBox.get(category) as List<dynamic>? ?? [];
      final filtersRef = userRef.collection('filters').doc(category);
      batch.set(filtersRef, {'items': filters});
    }

    // Upload brain points
    final brainPoints = brainBox.get('points') ?? 0;
    batch.set(userRef, {'brainPoints': brainPoints}, SetOptions(merge: true));

    await batch.commit();
  }

  static Future<void> downloadTasks(
    Box<dynamic> taskBox,
    Box<dynamic> filterBox,
    Box<dynamic> brainBox,
  ) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final userRef = _firestore.collection('users').doc(user.uid);

    // Download tasks for each category
    for (final category in [
      Keys.actions,
      Keys.flows,
      Keys.moments,
      Keys.thoughts,
    ]) {
      final tasksDoc = await userRef.collection('tasks').doc(category).get();
      if (tasksDoc.exists) {
        final data = tasksDoc.data();
        if (data != null && data['items'] != null) {
          await taskBox.put(category, data['items']);
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
          await userRef.collection('filters').doc(category).get();
      if (filtersDoc.exists) {
        final data = filtersDoc.data();
        if (data != null && data['items'] != null) {
          await filterBox.put(category, data['items']);
        }
      }
    }

    // Download brain points
    final userDoc = await userRef.get();
    if (userDoc.exists) {
      final data = userDoc.data();
      if (data != null && data['brainPoints'] != null) {
        await brainBox.put('points', data['brainPoints']);
      }
    }
  }

  static Future<void> syncOnLogin(
    Box<dynamic> taskBox,
    Box<dynamic> filterBox,
    Box<dynamic> brainBox,
  ) async {
    await downloadTasks(taskBox, filterBox, brainBox);
    await uploadTasks(
      taskBox,
      filterBox,
      brainBox,
    ); // Push any local data if not already in cloud
  }
}
