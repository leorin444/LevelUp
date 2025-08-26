import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/task_model.dart';
// import '../services/notifications_service.dart';

class DashboardData extends ChangeNotifier {
  List<Task> _tasks = [];
  late Box<Task> _taskBox;

  List<Task> get tasks => _tasks;

  Future<void> init() async {
    _taskBox = await Hive.openBox<Task>('tasksBox');
    _tasks = _taskBox.values.toList(); // load all tasks
    notifyListeners();
  }

  Task addTask(
    String title, {
    String category = "General",
    String priority = "Medium",
    DateTime? dueDate,
    String recurrence = "none",
  }) {
    final task = Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      category: category,
      priority: priority,
      completed: false,
      dueDate: dueDate,
      recurrence: recurrence,
    );

    // ✅ Save task in Hive
    _taskBox.put(task.id, task);

    // ✅ Add to in-memory list
    _tasks.add(task);

    notifyListeners(); // ✅ refresh UI

    return task;
  }

  void toggleTask(String id, bool completed) {
    final task = _taskBox.get(id);

    if (task != null) {
      // Update task property
      task.completed = completed;

      // Save updated task in Hive
      _taskBox.put(id, task); // ✅ overwrite using id

      // Update in-memory list
      final index = _tasks.indexWhere((t) => t.id == id);
      if (index != -1) {
        _tasks[index] = task;
      }

      notifyListeners(); // ✅ refresh UI
    }
  }

  void deleteTask(String taskId) {
    // final key = _taskBox.keys.firstWhere(
    //   (k) => _taskBox.get(k)!.id == taskId,
    //   orElse: () => null,
    // );

    _taskBox.delete(taskId); // ✅ directly delete by id
    _tasks = _taskBox.values.toList();
    notifyListeners();
  }

  void updateTask(String taskId, Task updatedTask) {
    // final key = _taskBox.keys.firstWhere(
    //   (k) => _taskBox.get(k)!.id == taskId,
    //   orElse: () => null,
    // );

    _taskBox.put(taskId, updatedTask); // ✅ overwrite directly
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

  int longestStreak() {
    // placeholder for streak logic
    return 0;
  }

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
