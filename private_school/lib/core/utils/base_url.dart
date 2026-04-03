// Base URL configuration for API endpoints

class BaseUrl {
  BaseUrl._();

  // Production environment
  static const String production = 'https://api.pst.innovimpactdev.cloud';

  // Development environment
  static const String development = 'https://api.pst.innovimpactdev.cloud';

  // Staging environment (if needed)
  static const String staging = 'https://api.pst.innovimpactdev.cloud';

  // Current active environment
  static const String current = production;

  // API version prefix
  static const String apiPrefix = '/api';

  // Base URL getter
  static String get baseUrl => current;
}
