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
  final TextEditingController _titleController = TextEditingController();
  String category = "General";
  String priority = "Medium";
  DateTime? dueDate;
  String recurrence = "none";

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _titleController.text = widget.task!.title;
      category = widget.task!.category;
      priority = widget.task!.priority;
      dueDate = widget.task!.dueDate;
      recurrence = widget.task!.recurrence;
    }
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: dueDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: dueDate != null
          ? TimeOfDay.fromDateTime(dueDate!)
          : const TimeOfDay(hour: 9, minute: 0),
    );
    if (time == null) return;

    if (!mounted) return; // ✅ fix for async BuildContext warning

    setState(() {
      dueDate =
          DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  void _saveTask() {
    final dashboard = Provider.of<DashboardData>(context, listen: false);
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    if (widget.task != null) {
      final updatedTask = widget.task!.copyWith(
        title: title,
        category: category,
        priority: priority,
        dueDate: dueDate,
        recurrence: recurrence,
      );
      dashboard.updateTask(widget.task!.id, updatedTask);

      if (dueDate != null) {
        NotificationsService.scheduleNotification(updatedTask, dueDate!);
      }
    } else {
      final newTask = dashboard.addTask(
        title,
        category: category,
        priority: priority,
        dueDate: dueDate,
        recurrence: recurrence,
      );

      if (dueDate != null) {
        NotificationsService.scheduleNotification(newTask, dueDate!);
      }
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task != null ? "Edit Task" : "Add Task"),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveTask,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: "Task Title",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: category, // ✅ use initialValue
                    items: ["General", "Work", "Personal", "Study"]
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (val) => setState(() => category = val!),
                    decoration: const InputDecoration(
                      labelText: "Category",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: priority, // ✅ use initialValue
                    items: ["High", "Medium", "Low"]
                        .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                        .toList(),
                    onChanged: (val) => setState(() => priority = val!),
                    decoration: const InputDecoration(
                      labelText: "Priority",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              title: Text(dueDate != null
                  ? "Due: ${dueDate!.day}/${dueDate!.month}/${dueDate!.year} ${dueDate!.hour}:${dueDate!.minute.toString().padLeft(2, '0')}"
                  : "Set Due Date & Time"),
              trailing: const Icon(Icons.calendar_today),
              onTap: _pickDueDate,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: recurrence, // ✅ use initialValue
              items: ["none", "daily", "weekly", "monthly"]
                  .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                  .toList(),
              onChanged: (val) => setState(() => recurrence = val!),
              decoration: const InputDecoration(
                labelText: "Recurrence",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
