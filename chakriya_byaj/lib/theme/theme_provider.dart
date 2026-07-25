import 'package:flutter/material.dart';

enum AppThemeMode { system, light, dark }

class ThemeProvider extends ChangeNotifier {
  AppThemeMode _mode = AppThemeMode.system;

  AppThemeMode get mode => _mode;

  ThemeMode get flutterMode {
    switch (_mode) {
      case AppThemeMode.light:  return ThemeMode.light;
      case AppThemeMode.dark:   return ThemeMode.dark;
      case AppThemeMode.system: return ThemeMode.system;
    }
  }

  void setMode(AppThemeMode m) {
    _mode = m;
    notifyListeners();
  }

  String label(AppThemeMode m) {
    switch (m) {
      case AppThemeMode.system: return 'System';
      case AppThemeMode.light:  return 'Light';
      case AppThemeMode.dark:   return 'Dark';
    }
  }

  IconData icon(AppThemeMode m) {
    switch (m) {
      case AppThemeMode.system: return Icons.brightness_auto_rounded;
      case AppThemeMode.light:  return Icons.light_mode_rounded;
      case AppThemeMode.dark:   return Icons.dark_mode_rounded;
    }
  }
}
