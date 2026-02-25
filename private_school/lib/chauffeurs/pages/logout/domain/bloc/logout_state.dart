abstract class LogoutState {}

/// État initial
class LogoutInitial extends LogoutState {}

/// Déconnexion en cours
class LogoutLoading extends LogoutState {}

/// Déconnexion réussie
class LogoutSuccess extends LogoutState {}

/// Erreur lors de la déconnexion
class LogoutError extends LogoutState {
  final String message;

  LogoutError(this.message);
}
