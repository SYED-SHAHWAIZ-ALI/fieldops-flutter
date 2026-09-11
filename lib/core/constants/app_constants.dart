/// App-wide constants, including the future API base URL.
///
/// Today all data comes from mock repositories. When a FastAPI backend
/// is ready, swap the Mock*Repository providers for Api*Repository
/// implementations that call [apiBaseUrl] - no presentation-layer
/// changes are required because screens only depend on the repository
/// interfaces in each feature's `domain` folder.
class AppConstants {
  AppConstants._();

  static const String appName = 'FieldOps';
  static const String appTagline = 'Field Service Management';

  /// Placeholder for the future FastAPI backend.
  static const String apiBaseUrl = 'http://localhost:8000/api/v1';

  static const String demoEmail = 'field.agent@fieldops.com';
  static const String demoPassword = 'demo123';

  static const String themePrefsKey = 'fieldops_theme_mode';
}
