import 'package:flutter/foundation.dart';

/// Task model
class Task {
  final String id;
  String title;
  bool completed;

  Task({
    required this.id,
    required this.title,
    this.completed = false,
  });
}

/// DashboardData to manage tasks
class DashboardData with ChangeNotifier {
  final List<Task> _tasks = [];

  /// Expose tasks as read-only list
  List<Task> get tasks => _tasks;

  /// Simulate listener (for Firebase later)
  void startListener() {
    // For now, this is empty
    // You can later connect to Firebase or DB here
  }

  /// Add a task
  void addTask(String title) {
    if (title.trim().isEmpty) return;
    final task = Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
    );
    _tasks.add(task);
    notifyListeners();
  }

  /// Delete a task by ID
  void deleteTask(String id) {
    _tasks.removeWhere((task) => task.id == id);
    notifyListeners();
  }

  /// Toggle completed/uncompleted
  void toggleTask(String id, bool value) {
    final task = _tasks.firstWhere((t) => t.id == id);
    task.completed = value;
    notifyListeners();
  }

  /// Update task title
  void updateTaskTitle(String id, String newTitle) {
    final task = _tasks.firstWhere((t) => t.id == id);
    task.title = newTitle;
    notifyListeners();
  }
}
