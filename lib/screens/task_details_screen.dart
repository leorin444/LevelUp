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
    final dashboard = Provider.of<DashboardData>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Task Details"),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddTaskScreen(task: task),
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
                  onChanged: (value) {
                    dashboard.toggleTask(task.id, value ?? false);
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
