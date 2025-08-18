import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/theme_model.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Consumer<ThemeModel>(
        builder: (context, themeModel, child) {
          final theme = Theme.of(context);
          return ListView(
            children: [
              SwitchListTile(
                title: const Text('Dark Mode'),
                value: themeModel.isDarkMode,
                onChanged: (val) => themeModel.toggleTheme(),
                activeColor: theme.colorScheme.primary,
              ),
            ],
          );
        },
      ),
    );
  }
}
