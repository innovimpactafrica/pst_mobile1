
class ApiConstants {
  ApiConstants._();

  // ==================== BASE URL ====================
  static const String baseUrl = 'http://86.106.181.31:3000';

  // ==================== AUTH ENDPOINTS ====================
  
  // Parent Auth
  static const String loginParent = '/api/auth/login/parent';
  static const String registerParent = '/api/auth/register-parent';
  
  // Driver Auth
  static const String loginDriver = '/api/auth/login/driver';
  static const String registerDriver = '/api/auth/register-driver';
  
  // Auth endpoints
  static const String logout = '/api/auth/logout'; // ← Ajoutez cette ligne
  static const String forgotPassword = '/api/auth/forgot-password';
  static const String resetPassword = '/api/auth/reset-password';
  static const String verifyOtp = '/api/auth/verify-otp';


  // ==================== PARENT ENDPOINTS ====================
  
  // Children
  static const String children = '/api/parents/children';
  static String childById(String childId) => '/api/parents/children/$childId';
  static String childLocation(String childId) => 
      '/api/parents/children/$childId/location';
  static const String childrenTrips = '/api/parents/children-trips';
  static const String childrenSchedules = '/api/parents/children/schedules';
  static String childrenBySchool(int schoolId) => '/api/schools/$schoolId/children';
  
  // Dashboard
  static const String parentDashboard = '/api/parents/dashboard';
  
  // Trips
  static const String tripsSearch = '/api/parents/trips/search';
  static const String tripsFilters = '/api/parents/trips/filters';
  static String tripDetails(String tripId) => 
      '/api/parents/trips/$tripId/details';
  static String tripRealtime(String tripId) => 
      '/api/parents/trips/$tripId/realtime';
  static String contactDriver(String tripId) => 
      '/api/parents/trips/$tripId/contact-driver';
  
  // Reservations
  static const String reservations = '/api/parents/reservations';
  static String cancelReservation(String tripId, String childId) =>
      '/api/parents/reservations/$tripId/$childId';
  
  // Account
  static const String parentAccount = '/api/parents/account';
  static const String parentAccountPhoto = '/api/parents/account/photo';
  
  // Alerts
  static const String parentAlertes = '/api/parents/alertes';
  
  // Carpool
  static const String carpoolGroups = '/api/parents/carpool/groups';
  static const String carpoolInvitations = '/api/parents/carpool/invitations';
  static const String carpoolCalendar = '/api/parents/carpool/calendar';
  static const String carpoolConduite = '/api/parents/carpool/conduite';

  static const String parentAllTrips = '/api/parents/trips';

  // ==================== DRIVER ENDPOINTS ====================
  
  // Dashboard
  static const String driverDashboard = '/api/drivers/dashboard';
  
  // Profile (GET and PUT use same endpoint)
  static const String driverProfile = '/api/drivers/profile';
  static String driverProfileById(String id) => '/api/drivers/$id/profile';
  
  // Admin endpoint to update driver by ID (for documents and vehicle)

  static String updateDriverById(String id) => '/api/drivers/$id';
  
  
  
  // Subscription
  static const String driverSubscription = '/api/drivers/subscription';
  static const String driverSubscriptionPlans = '/api/drivers/subscription/plans';
  static const String driverSubscriptionRenew = '/api/drivers/subscription/renew';
  static const String driverSubscriptionAlertes = '/api/drivers/subscription/alertes';
  static String driverSubscriptionCancel(String id) => 
      '/api/drivers/subscription/$id';
  static String driverSubscriptionPlanDelete(String id) => 
      '/api/drivers/subscription/plans/$id';
  static String driverSubscriptionPlanSetDefault(String id) => 
      '/api/drivers/subscription/plans/$id';
  
  // Transactions
  static const String driverTransactions = '/api/drivers/transactions';
  
  // Trips
  static const String driverTrips = '/api/drivers/trips';
  static String driverTripStart(String id) => '/api/drivers/trips/$id/start';
  static String driverTripCompleted(String id) => '/api/drivers/trips/$id/completed';
  static String driverTripCanceled(String id) => '/api/drivers/trips/$id/canceled';

  // ==================== MESSAGING ENDPOINTS ====================
  
  static const String conversations = '/api/conversations';
  static String conversationMessages(String id) => 
      '/api/conversations/$id/messages';
  static String conversationArchive(String id) => 
      '/api/conversations/$id/archive';
  static String conversationMute(String id) => 
      '/api/conversations/$id/mute';
  static const String conversationsGroup = '/api/conversations/group';
  static String messageById(String id) => '/api/messages/$id';

  // ==================== COMMON ENDPOINTS ====================
  
  // Evaluations
  static const String evaluations = '/api/evaluations';
  static String evaluationById(String id) => '/api/evaluations/$id';
  
  // Incidents
  static const String incidents = '/api/incidents';

  // ==================== NOTIFICATIONS ENDPOINTS ====================
  
  static const String notifications = '/api/notifications/user';
  static String notificationMarkAsRead(int id) => '/api/notifications/$id/read';
  static String notificationDelete(int id) => '/api/notifications/$id';

  // ==================== HEADERS ====================
  
  static const String contentType = 'application/json';
  static const String authorization = 'Authorization';

  // ==================== STORAGE KEYS ====================
  
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'user_data';

  // ==================== TIMEOUT ====================
  
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}