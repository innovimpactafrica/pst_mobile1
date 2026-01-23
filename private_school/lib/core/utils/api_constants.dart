/// Fichier de constantes pour l'API
/// Chemin: lib/core/utils/api_constants.dart

class ApiConstants {
  ApiConstants._();

  //  URL de base de l'API
  static const String baseUrl = 'http://86.106.181.31:3000';

  //  Endpoints Auth
  static const String loginParent = '/api/auth/login/parent';
  static const String registerParent = '/api/auth/register-parent';
  static const String logout = '/api/auth/logout';
  static const String forgotPassword = '/api/auth/forgot-password';
  static const String resetPassword = '/api/auth/reset-password';
  static const String verifyOtp = '/api/auth/verify-otp';

  //  Endpoints Enfants
  static const String children = '/api/parents/children';
  static String childById(String childId) => '/api/parents/children/$childId';
  static String childLocation(String childId) => '/api/parents/children/$childId/location';
  static const String childrenTrips = '/api/parents/children-trips';
  static const String childrenSchedules = '/api/parents/children/schedules';

  //  Endpoints Dashboard
  static const String dashboard = '/api/parents/dashboard';

  //  Endpoints Trajets
  static const String tripsSearch = '/api/parents/trips/search';
  static const String tripsFilters = '/api/parents/trips/filters';
  static String tripDetails(String tripId) => '/api/parents/trips/$tripId/details';
  static String tripRealtime(String tripId) => '/api/parents/trips/$tripId/realtime';

  //  Endpoints Réservations
  static const String reservations = '/api/parents/reservations';
  static String cancelReservation(String tripId, String childId) =>
      '/api/parents/reservations/$tripId/$childId';

  //  Endpoints Signalements
  static const String incidents = '/api/incidents';
  static const String incidentsList = '/api/incidents';

  //  Endpoints Évaluations
  static const String evaluations = '/api/evaluations';
  static String evaluationById(String id) => '/api/evaluations/$id';

  //  Endpoints Compte
  static const String account = '/api/parents/account';
  static const String accountPhoto = '/api/parents/account/photo';

  //  Endpoints Covoiturage
  static const String carpoolGroups = '/api/parents/carpool/groups';
  static const String carpoolInvitations = '/api/parents/carpool/invitations';
  static const String carpoolCalendar = '/api/parents/carpool/calendar';
  static const String carpoolConduite = '/api/parents/carpool/conduite';

  //  Headers
  static const String contentType = 'application/json';
  static const String authorization = 'Authorization';

  //  Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'user_data';

  //  Timeout
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}