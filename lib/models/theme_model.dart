import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class ThemeModel extends ChangeNotifier {
  static const String _boxName = 'settings';
  static const String _key = 'isDarkMode';

  late Box _box;
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  Future<void> init() async {
    _box = await Hive.openBox(_boxName);
    _isDarkMode = _box.get(_key, defaultValue: false);
    notifyListeners();
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    _box.put(_key, _isDarkMode);
    notifyListeners();
  }
}
