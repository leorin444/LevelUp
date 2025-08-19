import 'package:hive/hive.dart';

part 'task_model.g.dart'; // Generated file

@HiveType(typeId: 0)
class Task extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String category;

  @HiveField(3)
  final String priority;

  @HiveField(4)
  final bool completed;

  @HiveField(5)
  final DateTime? dueDate;

  @HiveField(6)
  final String recurrence;

  Task({
    required this.id,
    required this.title,
    this.category = "General",
    this.priority = "Medium",
    this.completed = false,
    this.dueDate,
    this.recurrence = "none",
  });

  Task copyWith({
    String? id,
    String? title,
    String? category,
    String? priority,
    bool? completed,
    DateTime? dueDate,
    String? recurrence,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      completed: completed ?? this.completed,
      dueDate: dueDate ?? this.dueDate,
      recurrence: recurrence ?? this.recurrence,
    );
  }
}
