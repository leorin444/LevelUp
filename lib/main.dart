import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import 'package:firebase_core/firebase_core.dart';

import 'models/task_model.dart';
import 'models/dashboard_data.dart';
import 'screens/dashboard_screen.dart';
import 'services/notifications_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  await Hive.initFlutter();
  Hive.registerAdapter(TaskAdapter());

  tz_data.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Kathmandu'));

  final dashboardData = DashboardData();
  await dashboardData.init();

  await NotificationsService.init();
  NotificationsService.registerDashboardData(dashboardData);

  runApp(
    ChangeNotifierProvider.value(
      value: dashboardData,
      child: const MyDashboardApp(),
    ),
  );
}

class MyDashboardApp extends StatelessWidget {
  const MyDashboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LevelUp',
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
      ),
      home: const DashboardScreen(),
    );
  }
}
