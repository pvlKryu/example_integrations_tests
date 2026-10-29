/// Конфигурация приложения.
///
/// Адрес API передаётся через:
/// `--dart-define=API_BASE_URL=http://127.0.0.1:8080`
///
/// Значения по умолчанию рассчитаны на iOS Simulator / macOS,
/// где хост-машина доступна как 127.0.0.1.
abstract final class AppConfig {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8080',
  );
}
