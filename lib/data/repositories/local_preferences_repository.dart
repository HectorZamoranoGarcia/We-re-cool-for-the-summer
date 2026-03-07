import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/user_preferences_entity.dart';
import '../../domain/repositories/i_preferences_repository.dart';

class LocalPreferencesRepository implements IPreferencesRepository {
  static const _keyUsername = 'username';
  static const _keyLanguage = 'languageCode';
  static const _keyTheme = 'themeMode';

  final SharedPreferences _prefs;

  const LocalPreferencesRepository(this._prefs);

  @override
  Future<UserPreferencesEntity> getPreferences() async {
    final username = _prefs.getString(_keyUsername);
    final languageCode = _prefs.getString(_keyLanguage);
    final themeString = _prefs.getString(_keyTheme);

    ThemeMode themeMode = ThemeMode.system;
    if (themeString == 'light') themeMode = ThemeMode.light;
    if (themeString == 'dark') themeMode = ThemeMode.dark;

    final defaultPrefs = UserPreferencesEntity.defaultPrefs();

    return UserPreferencesEntity(
      username: username ?? defaultPrefs.username,
      languageCode: languageCode ?? defaultPrefs.languageCode,
      themeMode: themeMode,
    );
  }

  @override
  Future<void> savePreferences(UserPreferencesEntity prefs) async {
    await _prefs.setString(_keyUsername, prefs.username);
    await _prefs.setString(_keyLanguage, prefs.languageCode);

    String themeString = 'system';
    if (prefs.themeMode == ThemeMode.light) themeString = 'light';
    if (prefs.themeMode == ThemeMode.dark) themeString = 'dark';
    await _prefs.setString(_keyTheme, themeString);
  }
}
