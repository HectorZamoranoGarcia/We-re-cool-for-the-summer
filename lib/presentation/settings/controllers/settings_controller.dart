import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter/material.dart';

import '../../../domain/entities/user_preferences_entity.dart';
import '../../../core/di/infrastructure_providers.dart';
import '../../../data/repositories/local_preferences_repository.dart';

part 'settings_controller.g.dart';

@riverpod
class SettingsController extends _$SettingsController {
  @override
  Future<UserPreferencesEntity> build() async {
    final prefs = ref.watch(sharedPreferencesProvider);
    final repository = LocalPreferencesRepository(prefs);
    return repository.getPreferences();
  }

  Future<void> updateUsername(String newName) async {
    final currentState = state.value;
    if (currentState == null) return;

    final newState = currentState.copyWith(username: newName);
    await _saveAndEmit(newState);
  }

  Future<void> updateTheme(ThemeMode mode) async {
    final currentState = state.value;
    if (currentState == null) return;

    final newState = currentState.copyWith(themeMode: mode);
    await _saveAndEmit(newState);
  }

  Future<void> updateLanguage(String langCode) async {
    final currentState = state.value;
    if (currentState == null) return;

    final newState = currentState.copyWith(languageCode: langCode);
    await _saveAndEmit(newState);
  }

  Future<void> _saveAndEmit(UserPreferencesEntity newState) async {
    final prefs = ref.read(sharedPreferencesProvider);
    final repository = LocalPreferencesRepository(prefs);

    // Optimistic update
    state = AsyncData(newState);
    await repository.savePreferences(newState);
  }
}
