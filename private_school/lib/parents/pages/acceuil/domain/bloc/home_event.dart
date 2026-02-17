abstract class HomeEvent {}

// Event pour charger la liste des chauffeurs
class LoadDriversEvent extends HomeEvent {}

// Event pour vider le cache
class ClearHomeCache extends HomeEvent {}