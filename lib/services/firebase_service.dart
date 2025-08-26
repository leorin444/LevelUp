import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/task_model.dart';

class DashboardData with ChangeNotifier {
  final List<Task> _tasks = [];
  final CollectionReference _taskCollection =
      FirebaseFirestore.instance.collection('tasks');

  List<Task> get tasks => _tasks;

  /// Start listening to Firestore
  void startListener(String userId) {
    _taskCollection
        .where('userId', isEqualTo: userId)
        .snapshots()
        .listen((snapshot) {
      _tasks.clear();
      for (var doc in snapshot.docs) {
        _tasks.add(Task(
          id: doc.id,
          title: doc['title'],
          completed: doc['completed'],
        ));
      }
      notifyListeners();
    });
  }

  Future<void> addTask(String title, String userId) async {
    if (title.trim().isEmpty) return;
    final doc = await _taskCollection.add({
      'title': title,
      'completed': false,
      'userId': userId,
      'createdAt': FieldValue.serverTimestamp(),
    });
    _tasks.add(Task(id: doc.id, title: title, completed: false));
    notifyListeners();
  }

  Future<void> deleteTask(String id) async {
    await _taskCollection.doc(id).delete();
    _tasks.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  Future<void> toggleTask(String id, bool value) async {
    await _taskCollection.doc(id).update({'completed': value});
    final task = _tasks.firstWhere((t) => t.id == id);
    task.completed = value;
    notifyListeners();
  }

  Future<void> updateTaskTitle(String id, String newTitle) async {
    await _taskCollection.doc(id).update({'title': newTitle});
    final task = _tasks.firstWhere((t) => t.id == id);
    task.title = newTitle;
    notifyListeners();
  }
}
