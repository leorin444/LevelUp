import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/dashboard_data.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  // Distinct colors for chart sections
  Color getSectionColor(int index, bool isDarkMode) {
    const lightColors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.cyan,
      Colors.amber,
    ];
    const darkColors = [
      Colors.blueAccent,
      Colors.greenAccent,
      Colors.orangeAccent,
      Colors.purpleAccent,
      Colors.redAccent,
      Colors.cyanAccent,
      Colors.amberAccent,
    ];
    return (isDarkMode ? darkColors : lightColors)[index % 7];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('LevelUp Dashboard'),
        centerTitle: true,
      ),
      body: Consumer<DashboardData>(
        builder: (context, dashboardData, _) {
          final tasks = dashboardData.tasks;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ElevatedButton.icon(
                  onPressed: () => showDialog(
                    context: context,
                    builder: (_) => AddTaskDialog(),
                  ),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Task'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Tasks:',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return Card(
                      color: theme.cardColor,
                      child: ListTile(
                        title:
                            Text(task.title, style: theme.textTheme.bodyMedium),
                        subtitle: Text(
                          'Category: ${task.category}, Priority: ${task.priority}${task.dueDate != null ? ', Due: ${task.dueDate!.toLocal().toString().split(' ')[0]}' : ''}',
                          style: theme.textTheme.bodySmall,
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Checkbox(
                              value: task.completed,
                              onChanged: (val) {
                                dashboardData.toggleTask(task.id, val ?? false);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () =>
                                  dashboardData.deleteTask(task.id),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 30),
                Text(
                  'Tasks completed today: ${dashboardData.completedToday()}',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 20),
                buildPieChart(
                  title: 'Completed Tasks by Category',
                  data: dashboardData.completedTasksByCategory(),
                  isDarkMode: isDarkMode,
                  theme: theme,
                ),
                const SizedBox(height: 20),
                buildPieChart(
                  title: 'Completed Tasks by Priority',
                  data: dashboardData.completedTasksByPriority(),
                  isDarkMode: isDarkMode,
                  theme: theme,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget buildPieChart({
    required String title,
    required Map<String, int> data,
    required bool isDarkMode,
    required ThemeData theme,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sections: data.entries.toList().asMap().entries.map((entry) {
                final idx = entry.key;
                final e = entry.value;
                return PieChartSectionData(
                  value: e.value.toDouble(),
                  title: '${e.key}: ${e.value}',
                  radius: 50,
                  color: getSectionColor(idx, isDarkMode),
                  titleStyle: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}

// Reusable Add Task Dialog Widget
class AddTaskDialog extends StatefulWidget {
  const AddTaskDialog({super.key});

  @override
  State<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  final titleController = TextEditingController();
  final categoryController = TextEditingController();
  final priorityController = TextEditingController();
  DateTime? dueDate;
  String recurrence = 'none';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      backgroundColor: theme.dialogBackgroundColor,
      title: const Text('Add New Task'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title')),
            TextField(
                controller: categoryController,
                decoration: const InputDecoration(labelText: 'Category')),
            TextField(
                controller: priorityController,
                decoration: const InputDecoration(
                    labelText: 'Priority (Low/Medium/High)')),
            Row(
              children: [
                const Text('Due Date: '),
                TextButton(
                  child: Text(dueDate == null
                      ? 'Select'
                      : '${dueDate!.toLocal()}'.split(' ')[0]),
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setState(() => dueDate = picked);
                    }
                  },
                ),
              ],
            ),
            DropdownButtonFormField<String>(
              value: recurrence,
              items: const [
                DropdownMenuItem(value: 'none', child: Text('None')),
                DropdownMenuItem(value: 'daily', child: Text('Daily')),
                DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
                DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
              ],
              onChanged: (val) => setState(() => recurrence = val ?? 'none'),
              decoration: const InputDecoration(labelText: 'Recurrence'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            if (titleController.text.isNotEmpty) {
              Provider.of<DashboardData>(context, listen: false).addTask(
                titleController.text,
                category: categoryController.text.isEmpty
                    ? 'General'
                    : categoryController.text,
                priority: priorityController.text.isEmpty
                    ? 'Medium'
                    : priorityController.text,
                dueDate: dueDate,
                recurrence: recurrence,
              );
              Navigator.pop(context);
            }
          },
          child: const Text('Add Task'),
        ),
      ],
    );
  }
}
