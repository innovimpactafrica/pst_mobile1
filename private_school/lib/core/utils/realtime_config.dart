/// Configuration du suivi en temps réel
class RealtimeConfig {
  /// Intervalle d'envoi de position GPS (chauffeur)
  static const Duration locationUpdateInterval = Duration(seconds: 30);
  
  /// Intervalle de polling (parent)
  static const Duration pollingInterval = Duration(seconds: 5);
  
  /// Précision de la localisation
  static const bool highAccuracy = true;
  
  /// Distance minimale pour mettre à jour (en mètres)
  static const double distanceFilter = 10.0;
  
  /// Timeout pour obtenir la position
  static const Duration locationTimeout = Duration(seconds: 10);
  
  /// Durée maximale d'utilisation d'une position en cache
  static const Duration maximumAge = Duration(seconds: 30);
}
