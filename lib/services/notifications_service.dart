import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:collection/collection.dart'; // ✅ for firstWhereOrNull

import '../models/task_model.dart';
import '../models/dashboard_data.dart';

class NotificationsService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  static DashboardData? _dashboardData;

  /// Register DashboardData for callbacks
  static void registerDashboardData(DashboardData dashboard) {
    _dashboardData = dashboard;
  }

  static Future<void> init() async {
    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Kathmandu'));

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();

    const settings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (response) async {
        final payload = response.payload;

        if (response.actionId == 'snooze') {
          final taskId =
              payload ?? DateTime.now().millisecondsSinceEpoch.toString();
          final snoozeTime = DateTime.now().add(const Duration(minutes: 10));
          await scheduleSnoozedNotification(taskId, snoozeTime);
        }

        if (response.actionId == 'mark_done' &&
            payload != null &&
            _dashboardData != null) {
          final task =
              _dashboardData!.tasks.firstWhereOrNull((t) => t.id == payload);

          if (task != null && !task.completed) {
            _dashboardData!.toggleTask(payload, true);

            // Schedule next occurrence if recurring
            if (task.recurrence != "none" && task.dueDate != null) {
              DateTime nextDate;
              switch (task.recurrence) {
                case "daily":
                  nextDate = task.dueDate!.add(const Duration(days: 1));
                  break;
                case "weekly":
                  nextDate = task.dueDate!.add(const Duration(days: 7));
                  break;
                case "monthly":
                  nextDate = DateTime(
                    task.dueDate!.year,
                    task.dueDate!.month + 1,
                    task.dueDate!.day,
                  );
                  break;
                default:
                  return;
              }

              final newTask = _dashboardData!.addTask(
                task.title,
                category: task.category,
                priority: task.priority,
                dueDate: nextDate,
                recurrence: task.recurrence,
              );

              scheduleNotification(newTask, nextDate);
            }
          }
        }
      },
    );
  }

  static Future<void> scheduleSnoozedNotification(
      String taskId, DateTime time) async {
    await _notifications.zonedSchedule(
      taskId.hashCode,
      "Snoozed Task Reminder",
      "Don't forget: Task is due soon!",
      tz.TZDateTime.from(time, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'task_channel',
          'Tasks',
          channelDescription: 'Task Reminders',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static Future<void> scheduleNotification(Task task, DateTime time) async {
    if (time.isBefore(DateTime.now())) return;

    await _notifications.zonedSchedule(
      task.id.hashCode,
      "Task Reminder",
      "${task.title} is due at ${time.hour}:${time.minute.toString().padLeft(2, '0')}",
      tz.TZDateTime.from(time, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          'task_channel',
          'Tasks',
          channelDescription: 'Task Reminders',
          importance: Importance.max,
          priority: Priority.high,
          actions: [
            const AndroidNotificationAction('snooze', 'Snooze 10 min'),
            const AndroidNotificationAction('mark_done', 'Mark Done'),
          ],
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: task.id,
    );
  }

  static Future<void> cancelNotification(String taskId) async {
    await _notifications.cancel(taskId.hashCode);
  }

  static Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }
}
