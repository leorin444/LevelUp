import 'package:flutter/material.dart';
import '../models/task_model.dart';

class TaskTile extends StatelessWidget {
  final Task task;
  final ValueChanged<bool?>? onCompletedChanged;
  final ValueChanged<Task>? onEdit;
  final Color? backgroundColor;

  const TaskTile({
    super.key,
    required this.task,
    this.onCompletedChanged,
    this.onEdit,
    this.backgroundColor,
  });

  Color getPriorityColor(String priority) {
    switch (priority) {
      case "High":
        return Colors.red.shade300;
      case "Medium":
        return Colors.orange.shade300;
      case "Low":
        return Colors.green.shade300;
      default:
        return Colors.grey.shade300;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: backgroundColor ?? Colors.white,
      child: ListTile(
        leading: Checkbox(
          value: task.completed,
          onChanged: onCompletedChanged,
        ),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.completed ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Row(
          children: [
            Text(task.category),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: getPriorityColor(task.priority),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(task.priority),
            ),
            if (task.dueDate != null)
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                    "${task.dueDate!.hour}:${task.dueDate!.minute.toString().padLeft(2, '0')}"),
              ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () => onEdit?.call(task),
        ),
      ),
    );
  }
}
