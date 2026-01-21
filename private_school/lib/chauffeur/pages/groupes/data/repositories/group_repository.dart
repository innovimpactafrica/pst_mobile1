import '../models/group_model.dart';

class GroupRepository {
  // Simulation d'une base de données en mémoire
  final Map<String, GroupModel> _myGroups = {};
  final Map<String, GroupModel> _availableGroups = {};

  GroupRepository() {
    // Initialiser MES GROUPES avec des données de test
    final senCov = GroupModel.sample();
    _myGroups[senCov.id] = senCov;

    // Ajouter Trans Cov
    final transCov = GroupModel(
      id: 'group_2',
      name: 'Trans Cov',
      createdBy: 'Fatou Diop',
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
      membersCount: 4,
      description: 'Groupe de transport pour le travail',
      avatar: 'T',
      members: [
        GroupMember(
          id: 'member_t1',
          name: 'Fatou Diop',
          role: 'Administrateur',
          availability: '5 jours/sem',
          initials: 'FD',
        ),
        GroupMember(
          id: 'member_t2',
          name: 'Ousmane Sow',
          role: 'Membre',
          availability: '4 jours/sem',
          initials: 'OS',
        ),
        GroupMember(
          id: 'member_t3',
          name: 'Aida Sarr',
          role: 'Membre',
          availability: '3 jours/sem',
          initials: 'AS',
        ),
        GroupMember(
          id: 'member_t4',
          name: 'Ibrahima Kane',
          role: 'Membre',
          availability: '4 jours/sem',
          initials: 'IK',
        ),
      ],
      plannings: [],
    );
    _myGroups[transCov.id] = transCov;

    // Initialiser GROUPES DISPONIBLES
    final expressCov1 = GroupModel(
      id: 'group_available_1',
      name: 'Express Cov',
      createdBy: 'Abdou Diallo',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      membersCount: 7,
      description: 'Groupe de covoiturage express pour le centre ville',
      avatar: 'E',
      members: [
        GroupMember(
          id: 'member_e1',
          name: 'Abdou Diallo',
          role: 'Administrateur',
          availability: '5 jours/sem',
          initials: 'AD',
        ),
        GroupMember(
          id: 'member_e2',
          name: 'Marie Faye',
          role: 'Membre',
          availability: '4 jours/sem',
          initials: 'MF',
        ),
        GroupMember(
          id: 'member_e3',
          name: 'Samba Diop',
          role: 'Membre',
          availability: '3 jours/sem',
          initials: 'SD',
        ),
      ],
      plannings: [],
    );
    _availableGroups[expressCov1.id] = expressCov1;

    final expressCov2 = GroupModel(
      id: 'group_available_2',
      name: 'Express Cov',
      createdBy: 'Cheikh Ndiaye',
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      membersCount: 5,
      description: 'Covoiturage rapide pour le plateau',
      avatar: 'E',
      members: [
        GroupMember(
          id: 'member_e4',
          name: 'Cheikh Ndiaye',
          role: 'Administrateur',
          availability: '5 jours/sem',
          initials: 'CN',
        ),
        GroupMember(
          id: 'member_e5',
          name: 'Aminata Ba',
          role: 'Membre',
          availability: '4 jours/sem',
          initials: 'AB',
        ),
      ],
      plannings: [],
    );
    _availableGroups[expressCov2.id] = expressCov2;

    final ecoCov = GroupModel(
      id: 'group_available_3',
      name: 'Eco Cov',
      createdBy: 'Mamadou Dieng',
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
      membersCount: 6,
      description: 'Covoiturage écologique et économique',
      avatar: 'E',
      members: [
        GroupMember(
          id: 'member_ec1',
          name: 'Mamadou Dieng',
          role: 'Administrateur',
          availability: '5 jours/sem',
          initials: 'MD',
        ),
      ],
      plannings: [],
    );
    _availableGroups[ecoCov.id] = ecoCov;
  }

  // ========== MÉTHODES POUR LES LISTES ==========

  /// Récupérer mes groupes (groupes dont je suis membre)
  Future<List<GroupModel>> getMyGroups() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _myGroups.values.toList();
  }

  /// Récupérer les groupes disponibles (pour rejoindre)
  Future<List<GroupModel>> getAvailableGroups() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _availableGroups.values.toList();
  }

  // ========== MÉTHODES POUR UN GROUPE SPÉCIFIQUE ==========

  /// Récupérer un groupe par son ID
  Future<GroupModel> getGroupById(String groupId) async {
    await Future.delayed(const Duration(milliseconds: 500));

    // Chercher d'abord dans mes groupes
    if (_myGroups.containsKey(groupId)) {
      return _myGroups[groupId]!;
    }

    // Puis dans les groupes disponibles
    if (_availableGroups.containsKey(groupId)) {
      return _availableGroups[groupId]!;
    }

    throw Exception('Group not found');
  }

  /// Alias pour getGroupById (pour compatibilité)
  Future<GroupModel> getGroupDetails(String groupId) async {
    return getGroupById(groupId);
  }

  // ========== MÉTHODES DE CRÉATION ==========

  /// Créer un nouveau groupe
  Future<GroupModel> createGroup({
    required String name,
    required List<String> memberEmails,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));

    final now = DateTime.now();
    final newGroup = GroupModel(
      id: 'group_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      createdBy: 'current_user_id',
      createdAt: now,
      membersCount: memberEmails.length + 1, // +1 pour le créateur
      members: [
        GroupMember(
          id: 'member_me',
          name: 'Moi',
          role: 'Administrateur',
          availability: '5 jours/sem',
        ),
        ...memberEmails.asMap().entries.map((entry) {
          return GroupMember(
            id: 'member_${entry.key}',
            name: entry.value.split('@')[0], // Utilise l'email comme nom temporaire
            role: 'Membre',
            availability: 'Non défini',
          );
        }),
      ],
      plannings: [],
      description: null,
      avatar: name.substring(0, 1).toUpperCase(),
    );

    _myGroups[newGroup.id] = newGroup;
    return newGroup;
  }

  // ========== MÉTHODES POUR LES MEMBRES ==========

  /// Inviter un membre au groupe (par email OU téléphone)
  Future<void> inviteMember({
    required String groupId,
    String? email,   // Optionnel
    String? phone,   // Optionnel
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));

    if (!_myGroups.containsKey(groupId)) {
      throw Exception('Group not found');
    }

    // Validation : au moins un des deux doit être fourni
    if ((email == null || email.isEmpty) && (phone == null || phone.isEmpty)) {
      throw Exception('Email ou téléphone requis');
    }

    final group = _myGroups[groupId]!;

    // Utiliser l'email ou le téléphone pour générer un nom temporaire
    String memberName;
    if (email != null && email.isNotEmpty) {
      memberName = email.split('@')[0];
    } else if (phone != null && phone.isNotEmpty) {
      memberName = phone;
    } else {
      memberName = 'Nouveau membre';
    }

    final newMember = GroupMember(
      id: 'member_${DateTime.now().millisecondsSinceEpoch}',
      name: memberName,
      role: 'Membre',
      availability: 'Non défini',
    );

    final updatedMembers = [...group.members, newMember];

    final updatedGroup = group.copyWith(
      members: updatedMembers,
      membersCount: updatedMembers.length,
    );

    _myGroups[groupId] = updatedGroup;
  }

  /// Rejoindre un groupe
  Future<void> joinGroup(String groupId) async {
    await Future.delayed(const Duration(milliseconds: 800));

    // Le groupe doit être dans les groupes disponibles
    if (!_availableGroups.containsKey(groupId)) {
      throw Exception('Group not found in available groups');
    }

    final group = _availableGroups[groupId]!;

    // Ajouter l'utilisateur actuel comme membre
    final newMember = GroupMember(
      id: 'member_me_${DateTime.now().millisecondsSinceEpoch}',
      name: 'Moi',
      role: 'Membre',
      availability: 'Non défini',
    );

    final updatedMembers = [...group.members, newMember];

    final updatedGroup = group.copyWith(
      members: updatedMembers,
      membersCount: updatedMembers.length,
    );

    // Déplacer le groupe des groupes disponibles vers mes groupes
    _availableGroups.remove(groupId);
    _myGroups[groupId] = updatedGroup;
  }

  // ========== MÉTHODES POUR LES PLANNINGS ==========

  /// Créer un planning pour le groupe
  Future<void> createPlanning({
    required String groupId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));

    if (!_myGroups.containsKey(groupId)) {
      throw Exception('Group not found');
    }

    final group = _myGroups[groupId]!;
    final newPlannings = <Planning>[];

    // Créer un planning pour chaque jour entre startDate et endDate
    DateTime currentDate = startDate;
    int memberIndex = 0;

    while (currentDate.isBefore(endDate) || currentDate.isAtSameMomentAs(endDate)) {
      final member = group.members[memberIndex % group.members.length];

      newPlannings.add(Planning(
        id: 'planning_${currentDate.millisecondsSinceEpoch}',
        date: currentDate,
        assignedTo: member.name,
        status: 'pending',
      ));

      currentDate = currentDate.add(const Duration(days: 1));
      memberIndex++;
    }

    final updatedPlannings = [...group.plannings, ...newPlannings];

    final updatedGroup = group.copyWith(plannings: updatedPlannings);
    _myGroups[groupId] = updatedGroup;
  }

  /// Créer un planning simple (avec objet Planning)
  Future<GroupModel> createPlanningWithObject({
    required String groupId,
    required Planning planning,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));

    if (!_myGroups.containsKey(groupId)) {
      throw Exception('Group not found');
    }

    final group = _myGroups[groupId]!;
    final updatedPlannings = [...group.plannings, planning];

    final updatedGroup = group.copyWith(plannings: updatedPlannings);
    _myGroups[groupId] = updatedGroup;

    return updatedGroup;
  }

  /// Confirmer un planning
  Future<GroupModel> confirmPlanning({
    required String groupId,
    required String planningId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    if (!_myGroups.containsKey(groupId)) {
      throw Exception('Group not found');
    }

    final group = _myGroups[groupId]!;
    final updatedPlannings = group.plannings.map((p) {
      if (p.id == planningId) {
        return p.copyWith(status: 'confirmed');
      }
      return p;
    }).toList();

    final updatedGroup = group.copyWith(plannings: updatedPlannings);
    _myGroups[groupId] = updatedGroup;

    return updatedGroup;
  }

  // ========== MÉTHODES POUR LES REMPLACEMENTS ==========

  /// Demander un remplacement pour un planning
  Future<void> requestReplacement({
    required String planningId,
    required String reason,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));

    // Trouver le groupe qui contient ce planning
    for (final group in _myGroups.values) {
      final planningIndex = group.plannings.indexWhere((p) => p.id == planningId);

      if (planningIndex != -1) {
        final updatedPlannings = List<Planning>.from(group.plannings);
        updatedPlannings[planningIndex] = updatedPlannings[planningIndex].copyWith(
          status: 'replacement_requested',
          replacementReason: reason,
        );

        final updatedGroup = group.copyWith(plannings: updatedPlannings);
        _myGroups[group.id] = updatedGroup;
        return;
      }
    }

    throw Exception('Planning not found');
  }

  /// Répondre à une demande de remplacement
  Future<void> respondToReplacement({
    required String planningId,
    required bool accept,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));

    // Trouver le groupe qui contient ce planning
    for (final group in _myGroups.values) {
      final planningIndex = group.plannings.indexWhere((p) => p.id == planningId);

      if (planningIndex != -1) {
        final updatedPlannings = List<Planning>.from(group.plannings);

        if (accept) {
          // Si accepté, marquer comme confirmé avec le nouveau membre
          updatedPlannings[planningIndex] = updatedPlannings[planningIndex].copyWith(
            status: 'confirmed',
            assignedTo: 'Nouveau membre', // À remplacer par le vrai nom
            replacementReason: null,
          );
        } else {
          // Si refusé, remettre en attente
          updatedPlannings[planningIndex] = updatedPlannings[planningIndex].copyWith(
            status: 'pending',
          );
        }

        final updatedGroup = group.copyWith(plannings: updatedPlannings);
        _myGroups[group.id] = updatedGroup;
        return;
      }
    }

    throw Exception('Planning not found');
  }
}