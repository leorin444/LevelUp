import 'package:flutter/material.dart';
import '../models/task_model.dart';

class TaskTile extends StatelessWidget {
  final Task task;
  final Color? backgroundColor;
  final ValueChanged<bool?>? onCompletedChanged;
  final ValueChanged<Task>? onEdit;

  const TaskTile({
    super.key,
    required this.task,
    this.backgroundColor,
    this.onCompletedChanged,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: backgroundColor ?? Colors.white,
      child: ListTile(
        leading: Checkbox(
          value: task.completed,
          onChanged: onCompletedChanged,
        ),
        title: Text(task.title,
            style: TextStyle(
                decoration: task.completed
                    ? TextDecoration.lineThrough
                    : TextDecoration.none)),
        subtitle: Row(
          children: [
            Text(task.category),
            const SizedBox(width: 10),
            Text(task.priority),
            if (task.dueDate != null)
              Text(
                  " - Due: ${task.dueDate!.hour}:${task.dueDate!.minute.toString().padLeft(2, '0')}"),
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
