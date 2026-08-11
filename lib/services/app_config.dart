// App-wide configuration singleton.
// Set once at app launch, accessed from any screen.

class AppConfig {
  static final AppConfig _instance = AppConfig._();
  factory AppConfig() => _instance;
  AppConfig._();

  String entityId = 'maria_trader_sps_001';
}