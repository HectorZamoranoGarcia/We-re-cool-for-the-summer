import '../entities/user_preferences_entity.dart';

abstract interface class IPreferencesRepository {
  Future<UserPreferencesEntity> getPreferences();
  Future<void> savePreferences(UserPreferencesEntity prefs);
}
