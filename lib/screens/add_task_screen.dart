import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/dashboard_data.dart';
import '../models/task_model.dart';
import '../services/notifications_service.dart';

class AddTaskScreen extends StatefulWidget {
  final Task? task;
  const AddTaskScreen({super.key, this.task});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final TextEditingController titleController = TextEditingController();
  String selectedCategory = "General";
  String selectedPriority = "Medium";
  String selectedRecurrence = "none";
  DateTime? selectedDueDate;

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      titleController.text = widget.task!.title;
      selectedCategory = widget.task!.category;
      selectedPriority = widget.task!.priority;
      selectedRecurrence = widget.task!.recurrence;
      selectedDueDate = widget.task!.dueDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dashboard = Provider.of<DashboardData>(context);

    return Scaffold(
      appBar:
          AppBar(title: Text(widget.task == null ? "Add Task" : "Edit Task")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: "Task Title"),
            ),
            const SizedBox(height: 10),
            DropdownButton<String>(
              value: selectedCategory,
              items: ["General", "Work", "Personal", "Study"]
                  .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                  .toList(),
              onChanged: (val) {
                if (val != null) setState(() => selectedCategory = val);
              },
            ),
            DropdownButton<String>(
              value: selectedPriority,
              items: ["High", "Medium", "Low"]
                  .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                  .toList(),
              onChanged: (val) {
                if (val != null) setState(() => selectedPriority = val);
              },
            ),
            DropdownButton<String>(
              value: selectedRecurrence,
              items: ["none", "daily", "weekly", "monthly"]
                  .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                  .toList(),
              onChanged: (val) {
                if (val != null) setState(() => selectedRecurrence = val);
              },
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isEmpty) return;
                if (widget.task == null) {
                  final newTask = dashboard.addTask(
                    titleController.text,
                    category: selectedCategory,
                    priority: selectedPriority,
                    dueDate: selectedDueDate,
                    recurrence: selectedRecurrence,
                  );
                  if (newTask.dueDate != null) {
                    NotificationsService.scheduleNotification(
                        newTask, newTask.dueDate!);
                  }
                } else {
                  final updatedTask = widget.task!.copyWith(
                    title: titleController.text,
                    category: selectedCategory,
                    priority: selectedPriority,
                    recurrence: selectedRecurrence,
                    dueDate: selectedDueDate,
                  );
                  dashboard.updateTask(updatedTask.id, updatedTask);
                  if (updatedTask.dueDate != null) {
                    NotificationsService.scheduleNotification(
                        updatedTask, updatedTask.dueDate!);
                  }
                }
                Navigator.pop(context);
              },
              child: Text(widget.task == null ? "Add Task" : "Update Task"),
            ),
          ],
        ),
      ),
    );
  }
}
