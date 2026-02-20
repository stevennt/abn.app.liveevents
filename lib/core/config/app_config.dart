class AppConfig {
  const AppConfig._();

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://axum.abnasia.org',
  );

  static const Duration requestTimeout = Duration(seconds: 15);
}
