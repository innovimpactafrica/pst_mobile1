import '../models/ user_model.dart';


class UserRepository {
  // Récupère les infos de l'utilisateur connecté
  Future<UserModel> getCurrentUser() async {
    await Future.delayed(const Duration(milliseconds: 500));

    // Pour le moment, données en dur
    // Plus tard, ce sera un appel API
    return UserModel(
      id: 'user1',
      firstName: 'Mariama',
      lastName: 'Ly',
      phone: '+221 77 123 45 67',
      email: 'bdiop@gmail.com',
      address: 'Ouakam cité avions, Dakar',
      photo: '1.png',
      role: 'Parent',
    );
  }

  // Met à jour les infos de l'utilisateur
  Future<UserModel> updateUser(UserModel user) async {
    await Future.delayed(const Duration(milliseconds: 800));

    // Simuler la mise à jour
    return user;
  }

  // Déconnexion
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 300));
    // Supprimer le token, etc.
  }
}