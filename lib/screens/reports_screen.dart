import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/dashboard_data.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  // Helper for section colors
  Color getSectionColor(int index) {
    const colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.cyan,
      Colors.amber,
    ];
    return colors[index % colors.length];
  }

  Widget buildLegend(Map<String, int> data) {
    return Wrap(
      spacing: 12,
      runSpacing: 6,
      children: data.entries.toList().asMap().entries.map((entry) {
        final idx = entry.key;
        final e = entry.value;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: getSectionColor(idx),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(e.key),
          ],
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dashboard = Provider.of<DashboardData>(context);

    final completedByCategory = dashboard.completedTasksByCategory();
    final completedByPriority = dashboard.completedTasksByPriority();

    return Scaffold(
      appBar: AppBar(title: const Text("Reports")),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text(
            "Completed Tasks by Category",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 220,
            child: PieChart(
              PieChartData(
                sections: completedByCategory.entries
                    .toList()
                    .asMap()
                    .entries
                    .map((entry) {
                  final idx = entry.key;
                  final e = entry.value;
                  return PieChartSectionData(
                    value: e.value.toDouble(),
                    title: '${e.value}',
                    color: getSectionColor(idx),
                    radius: 60,
                    titleStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  );
                }).toList(),
                sectionsSpace: 2,
                centerSpaceRadius: 40,
              ),
            ),
          ),
          const SizedBox(height: 8),
          buildLegend(completedByCategory),
          const SizedBox(height: 32),
          const Text(
            "Completed Tasks by Priority",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 220,
            child: PieChart(
              PieChartData(
                sections: completedByPriority.entries
                    .toList()
                    .asMap()
                    .entries
                    .map((entry) {
                  final idx = entry.key;
                  final e = entry.value;
                  return PieChartSectionData(
                    value: e.value.toDouble(),
                    title: '${e.value}',
                    color: getSectionColor(idx),
                    radius: 60,
                    titleStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  );
                }).toList(),
                sectionsSpace: 2,
                centerSpaceRadius: 40,
              ),
            ),
          ),
          const SizedBox(height: 8),
          buildLegend(completedByPriority),
          const SizedBox(height: 32),
          const Text(
            "Longest Streak",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text("${dashboard.longestStreak()} days"),
        ],
      ),
    );
  }
}
