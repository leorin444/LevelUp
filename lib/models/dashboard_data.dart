import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'task_model.dart';
import '../services/notifications_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardData extends ChangeNotifier {
  List<Task> _tasks = [];
  late Box<Task> _taskBox;

  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  String? _userId;

  List<Task> get tasks => _tasks;

  Future<void> init() async {
    _taskBox = await Hive.openBox<Task>('tasks');

    final user = _auth.currentUser ?? (await _auth.signInAnonymously()).user;
    _userId = user?.uid;

    _tasks = _taskBox.values.toList();
    await syncTasksFromFirestore();

    notifyListeners();
  }

  Future<void> syncTasksFromFirestore() async {
    if (_userId == null) return;

    final snapshot = await _firestore
        .collection('users')
        .doc(_userId)
        .collection('tasks')
        .get();

    final firestoreTasks =
        snapshot.docs.map((doc) => Task.fromMap(doc.data())).toList();

    for (var task in firestoreTasks) {
      if (!_taskBox.containsKey(task.id)) {
        _taskBox.put(task.id, task);
      }
    }

    _tasks = _taskBox.values.toList();
    notifyListeners();
  }

  Future<void> _saveTaskToFirestore(Task task) async {
    if (_userId == null) return;
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('tasks')
        .doc(task.id)
        .set(task.toMap());
  }

  Future<void> _deleteTaskFromFirestore(String id) async {
    if (_userId == null) return;
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('tasks')
        .doc(id)
        .delete();
  }

  Task addTask(String title,
      {String category = "General",
      String priority = "Medium",
      DateTime? dueDate,
      String recurrence = "none"}) {
    final task = Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      category: category,
      priority: priority,
      completed: false,
      dueDate: dueDate,
      recurrence: recurrence,
    );

    _taskBox.put(task.id, task);
    _saveTaskToFirestore(task);
    _tasks = _taskBox.values.toList();
    notifyListeners();
    return task;
  }

  void toggleTask(String id, bool completed) {
    final task = _taskBox.get(id);
    if (task == null) return;

    final updatedTask = task.copyWith(completed: completed);
    _taskBox.put(id, updatedTask);
    _saveTaskToFirestore(updatedTask);
    _tasks = _taskBox.values.toList();
    notifyListeners();

    if (completed && task.recurrence != "none" && task.dueDate != null) {
      DateTime nextDate;
      switch (task.recurrence) {
        case "daily":
          nextDate = task.dueDate!.add(const Duration(days: 1));
          break;
        case "weekly":
          nextDate = task.dueDate!.add(const Duration(days: 7));
          break;
        case "monthly":
          nextDate = DateTime(
              task.dueDate!.year, task.dueDate!.month + 1, task.dueDate!.day);
          break;
        default:
          return;
      }
      final newTask = addTask(
        task.title,
        category: task.category,
        priority: task.priority,
        dueDate: nextDate,
        recurrence: task.recurrence,
      );
      NotificationsService.scheduleNotification(newTask, nextDate);
    }
  }

  void deleteTask(String id) {
    _taskBox.delete(id);
    _deleteTaskFromFirestore(id);
    _tasks = _taskBox.values.toList();
    notifyListeners();
  }

  void updateTask(String id, Task updatedTask) {
    _taskBox.put(id, updatedTask);
    _saveTaskToFirestore(updatedTask);
    _tasks = _taskBox.values.toList();
    notifyListeners();
  }

  int completedToday() {
    final today = DateTime.now();
    return _tasks
        .where((t) =>
            t.completed &&
            t.dueDate != null &&
            t.dueDate!.year == today.year &&
            t.dueDate!.month == today.month &&
            t.dueDate!.day == today.day)
        .length;
  }

  int longestStreak() => 0;

  Map<String, int> completedTasksByCategory() {
    final map = <String, int>{};
    for (var task in _tasks.where((t) => t.completed)) {
      map[task.category] = (map[task.category] ?? 0) + 1;
    }
    return map;
  }

  Map<String, int> completedTasksByPriority() {
    final map = <String, int>{};
    for (var task in _tasks.where((t) => t.completed)) {
      map[task.priority] = (map[task.priority] ?? 0) + 1;
    }
    return map;
  }
}
