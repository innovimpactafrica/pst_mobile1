// Base URL configuration for API endpoints

class BaseUrl {
  BaseUrl._();

  // Production environment
  static const String production = 'http://86.106.181.31:3000';

  // Development environment
  static const String development = 'http://86.106.181.31:3000';

  // Staging environment (if needed)
  static const String staging = 'http://86.106.181.31:3000';

  // Current active environment
  static const String current = production;

  // API version prefix
  static const String apiPrefix = '/api';

  // Base URL getter
  static String get baseUrl => current;
}