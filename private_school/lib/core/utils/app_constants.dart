
class AppConstants {
  AppConstants._();

  // Splash & Assets
  static const int splashDuration = 3;
  static const String logoPath = 'assets/images/2.jpg';
  static const String decorationBlueShape = 'assets/icons/2.svg';
  static const String decorationGreenShape = 'assets/icons/3.svg';
  static const double logoWidth = 165.0;
  static const double logoHeight = 199.0;
  static const double largeShapeSize = 150.0;
  static const double mediumShapeSize = 120.0;
  static const double shapeRotationAngle = -0.35;

  // Spacing
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 12.0;
  static const double spacingXL = 16.0;
  static const double spacingXXL = 24.0;
  static const double spacingXXXL = 32.0;

  // Padding
  static const double paddingS = 8.0;
  static const double paddingM = 12.0;
  static const double paddingL = 20.0;

  // Radius
  static const double radiusS = 4.0;
  static const double radiusM = 6.0;
  static const double radiusL = 12.0;
  static const double radiusXL = 24.0;
  static const double radiusXXL = 30.0;

  // Font Sizes
  static const double fontSizeXS = 10.0;
  static const double fontSizeS = 12.0;
  static const double fontSizeM = 14.0;
  static const double fontSizeL = 16.0;
  static const double fontSizeXL = 18.0;
  static const double fontSizeXXL = 24.0;
  static const double fontSizeXXXL = 24.0;
  static const double fontSizeHuge = 48.0;

  // Icon Sizes
  static const double iconSizeS = 16.0;
  static const double iconSizeM = 20.0;
  static const double iconSizeL = 24.0;
  static const double iconSizeXL = 32.0;
  static const double iconSizeXXL = 48.0;
  static const double iconSizeXXXL = 64.0;

  // Avatar Sizes
  static const double avatarSizeS = 24.0;
  static const double avatarSizeM = 32.0;
  static const double avatarSizeL = 48.0;
  static const double avatarSizeXL = 64.0;

  // Map
  static const double mapHeight = 250.0;
  static const double mapBorderRadius = 16.0;

  // Modal
  static const double modalHeightFactor = 0.7;
  static const double modalHeightFactorMedium = 0.7;
  static const double modalHeightFactorSmall = 0.5;
  static const double modalHandleWidth = 40.0;
  static const double modalHandleHeight = 4.0;

  // File Upload
  static const int maxFileSizeKB = 10240; // 10 MB
  static const List<String> allowedDocumentExtensions = ['pdf', 'jpg', 'jpeg', 'png'];

  // Labels - General
  static const String labelRetry = "Réessayer";
  static const String labelToday = "Aujourd'hui";
  static const String labelTomorrow = "Demain";
  static const String labelViewAll = "Voir plus";

  // Labels - Documents
  static const String labelDocuments = 'Mes Documents';
  static const String labelLicense = 'Permis de conduire';
  static const String labelIdCard = 'CNI/Passeport';
  static const String labelUpdate = 'Mettre à jour les documents';
  static const String labelValidated = 'Validé ✓';
  static const String labelCurrentDocument = 'Document actuel';
  static const String labelChooseFile = 'Choisissez un fichier';
  static const String labelBrowse = 'Parcourir';
  static const String labelChangeFile = 'Changer le fichier';
  static const String labelReplaceFile = 'Remplacer le fichier';
  static const String labelFormats = 'Formats: JPEG, PNG, PDF jusqu\'à 10 Mo';
  static const String labelInfoMessage = 'Vous pouvez mettre à jour vos documents existants';

  // Labels - Vehicle
  static const String labelVehicle = 'Mon Véhicule';
  static const String labelBrand = 'Marque du véhicule';
  static const String labelColor = 'Couleur';
  static const String labelPlate = 'Plaque d\'immatriculation';
  static const String labelCapacity = 'Nombre de places';
  static const String labelEdit = 'Modifier les informations';
  static const String labelSave = 'Enregistrer les modifications';
  static const String labelCancel = 'Annuler';
  static const String labelTakePhoto = 'Prendre une photo';
  static const String labelGallery = 'Galerie';

  // Hints - Vehicle
  static const String hintBrand = 'Ex: Toyota';
  static const String hintColor = 'Ex: Blanc';
  static const String hintPlate = 'Ex: DK-XXXX-XX';
  static const String hintCapacity = 'Ex: 4';

  // Labels - Trips
  static const String labelMyTrips = "Mes trajets";
  static const String labelUpcoming = "À venir";
  static const String labelHistory = "Historique";
  static const String labelNoUpcomingTrips = "Aucun trajet à venir";
  static const String labelNoHistory = "Aucun historique";
  static const String labelPassengers = "Passagers";
  static const String labelSchools = "Écoles desservies";
  static const String labelStartPoint = "Point de départ";
  static const String labelDestination = "Destination";
  static const String labelAccept = "Accepter";
  static const String labelReject = "Rejeter";
  static const String labelStartTrip = "Démarrer le trajet";
  static const String labelCancelTrip = "Annuler le trajet";
  static const String labelNoPassengers = "Aucun passager";
  static const String labelSchoolNotSpecified = "École non spécifiée";
  static const String labelNoSchools = "Aucune école";

  // Labels - Dashboard
  static const String labelHome = "Accueil";
  static const String labelDashboard = "Tableau de bord";
  static const String labelGreeting = "Bonjour,";
  static const String labelTotalTrips = "Total trajets";
  static const String labelCompletedTrips = "Trajets terminés";
  static const String labelUpcomingTripsShort = "À venir";
  static const String labelTotalEarnings = "Gains totaux";
  static const String labelMonthlyEarnings = "Gains du mois";
  static const String labelActivePassengers = "Passagers actifs";
  static const String labelRating = "Note moyenne";
  static const String labelRecentTrips = "Trajets récents";
  static const String labelProfile = "Profil";
  static const String labelSubscription = "Abonnement";
  static const String labelSubscriptionActive = "Actif";
  static const String labelSubscriptionExpired = "Expiré";
  static const String labelDaysRemaining = "jours restants";

  // Labels - Navigation
  static const String labelTransactions = "Transactions";
  static const String labelStart = "Commencer";
  static const String labelNotifications = "Notifications";
  static const String labelRecentNotifications = "Notifications récentes";
  static const String labelViewAllNotifications = "Voir tout";

  // Notification badge
  static const double notificationBadgeSize = 8.0;

  // Status
  static const String statusPending = "pending";
  static const String statusActive = "active";
  static const String statusStarted = "started";
  static const String statusCompleted = "completed";
  static const String statusCanceled = "canceled";
  static const String statusInProgress = 'in_progress';

  // Success messages - Documents
  static const String successFileSelected = 'Fichier sélectionné avec succès';
  static const String successUpload = 'Documents mis à jour avec succès';

  // Success messages - Vehicle
  static const String successVehicleUpdate = 'Véhicule mis à jour avec succès !';

  // Success messages - Trips
  static const String successTripAccepted = "Trajet accepté avec succès";
  static const String successTripStarted = "Trajet démarré";
  static const String successTripCompleted = "Trajet terminé";
  static const String successTripCanceled = "Trajet annulé";

  // Error messages - Documents
  static const String errorFileTooBig = 'Le fichier est trop volumineux. Maximum 10 Mo.';
  static const String errorPickFile = 'Erreur lors de la sélection du fichier';
  static const String errorNoFile = 'Veuillez sélectionner au moins un document à mettre à jour';
  static const String errorUpload = 'Erreur lors de l\'upload';
  static const String errorNoDriverId = 'Erreur: ID du chauffeur introuvable';

  // Error messages - General
  static const String errorUpdate = 'Erreur';

  // Error messages - Trips
  static const String errorLoadTrips = "Failed to load trips";
  static const String errorCreateTrip = "Failed to create trip";
  static const String errorStartTrip = "Failed to start trip";
  static const String errorCompleteTrip = "Failed to complete trip";
  static const String errorCancelTrip = "Failed to cancel trip";

  // Assets
  static const String welcomeBackgroundImage = 'assets/images/1.png';

  // Welcome
  static const String welcomeTitle1 = "Bienvenue sur Private";
  static const String welcomeTitle2 = "School Transport";
  static const String welcomeDescription = "Votre partenaire de confiance pour le confort et la ponctualité au service des élèves.";
}