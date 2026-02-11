import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
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
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Text(
                      initialGroup.name,
                      style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  // ✅ BOUTON INVITER — avec Builder pour bon contexte
                  Builder(
                    builder: (btnContext) {
                      return BlocBuilder<GroupBloc, GroupState>(
                        builder: (context, state) {
                          return IconButton(
                            icon: const Icon(Icons.person_add, color: Colors.white, size: 24),
                            onPressed: () {
                              final groupId = state is GroupDetailsLoaded
                                  ? state.group.id
                                  : initialGroup.id;
                              showModalBottomSheet(
                                context: context, // ✅ Utilise le contexte du BlocProvider
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (_) => InviteMemberModal(groupId: groupId),
                              );
                            },
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
                if (state is GroupDetailsLoaded) selectedTab = state.selectedTabIndex;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2)),
                      ],
                    ),
                    child: Row(
                      children: [
                        _buildTabButton(context, 'Planning', 0, selectedTab),
                        _buildTabButton(context, 'Membres(${initialGroup.membersCount})', 1, selectedTab),
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
                        content: Text('Planning créé avec succès ✅', style: GoogleFonts.inter()),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                  if (state is MemberInvited) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Invitation envoyée ✅', style: GoogleFonts.inter()),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                  if (state is ReplacementRequested) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Demande de remplacement envoyée', style: GoogleFonts.inter()),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                  if (state is GroupError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message, style: GoogleFonts.inter()),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  if (state is GroupLoading) {
                    return Center(child: CircularProgressIndicator(color: AppColors.success));
                  }
                  if (state is GroupDetailsLoaded) {
                    return _buildTabContent(context, state);
                  }
                  return _buildTabContent(context, GroupDetailsLoaded(group: initialGroup));
                },
              ),
            ),
          ],
        ),
      ),
      // ✅ FAB CRÉER PLANNING — avec Builder pour bon contexte
      floatingActionButton: Builder(
        builder: (fabContext) {
          return BlocBuilder<GroupBloc, GroupState>(
            builder: (context, state) {
              int selectedTab = 0;
              if (state is GroupDetailsLoaded) selectedTab = state.selectedTabIndex;

              if (selectedTab != 0) return const SizedBox.shrink();

              final groupId = state is GroupDetailsLoaded ? state.group.id : initialGroup.id;

              return FloatingActionButton(
                onPressed: () {
                  debugPrint('📅 [FAB] Opening CreatePlanningModal for group: $groupId');
                  showModalBottomSheet(
                    context: context, // ✅ Utilise le contexte du BlocProvider
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => CreatePlanningModal(groupId: groupId),
                  );
                },
                backgroundColor: AppColors.success,
                child: const Icon(Icons.add, color: Colors.white),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildTabButton(BuildContext context, String label, int tabIndex, int selectedTabIndex) {
    final isSelected = tabIndex == selectedTabIndex;
    return Expanded(
      child: GestureDetector(
        onTap: () => context.read<GroupBloc>().add(SelectGroupTabEvent(tabIndex)),
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          if (group.plannings.any((p) => !p.isConfirmed))
            Container(
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
                            Text('Planning à confirmer',
                                style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.orange.shade900)),
                            const SizedBox(height: 4),
                            Text(
                                'Veuillez confirmer votre disponibilité pour les jours où vous êtes assigné(e)',
                                style: GoogleFonts.inter(fontSize: 12, color: Colors.orange.shade800)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.orange.shade700, size: 20),
                        onPressed: () {},
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.shade700,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text('Confirmer', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ),
          if (group.plannings.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  children: [
                    Icon(Icons.calendar_today, size: 64, color: Colors.grey.shade300),
                    const SizedBox(height: 16),
                    Text('Aucun planning',
                        style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey.shade600)),
                    const SizedBox(height: 8),
                    Text('Créez votre premier planning',
                        style: GoogleFonts.inter(fontSize: 14, color: Colors.grey.shade500)),
                  ],
                ),
              ),
            )
          else
            ...group.plannings.map((planning) => _buildPlanningCard(context, planning, group)),
        ],
      ),
    );
  }

  Widget _buildPlanningCard(BuildContext context, Planning planning, GroupModel group) {
    String dateStr;
    try {
      dateStr = DateFormat('EEE. dd MMMM', 'fr_FR').format(planning.date);
    } catch (e) {
      dateStr = DateFormat('EEE. dd MMMM').format(planning.date);
    }
    final isYou = planning.assignedTo == 'Vous';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              if (planning.needsReplacement) ...[
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(color: Colors.orange.shade100, shape: BoxShape.circle),
                  child: Center(child: Icon(Icons.warning_amber, color: Colors.orange.shade700, size: 20)),
                ),
                const SizedBox(width: 12),
              ],
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: isYou ? AppColors.success.withValues(alpha: 0.2) : Colors.grey.shade200,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    isYou
                        ? 'MN'
                        : group.members.firstWhere((m) => m.name == planning.assignedTo,
                            orElse: () => GroupMember(id: '', name: planning.assignedTo, role: '', availability: '')).displayInitials,
                    style: GoogleFonts.inter(
                        fontSize: 14, fontWeight: FontWeight.bold, color: isYou ? AppColors.success : Colors.grey.shade700),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(dateStr, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87)),
                    const SizedBox(height: 2),
                    Text(planning.assignedTo, style: GoogleFonts.inter(fontSize: 13, color: Colors.grey.shade600)),
                  ],
                ),
              ),
              if (!planning.needsReplacement) ...[
                if (planning.isPending)
                  Text('En attente',
                      style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.orange.shade600))
                else if (planning.isConfirmed)
                  Icon(Icons.check_circle, color: AppColors.success, size: 20),
              ],
            ],
          ),
          if (isYou && !planning.needsReplacement) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => RequestReplacementModal(planning: planning),
                  );
                },
                icon: Icon(Icons.sync, color: Colors.orange.shade700, size: 18),
                label: Text('Remplacer ma journée',
                    style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.orange.shade700)),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.orange.shade200),
                  backgroundColor: Colors.orange.shade50,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ],
          if (planning.needsReplacement && planning.replacementReason != null) ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => RespondReplacementModal(planning: planning),
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.sync, color: Colors.orange.shade700, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text('Remplacement demandé',
                          style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.orange.shade900)),
                    ),
                    Icon(Icons.chevron_right, color: Colors.orange.shade700, size: 18),
                  ],
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
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Rechercher',
                hintStyle: GoogleFonts.inter(color: Colors.grey.shade400, fontSize: 14),
                prefixIcon: Icon(Icons.search, color: Colors.grey.shade500, size: 22),
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
                child: Text('Aucun membre', style: GoogleFonts.inter(fontSize: 14, color: Colors.grey.shade500)),
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
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.2), shape: BoxShape.circle),
            child: Center(
              child: Text(member.displayInitials,
                  style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.success)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(member.name, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87)),
                const SizedBox(height: 4),
                Text(member.role, style: GoogleFonts.inter(fontSize: 12, color: Colors.grey.shade600)),
              ],
            ),
          ),
          Text(member.availability,
              style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.success)),
        ],
      ),
    );
  }

  Widget _buildHistoryTab(BuildContext context, GroupModel group) {
    final historyItems = [
      {'date': 'Vendredi 24 janvier', 'time': '10:23', 'from': 'Moussa Fall', 'to': 'Aïssatou Diop', 'reason': 'déplacement personnelle'},
      {'date': 'Lundi 2 janvier', 'time': '08:14', 'from': 'Aïssatou Diop', 'to': 'Moussa Fall', 'reason': 'Panne de voiture'},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: historyItems.isEmpty
            ? [
                const SizedBox(height: 40),
                Icon(Icons.history, size: 64, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                Text('Aucun historique',
                    style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey.shade600)),
                const SizedBox(height: 8),
                Text('Les trajets passés apparaîtront ici',
                    style: GoogleFonts.inter(fontSize: 14, color: Colors.grey.shade500)),
              ]
            : historyItems
                .map((item) => Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 40, height: 40,
                            decoration: BoxDecoration(color: Colors.orange.shade50, shape: BoxShape.circle),
                            child: Center(child: Icon(Icons.sync, color: Colors.orange.shade600, size: 20)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item['date']!,
                                    style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87)),
                                const SizedBox(height: 4),
                                Text('${item['from']} → ${item['to']}',
                                    style: GoogleFonts.inter(fontSize: 14, color: Colors.grey.shade700)),
                                const SizedBox(height: 8),
                                Text('Raison : ${item['reason']}',
                                    style:
                                        GoogleFonts.inter(fontSize: 13, color: Colors.grey.shade600, fontStyle: FontStyle.italic)),
                              ],
                            ),
                          ),
                          Text(item['time']!, style: GoogleFonts.inter(fontSize: 13, color: Colors.grey.shade500)),
                        ],
                      ),
                    ))
                .toList(),
      ),
    );
  }
}