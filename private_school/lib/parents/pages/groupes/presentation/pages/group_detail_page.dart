import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:private_school/parents/pages/authentification/domain/bloc/auth_bloc.dart';
import 'package:private_school/parents/pages/authentification/domain/bloc/auth_state.dart';
import 'package:private_school/parents/pages/groupes/presentation/widgets/confirm_planning_banner.dart';
import '../../domain/bloc/group_bloc.dart';
import '../../domain/bloc/group_event.dart';
import '../../domain/bloc/group_state.dart';
import '../../data/repositories/group_repository.dart';
import '../../data/models/group_model.dart';
import '../widgets/create_planning_modal.dart';
import '../widgets/invite_member_modal.dart';
import '../widgets/request_replacement_modal.dart';
import '../widgets/respond_replacement_modal.dart';
import 'package:private_school/core/utils/app_colors.dart';

class GroupDetailPage extends StatefulWidget {
  final GroupModel group;

  const GroupDetailPage({super.key, required this.group});

  @override
  State<GroupDetailPage> createState() => _GroupDetailPageState();
}

class _GroupDetailPageState extends State<GroupDetailPage> {
  bool _localeInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeLocale();
  }

  Future<void> _initializeLocale() async {
    try {
      await initializeDateFormatting('fr_FR', null);
      if (mounted) {
        setState(() {
          _localeInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Error initializing locale: $e');
      if (mounted) {
        setState(() {
          _localeInitialized = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_localeInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return BlocProvider(
      create: (context) =>
          GroupBloc(repository: GroupRepository())
            ..add(LoadGroupDetailsEvent(widget.group.id)),
      child: GroupDetailPageContent(initialGroup: widget.group),
    );
  }
}

class GroupDetailPageContent extends StatelessWidget {
  final GroupModel initialGroup;

  const GroupDetailPageContent({super.key, required this.initialGroup});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Column(
          children: [
            // HEADER VERT
            Container(
              color: AppColors.success,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Text(
                      initialGroup.name,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  // ✅ BOUTON INVITER — CORRIGÉ avec BlocProvider.value
                  BlocBuilder<GroupBloc, GroupState>(
                    builder: (context, state) {
                      return IconButton(
                        icon: const Icon(
                          Icons.person_add,
                          color: Colors.white,
                          size: 24,
                        ),
                        onPressed: () {
                          final groupId = state is GroupDetailsLoaded
                              ? state.group.id
                              : initialGroup.id;
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) => BlocProvider.value(
                              value: context
                                  .read<GroupBloc>(), // ✅ PARTAGE le BLoC
                              child: InviteMemberModal(groupId: groupId),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // TABS
            BlocBuilder<GroupBloc, GroupState>(
              builder: (context, state) {
                int selectedTab = 0;
                if (state is GroupDetailsLoaded) {
                  selectedTab = state.selectedTabIndex;
                }
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        _buildTabButton(context, 'Planning', 0, selectedTab),
                        _buildTabButton(
                          context,
                          'Membres(${initialGroup.membersCount})',
                          1,
                          selectedTab,
                        ),
                        _buildTabButton(context, 'Historiques', 2, selectedTab),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            // CONTENU DES TABS
            Expanded(
              child: BlocConsumer<GroupBloc, GroupState>(
                listener: (context, state) {
                  if (state is PlanningCreated) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Planning créé avec succès ✅',
                          style: GoogleFonts.inter(),
                        ),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                  if (state is PlanningConfirmed) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Planning confirmé ✅',
                          style: GoogleFonts.inter(),
                        ),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                  if (state is MemberInvited) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Invitation envoyée ✅',
                          style: GoogleFonts.inter(),
                        ),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                  if (state is ReplacementRequested) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Demande de remplacement envoyée',
                          style: GoogleFonts.inter(),
                        ),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                  if (state is GroupError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          state.message,
                          style: GoogleFonts.inter(),
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  if (state is GroupLoading) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: AppColors.success,
                      ),
                    );
                  }
                  if (state is GroupDetailsLoaded) {
                    return _buildTabContent(context, state);
                  }
                  return _buildTabContent(
                    context,
                    GroupDetailsLoaded(group: initialGroup),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      // ✅ FAB CRÉER PLANNING — CORRIGÉ avec BlocProvider.value
      floatingActionButton: BlocBuilder<GroupBloc, GroupState>(
        builder: (context, state) {
          int selectedTab = 0;
          if (state is GroupDetailsLoaded) selectedTab = state.selectedTabIndex;

          if (selectedTab != 0) return const SizedBox.shrink();

          final groupId = state is GroupDetailsLoaded
              ? state.group.id
              : initialGroup.id;

          return FloatingActionButton(
            onPressed: () {
              debugPrint(
                '📅 [FAB] Opening CreatePlanningModal for group: $groupId',
              );
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => BlocProvider.value(
                  value: context.read<GroupBloc>(), // ✅ PARTAGE le BLoC
                  child: CreatePlanningModal(groupId: groupId),
                ),
              );
            },
            backgroundColor: AppColors.success,
            child: const Icon(Icons.add, color: Colors.white),
          );
        },
      ),
    );
  }

  Widget _buildTabButton(
    BuildContext context,
    String label,
    int tabIndex,
    int selectedTabIndex,
  ) {
    final isSelected = tabIndex == selectedTabIndex;
    return Expanded(
      child: GestureDetector(
        onTap: () =>
            context.read<GroupBloc>().add(SelectGroupTabEvent(tabIndex)),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.success : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? Colors.white : Colors.grey.shade600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent(BuildContext context, GroupDetailsLoaded state) {
    switch (state.selectedTabIndex) {
      case 0:
        return _buildPlanningTab(context, state.group);
      case 1:
        return _buildMembersTab(context, state.group);
      case 2:
        return _buildHistoryTab(context, state.group);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildPlanningTab(BuildContext context, GroupModel group) {
  final now = DateTime.now();
  final todayPlannings = group.plannings.where((p) {
    return p.date.year == now.year &&
        p.date.month == now.month &&
        p.date.day == now.day;
  }).toList();

  String currentUserId = '';
  final authState = context.read<AuthBloc>().state;
  if (authState is AuthAuthenticated && authState.user != null) {
    currentUserId = authState.user!.id;
  } else if (authState is UserLoaded) {
    currentUserId = authState.user.id;
  }

  // ✅ Séparer les plannings
  final pendingReplacements = todayPlannings
      .where((p) => p.needsReplacement)
      .toList();
  
  // ✅ Plannings qui nécessitent confirmation
  final needsConfirmation = todayPlannings.where((p) {
    final isMyTurn = p.isMyTurn == true || 
                    p.driverId == currentUserId ||
                    (p.driverId == null && group.creatorId == currentUserId);
    
    return isMyTurn && !p.isConfirmed && !p.needsReplacement;
  }).toList();
  
  final otherPlannings = todayPlannings
      .where((p) => !pendingReplacements.contains(p) && !needsConfirmation.contains(p))
      .toList();

  return SingleChildScrollView(
    padding: const EdgeInsets.all(20),
    child: Column(
      children: [
        //  Banner de confirmation EN PREMIER
        if (needsConfirmation.isNotEmpty)
          ...needsConfirmation.map(
            (planning) => ConfirmPlanningBanner(
              planningId: planning.id,
              groupId: group.id,
            ),
          ),

        // Cards de remplacement
        if (pendingReplacements.isNotEmpty)
          ...pendingReplacements.map(
            (planning) => _buildPendingReplacementCard(context, planning, group),
          ),

        // Message vide
        if (todayPlannings.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                children: [
                  Icon(Icons.calendar_today, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text('Aucun planning aujourd\'hui',
                      style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey.shade600)),
                  const SizedBox(height: 8),
                  Text('Créez votre premier planning',
                      style: GoogleFonts.inter(fontSize: 14, color: Colors.grey.shade500)),
                ],
              ),
            ),
          )
        else
          ...otherPlannings.map(
            (planning) => _buildPlanningCard(context, planning, group),
          ),
      ],
    ),
  );
}

  Widget _buildPendingReplacementCard(
    BuildContext context,
    Planning planning,
    GroupModel group,
  ) {
    String dateStr;
    try {
      dateStr = DateFormat('EEE. dd MMMM', 'fr_FR').format(planning.date);
      dateStr = dateStr[0].toUpperCase() + dateStr.substring(1);
    } catch (e) {
      dateStr = DateFormat('EEE. dd MMMM').format(planning.date);
      dateStr = dateStr[0].toUpperCase() + dateStr.substring(1);
    }

    String currentUserId = '';
    final authState = context.read<AuthBloc>().state;

    if (authState is AuthAuthenticated && authState.user != null) {
      currentUserId = authState.user!.id;
    } else if (authState is UserLoaded) {
      currentUserId = authState.user.id;
    }

    bool isMyRequest =
        planning.isMyTurn == true || planning.driverId == currentUserId;

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber, color: Colors.orange.shade700),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isMyRequest
                          ? 'Demande de remplacement en attente'
                          : 'Remplacement demandé',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.orange.shade900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dateStr,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.orange.shade800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (!isMyRequest) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => BlocProvider.value(
                      value: context.read<GroupBloc>(),
                      child: RespondReplacementModal(planning: planning),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Répondre',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPlanningCard(
    BuildContext context,
    Planning planning,
    GroupModel group,
  ) {
    String dateStr;
    try {
      dateStr = DateFormat('EEE. dd MMMM', 'fr_FR').format(planning.date);
      dateStr = dateStr[0].toUpperCase() + dateStr.substring(1);
    } catch (e) {
      dateStr = DateFormat('EEE. dd MMMM').format(planning.date);
      dateStr = dateStr[0].toUpperCase() + dateStr.substring(1);
    }

    // ✅ Récupérer les informations de l'utilisateur connecté
    String currentUserInitials = 'MN';
    String currentUserId = '';
    final authState = context.read<AuthBloc>().state;

    if (authState is AuthAuthenticated && authState.user != null) {
      currentUserInitials = authState.user!.initials;
      currentUserId = authState.user!.id;
    } else if (authState is UserLoaded) {
      currentUserInitials = authState.user.initials;
      currentUserId = authState.user.id;
    }

    debugPrint('🔍 [PlanningCard] Planning ID: ${planning.id}');
    debugPrint('   Date: ${planning.date}');
    debugPrint('   driver_id: ${planning.driverId}');
    debugPrint('   driver_name: ${planning.driverName}');
    debugPrint('   is_my_turn: ${planning.isMyTurn}');
    debugPrint('   status: ${planning.status}');
    debugPrint('   currentUserId: $currentUserId');
    debugPrint('   group.creatorId: ${group.creatorId}');

    // ✅ NOUVELLE LOGIQUE : Déterminer l'état du planning
    bool isMyTurn = false;
    bool isUnassigned =
        planning.driverName == null && planning.driverId == null;

    // Si pas de driver assigné ET que je suis le créateur du groupe
    // OU si is_my_turn est explicitement true
    // OU si driver_id correspond à mon ID
    if (planning.isMyTurn == true) {
      isMyTurn = true;
    } else if (planning.driverId != null &&
        planning.driverId == currentUserId) {
      isMyTurn = true;
    } else if (isUnassigned && group.creatorId == currentUserId) {
      // ✅ SI non assigné ET je suis créateur → c'est mon tour par défaut
      isMyTurn = true;
      isUnassigned = false; // Ce n'est plus "non assigné", c'est MON tour
    }

    final bool needsReplacement = planning.needsReplacement;
    final bool isConfirmed = planning.isConfirmed;

    debugPrint('   → isMyTurn: $isMyTurn');
    debugPrint('   → isUnassigned: $isUnassigned');

    // ✅ Vérifier si le remplacement a été accepté
    final bool replacementAccepted = planning.isReplacementAccepted;

    // ✅ Définir l'affichage selon l'état
    String displayName;
    String displayInitials;
    Color avatarColor;
    Color initialsColor;

    if (replacementAccepted && planning.replacementAcceptedByName != null) {
      // État 5 : Remplacement accepté par quelqu'un
      displayName = planning.replacementAcceptedByName!;
      final nameParts = displayName.split(' ');
      displayInitials = nameParts
          .map((n) => n.isNotEmpty ? n[0] : '')
          .take(2)
          .join()
          .toUpperCase();
      avatarColor = AppColors.success.withValues(alpha: 0.2);
      initialsColor = AppColors.success;
    } else if (isUnassigned) {
      // État 1 : Non assigné (vraiment personne)
      displayName = 'Non assigné';
      displayInitials = 'NA';
      avatarColor = Colors.grey.shade200;
      initialsColor = Colors.grey.shade700;
    } else if (isMyTurn) {
      // États 2 & 3 : C'est mon tour
      displayName = 'Vous';
      displayInitials = currentUserInitials;
      avatarColor = AppColors.success.withValues(alpha: 0.2);
      initialsColor = AppColors.success;
    } else {
      // État 4 : Quelqu'un d'autre
      displayName = planning.driverName ?? 'Non assigné';
      final nameParts = displayName.split(' ');
      displayInitials = nameParts
          .map((n) => n.isNotEmpty ? n[0] : '')
          .take(2)
          .join()
          .toUpperCase();
      avatarColor = Colors.grey.shade200;
      initialsColor = Colors.grey.shade700;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // ✅ AVATAR
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: avatarColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    displayInitials,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: initialsColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // ✅ DATE ET NOM
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dateStr,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      displayName,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              // ✅ BADGE/ICÔNE DE STATUT
              if (isUnassigned && !needsReplacement)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'En attente',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Colors.orange.shade700,
                    ),
                  ),
                )
              else if (replacementAccepted)
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 18),
                )
              else if (isConfirmed && !isMyTurn)
                Icon(Icons.check_circle, color: AppColors.success, size: 20),
            ],
          ),

          // ✅ BOUTON "Remplacer ma journée"
          if (isMyTurn && isConfirmed && !needsReplacement && !replacementAccepted) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  debugPrint('🔄 [PlanningCard] Button pressed');

                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => BlocProvider.value(
                      value: context.read<GroupBloc>(),
                      child: RequestReplacementModal(planning: planning),
                    ),
                  );
                },
                icon: Icon(Icons.sync, color: Colors.orange.shade700, size: 18),
                label: Text(
                  'Remplacer ma journée',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.orange.shade700,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.orange.shade200),
                  backgroundColor: Colors.orange.shade50,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMembersTab(BuildContext context, GroupModel group) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Rechercher',
                hintStyle: GoogleFonts.inter(
                  color: Colors.grey.shade400,
                  fontSize: 14,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.grey.shade500,
                  size: 22,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 20),
          if (group.members.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Text(
                  'Aucun membre',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                  ),
                ),
              ),
            )
          else
            ...group.members.map((member) => _buildMemberCard(member)),
        ],
      ),
    );
  }

  Widget _buildMemberCard(GroupMember member) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                member.displayInitials,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.success,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.name,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  member.role,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Text(
            member.availability,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.success,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab(BuildContext context, GroupModel group) {
    final historyItems = [
      {
        'date': 'Vendredi 24 janvier',
        'time': '10:23',
        'from': 'Moussa Fall',
        'to': 'Aïssatou Diop',
        'reason': 'déplacement personnelle',
      },
      {
        'date': 'Lundi 2 janvier',
        'time': '08:14',
        'from': 'Aïssatou Diop',
        'to': 'Moussa Fall',
        'reason': 'Panne de voiture',
      },
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: historyItems.isEmpty
            ? [
                const SizedBox(height: 40),
                Icon(Icons.history, size: 64, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                Text(
                  'Aucun historique',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Les trajets passés apparaîtront ici',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                  ),
                ),
              ]
            : historyItems
                  .map(
                    (item) => Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Icon(
                                Icons.sync,
                                color: Colors.orange.shade600,
                                size: 20,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['date']!,
                                  style: GoogleFonts.inter(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${item['from']} → ${item['to']}',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Raison : ${item['reason']}',
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: Colors.grey.shade600,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            item['time']!,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
      ),
    );
  }
}
