import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/dashboard_data.dart';
import '../models/task_model.dart';
import 'add_task_screen.dart';

class TaskDetailsScreen extends StatelessWidget {
  final Task task;

  const TaskDetailsScreen({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final dashboard = Provider.of<DashboardData>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Task Details"),
        actions: [
          IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () async {
                final navigator = Navigator.of(context); // capture before await
                final dashboard = Provider.of<DashboardData>(context,
                    listen: false); // capture before await

                await navigator.push(
                  MaterialPageRoute(
                    builder: (_) => AddTaskScreen(task: task),
                  ),
                );

                // Refresh the task safely (no context usage here)
                final refreshedTask =
                    dashboard.tasks.firstWhere((t) => t.id == task.id);

                task.title = refreshedTask.title;
                task.category = refreshedTask.category;
                task.priority = refreshedTask.priority;
                task.dueDate = refreshedTask.dueDate;
                task.recurrence = refreshedTask.recurrence;
                task.completed = refreshedTask.completed;
              }),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              showDialog(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  title: const Text("Delete Task"),
                  content:
                      const Text("Are you sure you want to delete this task?"),
                  actions: [
                    TextButton(
                      onPressed: () =>
                          Navigator.of(dialogContext).pop(), // cancel
                      child: const Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () {
                        dashboard.deleteTask(task.id); // delete only this task
                        Navigator.of(dialogContext).pop(); // close dialog
                        Navigator.of(context).pop(); // go back to task list
                      },
                      child: const Text(
                        "Delete",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(task.title,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Text("Category: ${task.category}",
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text("Priority: ${task.priority}",
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text(
                "Due: ${task.dueDate?.toLocal().toString().split(' ')[0] ?? "None"}",
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            Row(
              children: [
                const Text("Completed: ", style: TextStyle(fontSize: 18)),
                Checkbox(
                  value: task.completed,
                  onChanged: (value) async {
                    task.completed = value ?? false;
                    await task.save(); // ✅ persist in Hive
                    dashboard.toggleTask(
                        task.id, value ?? false); // keep provider synced
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
