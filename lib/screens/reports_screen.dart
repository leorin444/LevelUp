import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/dashboard_data.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dashboard = Provider.of<DashboardData>(context);

    final completedByCategory = dashboard.completedTasksByCategory();
    final completedByPriority = dashboard.completedTasksByPriority();

    // Predefined colors
    final categoryColors = {
      "General": Colors.blueAccent,
      "Work": Colors.orange,
      "Personal": Colors.purple,
      "Study": Colors.green,
    };
    final priorityColors = {
      "High": Colors.red,
      "Medium": Colors.yellow,
      "Low": Colors.green,
    };

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
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: (completedByCategory.values.isEmpty
                            ? 1
                            : completedByCategory.values
                                .reduce((a, b) => a > b ? a : b))
                        .toDouble() +
                    1,
                barGroups: completedByCategory.entries.map((entry) {
                  return BarChartGroupData(
                    x: entry.key.hashCode,
                    barRods: [
                      BarChartRodData(
                        toY: entry.value.toDouble(),
                        color: categoryColors[entry.key] ?? Colors.grey,
                        width: 22,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                    showingTooltipIndicators: const [0],
                  );
                }).toList(),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final entry = completedByCategory.entries.firstWhere(
                          (e) => e.key.hashCode.toDouble() == value,
                          orElse: () => const MapEntry("", 0),
                        );
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(entry.key),
                        );
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: true, interval: 1),
                  ),
                ),
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    // Keep default styling; just provide the content.
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final entry = completedByCategory.entries.firstWhere(
                        (e) => e.key.hashCode == group.x,
                        orElse: () => const MapEntry("", 0),
                      );
                      return BarTooltipItem(
                        "${entry.key}: ${entry.value}",
                        const TextStyle(fontWeight: FontWeight.w600),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            "Completed Tasks by Priority",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 220,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: (completedByPriority.values.isEmpty
                            ? 1
                            : completedByPriority.values
                                .reduce((a, b) => a > b ? a : b))
                        .toDouble() +
                    1,
                barGroups: completedByPriority.entries.map((entry) {
                  return BarChartGroupData(
                    x: entry.key.hashCode,
                    barRods: [
                      BarChartRodData(
                        toY: entry.value.toDouble(),
                        color: priorityColors[entry.key] ?? Colors.grey,
                        width: 22,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                    showingTooltipIndicators: const [0],
                  );
                }).toList(),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final entry = completedByPriority.entries.firstWhere(
                          (e) => e.key.hashCode.toDouble() == value,
                          orElse: () => const MapEntry("", 0),
                        );
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(entry.key),
                        );
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: true, interval: 1),
                  ),
                ),
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final entry = completedByPriority.entries.firstWhere(
                        (e) => e.key.hashCode == group.x,
                        orElse: () => const MapEntry("", 0),
                      );
                      return BarTooltipItem(
                        "${entry.key}: ${entry.value}",
                        const TextStyle(fontWeight: FontWeight.w600),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
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
