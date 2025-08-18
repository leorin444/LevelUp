import 'package:hive/hive.dart';
part 'task_model.g.dart';

@HiveType(typeId: 0)
class Task extends HiveObject {
  @HiveField(0)
  String id;
  @HiveField(1)
  String title;
  @HiveField(2)
  String category;
  @HiveField(3)
  String priority;
  @HiveField(4)
  bool completed;
  @HiveField(5)
  DateTime? dueDate;
  @HiveField(6)
  String recurrence;

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
