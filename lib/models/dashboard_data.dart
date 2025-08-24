import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/task_model.dart';
import '../services/notifications_service.dart';

class DashboardData extends ChangeNotifier {
  List<Task> _tasks = [];
  late Box<Task> _taskBox;

  List<Task> get tasks => _tasks;

  Future<void> init() async {
    _taskBox = await Hive.openBox<Task>('tasksBox'); // open Hive box
    _tasks.addAll(_taskBox.values); // ✅ load saved tasks
    _tasks = _taskBox.values.toList(); // ✅ load all tasks, not just one
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

    // Store task with its string ID as key

    _tasks.add(task); // update in-memory list
    _taskBox.put(task.id, task);
    //_tasks = _taskBox.values.toList(); // refresh in-memory list
    notifyListeners();
    return task;
  }

  void toggleTask(String id, bool completed) {
    final task = _taskBox.get(id);

    if (task != null) {
      // Update the task property
      task.completed = completed;

      // Save the updated task in Hive using the string ID
      _taskBox.put(task.id, task);

      // Refresh the in-memory list
      _tasks = _taskBox.values.toList();

      notifyListeners();

      // Handle recurring tasks
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
    _taskBox.delete(id); // deletes the correct task
    _tasks = _taskBox.values.toList(); // reload list
    notifyListeners();
  }

  int completedToday() {
    final today = DateTime.now();
    return _tasks
        .where((t) =>
            t.completed == true && // ✅ ensure non-null
            t.dueDate != null &&
            t.dueDate!.year == today.year &&
            t.dueDate!.month == today.month &&
            t.dueDate!.day == today.day)
        .length;
  }

  void updateTask(String id, Task updatedTask) {
    if (_taskBox.containsKey(id)) {
      _taskBox.put(id, updatedTask); // update Hive
      _tasks = _taskBox.values.toList(); // refresh in-memory list
      notifyListeners();
    }
  }

  // void updateTask(String id, Task updatedTask) {
  //   final index = _tasks.indexWhere((t) => t.id == id);
  //   if (index != -1) {
  //     _tasks[index] = updatedTask;
  //     _taskBox.putAt(index, updatedTask); // ✅ update in Hive
  //     notifyListeners();
  //   }
  // }

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
