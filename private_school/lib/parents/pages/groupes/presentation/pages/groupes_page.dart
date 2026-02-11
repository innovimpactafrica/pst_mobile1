import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../domain/bloc/group_bloc.dart';
import '../../domain/bloc/group_event.dart';
import '../../domain/bloc/group_state.dart';
import '../../data/repositories/group_repository.dart';
import '../../data/models/group_model.dart';
import '../widgets/join_group_modal.dart';
import 'group_detail_page.dart';
import 'package:private_school/core/utils/app_colors.dart';

class GroupesPage extends StatelessWidget {
  const GroupesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GroupBloc(repository: GroupRepository())
        ..add(LoadAllGroupsEvent()), // ✅ UN seul event qui charge tout en parallèle
      child: const GroupesPageContent(),
    );
  }
}

class GroupesPageContent extends StatefulWidget {
  const GroupesPageContent({super.key});

  @override
  State<GroupesPageContent> createState() => _GroupesPageContentState();
}

class _GroupesPageContentState extends State<GroupesPageContent> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openCreateGroupModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'create_carpooling_group'.tr(),
                        style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                      IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text('group_name'.tr(), style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87)),
                  const SizedBox(height: 8),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'group_name_example'.tr(),
                      hintStyle: GoogleFonts.inter(color: Colors.grey.shade400, fontSize: 14),
                      filled: true, fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.success)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text('members'.tr(), style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87)),
                  const SizedBox(height: 8),
                  TextField(
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'email_or_phone_number'.tr(),
                      hintStyle: GoogleFonts.inter(color: Colors.grey.shade400, fontSize: 14),
                      filled: true, fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.success)),
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success, foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: Text('create'.tr(), style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Column(
          children: [
            // ── HEADER VERT (design conservé) ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              decoration: BoxDecoration(
                color: AppColors.success,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('groups'.tr(),
                      style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── BARRE DE RECHERCHE (design conservé) ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'search'.tr(),
                    hintStyle: GoogleFonts.inter(color: Colors.grey.shade400, fontSize: 14),
                    prefixIcon: Icon(Icons.search, color: Colors.grey.shade400, size: 20),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ── CONTENU ──
            Expanded(
              child: BlocConsumer<GroupBloc, GroupState>(
                listener: (context, state) {
                  if (state is GroupJoined) {
                    context.read<GroupBloc>().add(LoadAllGroupsEvent());
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Groupe rejoint !', style: GoogleFonts.inter()),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                  if (state is InvitationResponded) {
                    context.read<GroupBloc>().add(LoadAllGroupsEvent());
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.accepted ? 'Invitation acceptée !' : 'Invitation refusée', style: GoogleFonts.inter()),
                        backgroundColor: state.accepted ? AppColors.success : Colors.grey,
                      ),
                    );
                  }
                  if (state is GroupError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.message, style: GoogleFonts.inter()), backgroundColor: Colors.red),
                    );
                  }
                },
                builder: (context, state) {

                  // ── CHARGEMENT INITIAL ──
                  if (state is GroupLoading) {
                    return Center(child: CircularProgressIndicator(color: AppColors.success));
                  }

                  // ── ERREUR CRITIQUE ──
                  if (state is GroupError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
                          const SizedBox(height: 16),
                          Text(state.message,
                              style: GoogleFonts.inter(fontSize: 16, color: Colors.red.shade700), textAlign: TextAlign.center),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => context.read<GroupBloc>().add(LoadAllGroupsEvent()),
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
                            child: Text('Réessayer', style: GoogleFonts.inter(color: Colors.white)),
                          ),
                        ],
                      ),
                    );
                  }

                  // ── ✅ DONNÉES RÉELLES — état GroupsLoaded ──
                  List<GroupModel> myGroups = [];
                  List<GroupModel> availableGroups = [];
                  List<GroupInvitation> invitations = [];

                  if (state is GroupsLoaded) {
                    myGroups = state.myGroups;
                    availableGroups = state.availableGroups;
                    invitations = state.invitations;
                  }

                  return RefreshIndicator(
                    color: AppColors.success,
                    onRefresh: () async {
                      context.read<GroupBloc>().add(LoadAllGroupsEvent());
                      // Attendre que l'état change
                      await Future.delayed(const Duration(milliseconds: 500));
                    },
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          // ── ✅ INVITATIONS EN ATTENTE (depuis l'API) ──
                          if (invitations.isNotEmpty)
                            ...invitations.map((invitation) => _buildInvitationCard(context, invitation)),

                          const SizedBox(height: 24),

                          // ── MES GROUPES ──
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Text('my_groups'.tr(),
                                style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1E3A8A))),
                          ),
                          const SizedBox(height: 16),

                          if (myGroups.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 40),
                                  child: Column(
                                    children: [
                                      Icon(Icons.group_outlined, size: 64, color: Colors.grey.shade300),
                                      const SizedBox(height: 16),
                                      Text('no_groups'.tr(),
                                          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey.shade600)),
                                      const SizedBox(height: 8),
                                      Text('create_your_first_group'.tr(),
                                          style: GoogleFonts.inter(fontSize: 14, color: Colors.grey.shade500)),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          else
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Column(
                                children: myGroups.map((group) => _buildVerticalGroupCard(group, context)).toList(),
                              ),
                            ),

                          const SizedBox(height: 32),

                          // ── GROUPES DISPONIBLES ──
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Text('groups_you_can_join'.tr(),
                                style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1E3A8A))),
                          ),
                          const SizedBox(height: 16),
                          _buildAvailableGroupsSection(context, availableGroups),

                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      // ── BOUTON FLOTTANT (design conservé) ──
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 60),
        child: FloatingActionButton(
          onPressed: _openCreateGroupModal,
          backgroundColor: AppColors.success,
          elevation: 6,
          child: const Icon(Icons.add, color: Colors.white, size: 28),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // ✅ CARTE INVITATION — données réelles de l'API
  // ─────────────────────────────────────────────
  Widget _buildInvitationCard(BuildContext context, GroupInvitation invitation) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          // AVATAR
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(invitation.initial,
                  style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.success)),
            ),
          ),
          const SizedBox(width: 12),
          // TEXTE
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('invitation_to_join'.tr(),
                    style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87)),
                const SizedBox(height: 2),
                Text(
                  // ✅ Vrai nom du groupe depuis l'API
                  invitation.groupName.isNotEmpty
                      ? invitation.groupName
                      : 'invitation_message'.tr(),
                  style: GoogleFonts.inter(fontSize: 13, color: Colors.grey.shade600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (invitation.invitedBy.isNotEmpty)
                  Text('Par ${invitation.invitedBy}',
                      style: GoogleFonts.inter(fontSize: 11, color: Colors.grey.shade400)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // ✅ BOUTONS connectés au BLoC
          Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(color: Colors.red.shade50, shape: BoxShape.circle),
                child: IconButton(
                  icon: Icon(Icons.close, size: 18, color: Colors.red.shade400),
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    context.read<GroupBloc>().add(RespondToInvitationEvent(
                      invitationId: invitation.id,
                      accept: false,
                    ));
                  },
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(color: Colors.green.shade50, shape: BoxShape.circle),
                child: IconButton(
                  icon: Icon(Icons.check, size: 18, color: Colors.green.shade600),
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    context.read<GroupBloc>().add(RespondToInvitationEvent(
                      invitationId: invitation.id,
                      accept: true,
                    ));
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // CARTE VERTICALE MES GROUPES (design conservé)
  // ─────────────────────────────────────────────
  Widget _buildVerticalGroupCard(GroupModel group, BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => GroupDetailPage(group: group)));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(group.initial,
                    style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.success)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(group.name,
                      style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87)),
                  const SizedBox(height: 4),
                  // ✅ Données réelles
                  Text('${group.membersCount} ${'members'.tr()}',
                      style: GoogleFonts.inter(fontSize: 14, color: Colors.grey.shade600)),
                  if (group.schoolName != null && group.schoolName!.isNotEmpty)
                    Text(group.schoolName!,
                        style: GoogleFonts.inter(fontSize: 12, color: Colors.grey.shade400)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 24),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // GROUPES DISPONIBLES HORIZONTAL (design conservé)
  // ─────────────────────────────────────────────
  Widget _buildAvailableGroupsSection(BuildContext context, List<GroupModel> availableGroups) {
    if (availableGroups.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          child: Text('no_available_groups'.tr(),
              style: GoogleFonts.inter(fontSize: 14, color: Colors.grey.shade500)),
        ),
      );
    }

    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: availableGroups.length,
        itemBuilder: (context, index) {
          return _buildHorizontalGroupCard(context, availableGroups[index]);
        },
      ),
    );
  }

  Widget _buildHorizontalGroupCard(BuildContext context, GroupModel group) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => JoinGroupModal(group: group),
        );
      },
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(group.initial,
                    style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.success)),
              ),
            ),
            const SizedBox(height: 12),
            Text(group.name,
                style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87),
                maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center),
            const SizedBox(height: 4),
            Text('${group.membersCount} ${'members'.tr()}',
                style: GoogleFonts.inter(fontSize: 13, color: Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }
}