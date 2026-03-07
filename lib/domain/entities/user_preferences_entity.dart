import 'package:flutter/material.dart';

class UserPreferencesEntity {
  final String username;
  final String languageCode;
  final ThemeMode themeMode;

  const UserPreferencesEntity({
    required this.username,
    required this.languageCode,
    required this.themeMode,
  });

  UserPreferencesEntity copyWith({
    String? username,
    String? languageCode,
    ThemeMode? themeMode,
  }) {
    return UserPreferencesEntity(
      username: username ?? this.username,
      languageCode: languageCode ?? this.languageCode,
      themeMode: themeMode ?? this.themeMode,
    );
  }

  factory UserPreferencesEntity.defaultPrefs() {
    return const UserPreferencesEntity(
      username: 'Gourmet',
      languageCode: 'en',
      themeMode: ThemeMode.system,
    );
  }
}
