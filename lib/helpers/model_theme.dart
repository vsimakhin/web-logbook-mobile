import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MyThemePreferences {
  final storage = const FlutterSecureStorage();
  static const _themeKey = "theme";

  Future<void> setTheme(String value) async {
    await storage.write(key: _themeKey, value: value);
  }

  Future<ThemeMode> getTheme() async {
    final theme = await getThemeString();
    return convertTheme(theme);
  }

  Future<String> getThemeString() async {
    final theme = await storage.read(key: _themeKey);
    return theme ?? 'System';
  }
}

class ModelTheme extends ChangeNotifier {
  late MyThemePreferences _preferences;
  ThemeMode _themeMode = ThemeMode.system;
  String _themeName = 'System';

  ThemeMode get themeMode => _themeMode;
  String get themeName => _themeName;

  ModelTheme() {
    _preferences = MyThemePreferences();
    getPreferences();
  }

  set theme(String value) {
    _preferences.setTheme(value);
    _themeMode = convertTheme(value);
    _themeName = value;
    notifyListeners();
  }

  Future<void> getPreferences() async {
    _themeMode = await _preferences.getTheme();
    _themeName = await _preferences.getThemeString();
    notifyListeners();
  }
}

ThemeMode convertTheme(String value) {
  late ThemeMode themeMode;

  switch (value) {
    case 'Light':
      {
        themeMode = ThemeMode.light;
      }
      break;
    case 'Dark':
      {
        themeMode = ThemeMode.dark;
      }
      break;
    case 'System':
      {
        themeMode = ThemeMode.system;
      }
      break;
    default:
      {
        themeMode = ThemeMode.system;
      }
  }

  return themeMode;
}
