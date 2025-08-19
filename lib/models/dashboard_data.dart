import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart'; // Added Uuid import
import '../models/task_model.dart';
import '../services/notifications_service.dart';

class DashboardData extends ChangeNotifier {
  List<Task> _tasks = [];
  late Box<Task> _taskBox;
  final Uuid _uuid = const Uuid(); // Uuid instance

  List<Task> get tasks => _tasks;

  Future<void> init() async {
    _taskBox = await Hive.openBox<Task>('tasks');
    _tasks = _taskBox.values.toList();
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
      id: _uuid.v4(), // Generate unique ID with Uuid
      title: title,
      category: category,
      priority: priority,
      completed: false,
      dueDate: dueDate,
      recurrence: recurrence,
    );

    _taskBox.put(task.id, task);
    _tasks = _taskBox.values.toList();
    notifyListeners();
    return task;
  }

  void toggleTask(String id, bool completed) {
    final task = _taskBox.get(id);
    if (task != null) {
      final updatedTask = task.copyWith(completed: completed);
      _taskBox.put(id, updatedTask);
      _tasks = _taskBox.values.toList();
      notifyListeners();

      // Recurring tasks
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
              task.dueDate!.year,
              task.dueDate!.month + 1,
              task.dueDate!.day,
            );
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
  }

  void deleteTask(String id) {
    _taskBox.delete(id);
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

  void updateTask(String id, Task updatedTask) {
    _taskBox.put(id, updatedTask);
    _tasks = _taskBox.values.toList();
    notifyListeners();
  }

  int longestStreak() {
    // Implement streak logic if needed
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
