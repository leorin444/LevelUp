import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/dashboard_data.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  Color getCategoryColor(String category) {
    switch (category) {
      case "Work":
        return Colors.blue;
      case "Personal":
        return Colors.orange;
      case "Study":
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Color getPriorityColor(String priority) {
    switch (priority) {
      case "High":
        return Colors.red;
      case "Medium":
        return Colors.orange;
      case "Low":
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dashboard = Provider.of<DashboardData>(context);

    if (dashboard.tasks.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text("Reports")),
        body: const Center(child: Text("No tasks yet. Add tasks first!")),
      );
    }

    final categories = dashboard.completedTasksByCategory();
    final priorities = dashboard.completedTasksByPriority();

    final categorySections = categories.entries.map((entry) {
      return PieChartSectionData(
        value: entry.value.toDouble(),
        color: getCategoryColor(entry.key),
        title: "${entry.key}\n${entry.value}",
        radius: 50,
        titleStyle: const TextStyle(
            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
      );
    }).toList();

    final prioritySections = priorities.entries.map((entry) {
      return PieChartSectionData(
        value: entry.value.toDouble(),
        color: getPriorityColor(entry.key),
        title: "${entry.key}\n${entry.value}",
        radius: 50,
        titleStyle: const TextStyle(
            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
      );
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text("Reports")),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Text(
              "Task Distribution by Category",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 200,
              child: PieChart(PieChartData(
                sections: categorySections,
                sectionsSpace: 2,
                centerSpaceRadius: 0,
              )),
            ),
            const SizedBox(height: 30),
            const Text(
              "Task Distribution by Priority",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 200,
              child: PieChart(PieChartData(
                sections: prioritySections,
                sectionsSpace: 2,
                centerSpaceRadius: 0,
              )),
            ),
            const SizedBox(height: 30),
            Text(
              "Total Tasks: ${dashboard.tasks.length}",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
