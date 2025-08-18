import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

import '../models/dashboard_data.dart';
import '../models/task_model.dart';
import '../services/notifications_service.dart';
import '../widgets/task_tile.dart';
import 'add_task_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final TextEditingController _controller = TextEditingController();
  String selectedCategory = "General";
  String selectedPriority = "Medium";
  String? filterCategory;
  String? filterPriority;
  String sortBy = "None";
  String? groupBy;
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    final dashboard = Provider.of<DashboardData>(context, listen: false);
    dashboard.init();
    NotificationsService.init();
  }

  @override
  Widget build(BuildContext context) {
    final dashboard = Provider.of<DashboardData>(context);

    List<Task> displayedTasks = dashboard.tasks;

    // Filters
    if (filterCategory != null) {
      displayedTasks =
          displayedTasks.where((t) => t.category == filterCategory).toList();
    }
    if (filterPriority != null) {
      displayedTasks =
          displayedTasks.where((t) => t.priority == filterPriority).toList();
    }
    if (searchQuery.isNotEmpty) {
      displayedTasks = displayedTasks
          .where(
              (t) => t.title.toLowerCase().contains(searchQuery.toLowerCase()))
          .toList();
    }

    // Sorting
    switch (sortBy) {
      case "Due Date":
        displayedTasks.sort((a, b) {
          if (a.dueDate == null) return 1;
          if (b.dueDate == null) return -1;
          return a.dueDate!.compareTo(b.dueDate!);
        });
        break;
      case "Priority":
        const order = {"High": 0, "Medium": 1, "Low": 2};
        displayedTasks.sort((a, b) =>
            (order[a.priority] ?? 3).compareTo(order[b.priority] ?? 3));
        break;
      case "Title":
        displayedTasks.sort((a, b) => a.title.compareTo(b.title));
        break;
    }

    Map<String, List<Task>> groupedTasks = {};
    if (groupBy != null) {
      for (var task in displayedTasks) {
        final key = groupBy == "Category" ? task.category : task.priority;
        groupedTasks.putIfAbsent(key, () => []).add(task);
      }
    }

    final categoryStats = dashboard.completedTasksByCategory();
    final priorityStats = dashboard.completedTasksByPriority();

    return Scaffold(
      appBar: AppBar(
        title: const Text("LevelUp Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () => Navigator.pushNamed(context, '/reports'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Stats Card
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              color: Colors.blue.shade100,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        const Text("Completed Today",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text("${dashboard.completedToday()}"),
                      ],
                    ),
                    Column(
                      children: [
                        const Text("Longest Streak",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text("${dashboard.longestStreak()} days"),
                      ],
                    ),
                    Column(
                      children: [
                        const Text("Total Tasks",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text("${dashboard.tasks.length}"),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Charts for Day 28
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(child: buildPieChart(categoryStats, "Category Stats")),
                const SizedBox(width: 10),
                Expanded(child: buildPieChart(priorityStats, "Priority Stats")),
              ],
            ),
          ),

          // Search
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: "Search tasks...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => setState(() => searchQuery = value),
            ),
          ),

          // Filters, Sorting, Grouping
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                DropdownButton<String>(
                  hint: const Text("Category"),
                  value: filterCategory,
                  items: [null, "General", "Work", "Personal", "Study"]
                      .map((cat) => DropdownMenuItem(
                          value: cat, child: Text(cat ?? "All")))
                      .toList(),
                  onChanged: (val) => setState(() => filterCategory = val),
                ),
                const SizedBox(width: 10),
                DropdownButton<String>(
                  hint: const Text("Priority"),
                  value: filterPriority,
                  items: [null, "High", "Medium", "Low"]
                      .map((p) =>
                          DropdownMenuItem(value: p, child: Text(p ?? "All")))
                      .toList(),
                  onChanged: (val) => setState(() => filterPriority = val),
                ),
                const SizedBox(width: 10),
                DropdownButton<String>(
                  value: sortBy,
                  items: ["None", "Due Date", "Priority", "Title"]
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (val) => setState(() => sortBy = val ?? "None"),
                ),
                const SizedBox(width: 10),
                DropdownButton<String>(
                  value: groupBy,
                  items: [null, "Category", "Priority"]
                      .map((g) => DropdownMenuItem(
                          value: g, child: Text(g ?? "No Group")))
                      .toList(),
                  onChanged: (val) => setState(() => groupBy = val),
                ),
              ],
            ),
          ),

          // Task List
          Expanded(
            child: groupedTasks.isEmpty
                ? ListView.builder(
                    itemCount: displayedTasks.length,
                    itemBuilder: (context, index) {
                      final task = displayedTasks[index];
                      final isOverdue = task.dueDate != null &&
                          task.dueDate!.isBefore(DateTime.now()) &&
                          !task.completed;

                      return TaskTile(
                        task: task,
                        backgroundColor: isOverdue ? Colors.red.shade100 : null,
                        onCompletedChanged: (val) =>
                            dashboard.toggleTask(task.id, val ?? false),
                        onEdit: (task) => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => AddTaskScreen(task: task)),
                        ),
                      );
                    },
                  )
                : ListView(
                    children: groupedTasks.entries.map((entry) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(entry.key,
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                          ),
                          ...entry.value.map((task) {
                            final isOverdue = task.dueDate != null &&
                                task.dueDate!.isBefore(DateTime.now()) &&
                                !task.completed;

                            return TaskTile(
                              task: task,
                              backgroundColor:
                                  isOverdue ? Colors.red.shade100 : null,
                              onCompletedChanged: (val) =>
                                  dashboard.toggleTask(task.id, val ?? false),
                              onEdit: (task) => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => AddTaskScreen(task: task)),
                              ),
                            );
                          }).toList(),
                        ],
                      );
                    }).toList(),
                  ),
          ),

          // Add Task
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration:
                        const InputDecoration(hintText: "Add new task..."),
                  ),
                ),
                DropdownButton<String>(
                  value: selectedCategory,
                  items: ["General", "Work", "Personal", "Study"]
                      .map((cat) =>
                          DropdownMenuItem(value: cat, child: Text(cat)))
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
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    if (_controller.text.isNotEmpty) {
                      final newTask = dashboard.addTask(
                        _controller.text,
                        category: selectedCategory,
                        priority: selectedPriority,
                      );
                      if (newTask.dueDate != null) {
                        NotificationsService.scheduleNotification(
                            newTask, newTask.dueDate!);
                      }
                      _controller.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Pie chart helper
  Widget buildPieChart(Map<String, int> data, String title) {
    if (data.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(child: Text("$title: No data")),
        ),
      );
    }

    final sections = data.entries
        .map((e) => PieChartSectionData(
              value: e.value.toDouble(),
              title: e.key,
              radius: 30,
            ))
        .toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(
                height: 100, child: PieChart(PieChartData(sections: sections))),
          ],
        ),
      ),
    );
  }
}
