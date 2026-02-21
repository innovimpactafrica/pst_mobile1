import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:private_school/core/utils/app_colors.dart';
import 'package:private_school/core/utils/app_constants.dart';
import 'package:private_school/parents/pages/acceuil/data/services/driver_user_id_extractor.dart';
import '../../domain/bloc/conversation_bloc.dart';
import '../../domain/bloc/conversation_event.dart';
import '../../domain/bloc/conversation_state.dart';
import '../../domain/bloc/unread_messages_bloc.dart';
import '../../data/models/conversation_model.dart';
import '../widgets/conversation_card_widget.dart';
import 'chat.dart';

class DiscussionsPage extends StatefulWidget {
  const DiscussionsPage({super.key});

  @override
  State<DiscussionsPage> createState() => _DiscussionsPageState();
}

class _DiscussionsPageState extends State<DiscussionsPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _showArchived = false;

  @override
  void initState() {
    super.initState();
    // Charger les conversations au démarrage
    context.read<ConversationBloc>().add(const LoadConversationsEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: _buildAppBar(),
      body: BlocConsumer<ConversationBloc, ConversationState>(
        listener: (context, state) {
          // Afficher les messages d'erreur
          if (state is ConversationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }

          // Afficher les confirmations
          if (state is ConversationUpdated) {
            String message = '';
            switch (state.action) {
              case 'archived':
                message = 'conversation_archived'.tr();
                break;
              case 'unarchived':
                message = 'conversation_unarchived'.tr();
                break;
              case 'muted':
                message = 'notifications_disabled'.tr();
                break;
              case 'unmuted':
                message = 'notifications_enabled'.tr();
                break;
            }
            
            if (message.isNotEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(message),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          }
        },
        builder: (context, state) {
          if (state is ConversationLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            );
          }

          if (state is ConversationEmpty) {
            return _buildEmptyState();
          }

          if (state is ConversationLoaded) {
            return _buildConversationsList(state);
          }

          if (state is ConversationError) {
            return _buildErrorState(state.message);
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showNewConversationDialog,
        backgroundColor: AppColors.success,
        child: const Icon(
          Icons.add_comment,
          color: AppColors.white,
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.success,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        _showArchived ? 'archived_conversations'.tr() : 'discussions'.tr(),
        style: GoogleFonts.inter(
          color: AppColors.white,
          fontSize: AppConstants.fontSizeXL,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        // Toggle archived button
        IconButton(
          icon: Icon(
            _showArchived ? Icons.unarchive : Icons.archive,
            color: AppColors.white,
          ),
          onPressed: _toggleArchivedView,
        ),

        // More options
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: AppColors.white),
          onSelected: (value) {
            switch (value) {
              case 'refresh':
                context.read<ConversationBloc>().add(
                      const RefreshConversationsEvent(),
                    );
                break;
              case 'settings':
                // TODO: Implémenter les paramètres
                break;
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'refresh',
              child: Row(
                children: [
                  const Icon(Icons.refresh, size: 20),
                  const SizedBox(width: 12),
                  Text('refresh'.tr()),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'settings',
              child: Row(
                children: [
                  const Icon(Icons.settings, size: 20),
                  const SizedBox(width: 12),
                  Text('settings'.tr()),
                ],
              ),
            ),
          ],
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: _buildSearchBar(),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.spacingM,
        0,
        AppConstants.spacingM,
        AppConstants.spacingM,
      ),
      color: AppColors.success,
      child: TextField(
        controller: _searchController,
        onChanged: (query) {
          context.read<ConversationBloc>().add(
                FilterConversationsEvent(query: query),
              );
        },
        style: GoogleFonts.inter(color: AppColors.white),
        decoration: InputDecoration(
          hintText: 'search_conversation'.tr(),
          hintStyle: GoogleFonts.inter(
            color: AppColors.white.withValues(alpha: 0.7),
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: AppColors.white,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: AppColors.white),
                  onPressed: () {
                    _searchController.clear();
                    context.read<ConversationBloc>().add(
                          const FilterConversationsEvent(query: ''),
                        );
                  },
                )
              : null,
          filled: true,
          fillColor: AppColors.white.withValues(alpha: 0.2),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacingM,
            vertical: AppConstants.spacingS,
          ),
        ),
      ),
    );
  }

  Widget _buildConversationsList(ConversationLoaded state) {
    final conversations = state.displayedConversations;

    if (conversations.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<ConversationBloc>().add(
              const RefreshConversationsEvent(),
            );
        await Future.delayed(const Duration(seconds: 1));
      },
      color: AppColors.primary,
      child: ListView.builder(
        itemCount: conversations.length,
        itemBuilder: (context, index) {
          final conversation = conversations[index];
          return ConversationCardWidget(
            conversation: conversation,
            onTap: () => _openChat(conversation),
            onLongPress: () => _showConversationOptions(conversation),
          );
        },
      ),
    );
  }

  void _openChat(ConversationModel conversation) async {
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ChatPage(conversation: conversation),
    ),
  );
  
  if (mounted) {
    // ✅ Refresh conversations ET compteur au retour
    context.read<ConversationBloc>().add(const RefreshConversationsEvent());
    UnreadMessagesBloc.instance?.add(RefreshUnreadCountEvent());
  }
}

  void _showConversationOptions(ConversationModel conversation) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                conversation.isMuted ? Icons.volume_up : Icons.volume_off,
              ),
              title: Text(conversation.isMuted ? 'unmute'.tr() : 'mute'.tr()),
              onTap: () {
                Navigator.pop(context);
                if (conversation.isMuted) {
                  this.context.read<ConversationBloc>().add(
                        UnmuteConversationEvent(conversationId: conversation.id),
                      );
                } else {
                  this.context.read<ConversationBloc>().add(
                        MuteConversationEvent(conversationId: conversation.id),
                      );
                }
              },
            ),
            ListTile(
              leading: Icon(
                conversation.isArchived ? Icons.unarchive : Icons.archive,
              ),
              title: Text(conversation.isArchived ? 'unarchive'.tr() : 'archive'.tr()),
              onTap: () {
                Navigator.pop(context);
                if (conversation.isArchived) {
                  this.context.read<ConversationBloc>().add(
                        UnarchiveConversationEvent(conversationId: conversation.id),
                      );
                } else {
                  this.context.read<ConversationBloc>().add(
                        ArchiveConversationEvent(conversationId: conversation.id),
                      );
                }
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.cancel, color: AppColors.textSecondary),
              title: Text('cancel'.tr()),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleArchivedView() {
    setState(() {
      _showArchived = !_showArchived;
    });

    if (_showArchived) {
      context.read<ConversationBloc>().add(const ShowArchivedConversationsEvent());
    } else {
      context.read<ConversationBloc>().add(const ShowActiveConversationsEvent());
    }
  }

  void _showNewConversationDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(AppConstants.spacingM),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: AppColors.grey300),
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Text(
                        'new_conversation'.tr(),
                        style: GoogleFonts.inter(
                          fontSize: AppConstants.fontSizeL,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              Expanded(
                child: _NewConversationContent(
                  scrollController: scrollController,
                  onConversationCreated: () {
                    Navigator.pop(context);
                    this.context.read<ConversationBloc>().add(
                          const RefreshConversationsEvent(),
                        );
                    // Rafraîchir aussi le compteur
                    UnreadMessagesBloc.instance?.add(RefreshUnreadCountEvent());
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _showArchived ? Icons.archive_outlined : Icons.chat_bubble_outline,
              size: 80,
              color: AppColors.grey400,
            ),
            const SizedBox(height: AppConstants.spacingL),
            Text(
              _showArchived
                  ? 'no_archived_conversations'.tr()
                  : 'no_conversations'.tr(),
              style: GoogleFonts.inter(
                fontSize: AppConstants.fontSizeXL,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.spacingS),
            Text(
              _showArchived
                  ? 'archived_conversations_will_appear'.tr()
                  : 'start_new_conversation'.tr(),
              style: GoogleFonts.inter(
                fontSize: AppConstants.fontSizeM,
                color: AppColors.grey600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 80,
              color: AppColors.error,
            ),
            const SizedBox(height: AppConstants.spacingL),
            Text(
              'error'.tr(),
              style: GoogleFonts.inter(
                fontSize: AppConstants.fontSizeXL,
                fontWeight: FontWeight.w600,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: AppConstants.spacingS),
            Text(
              message,
              style: GoogleFonts.inter(
                fontSize: AppConstants.fontSizeM,
                color: AppColors.grey600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.spacingL),
            ElevatedButton.icon(
              onPressed: () {
                context.read<ConversationBloc>().add(
                      const LoadConversationsEvent(),
                    );
              },
              icon: const Icon(Icons.refresh),
              label: Text('retry'.tr()),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spacingXL,
                  vertical: AppConstants.spacingM,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// Widget pour créer une nouvelle conversation - VERSION FINALE
// À remplacer dans votre discussions.dart

class _NewConversationContent extends StatefulWidget {
  final ScrollController scrollController;
  final VoidCallback onConversationCreated;

  const _NewConversationContent({
    required this.scrollController,
    required this.onConversationCreated,
  });

  @override
  State<_NewConversationContent> createState() => _NewConversationContentState();
}

class _NewConversationContentState extends State<_NewConversationContent> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _groupNameController = TextEditingController();
  bool _isGroupMode = false;
  final Set<int> _selectedMembers = {};

  @override
  void dispose() {
    _searchController.dispose();
    _groupNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Toggle entre conversation directe et groupe
        Padding(
          padding: const EdgeInsets.all(AppConstants.spacingM),
          child: Row(
            children: [
              Expanded(
                child: ChoiceChip(
                  label: Text('direct_conversation'.tr()),
                  selected: !_isGroupMode,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _isGroupMode = false;
                        _selectedMembers.clear();
                      });
                    }
                  },
                ),
              ),
              const SizedBox(width: AppConstants.spacingS),
              Expanded(
                child: ChoiceChip(
                  label: Text('group'.tr()),
                  selected: _isGroupMode,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _isGroupMode = true);
                    }
                  },
                ),
              ),
            ],
          ),
        ),

        // Nom du groupe (si mode groupe)
        if (_isGroupMode)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingM),
            child: TextField(
              controller: _groupNameController,
              decoration: InputDecoration(
                labelText: 'group_name'.tr(),
                hintText: 'enter_group_name'.tr(),
                prefixIcon: const Icon(Icons.group),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

        // Barre de recherche
        Padding(
          padding: const EdgeInsets.all(AppConstants.spacingM),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'search_driver'.tr(),
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (value) => setState(() {}),
          ),
        ),

        // Liste des chauffeurs disponibles
        Expanded(
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _getAllDrivers(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.success),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 48, color: AppColors.error),
                        const SizedBox(height: 16),
                        Text(
                          'loading_error'.tr(),
                          style: GoogleFonts.inter(
                            color: AppColors.error,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${snapshot.error}',
                          style: GoogleFonts.inter(color: AppColors.textSecondary),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }

              final drivers = snapshot.data ?? [];
              final filteredDrivers = _searchController.text.isEmpty
                  ? drivers
                  : drivers.where((d) {
                      final name = d['name'].toString().toLowerCase();
                      final query = _searchController.text.toLowerCase();
                      return name.contains(query);
                    }).toList();

              if (filteredDrivers.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people_outline, size: 64, color: AppColors.grey400),
                      const SizedBox(height: 16),
                      Text(
                        _searchController.text.isEmpty
                            ? 'no_drivers_available'.tr()
                            : 'no_results'.tr(),
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (_searchController.text.isEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          'book_trip_to_chat'.tr(),
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: AppColors.grey600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                );
              }

              return ListView.builder(
                controller: widget.scrollController,
                itemCount: filteredDrivers.length,
                itemBuilder: (context, index) {
                  final driver = filteredDrivers[index];
                  final driverId = driver['id'] as int;
                  final isSelected = _selectedMembers.contains(driverId);

                  return ListTile(
                    leading: Stack(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: AppColors.success.withValues(alpha: 0.2),
                          backgroundImage: driver['photo'] != null
                              ? NetworkImage(driver['photo'])
                              : null,
                          child: driver['photo'] == null
                              ? Icon(
                                  Icons.drive_eta,
                                  color: AppColors.success,
                                  size: 24,
                                )
                              : null,
                        ),
                        // Badge chauffeur
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: AppColors.success,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.white, width: 2),
                            ),
                            child: Icon(
                              Icons.drive_eta,
                              color: AppColors.white,
                              size: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                    title: Text(
                      driver['name'].toString(),
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Row(
                      children: [
                        Icon(
                          Icons.local_shipping,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'role_driver'.tr(),
                          style: GoogleFonts.inter(
                            fontSize: AppConstants.fontSizeS,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        if (driver['phone'] != null) ...[
                          const SizedBox(width: 8),
                          Icon(Icons.phone, size: 12, color: AppColors.grey600),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              driver['phone'],
                              style: GoogleFonts.inter(
                                fontSize: AppConstants.fontSizeXS,
                                color: AppColors.grey600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                        // Rating si disponible
                        if (driver['rating'] != null && driver['rating'] > 0) ...[
                          const SizedBox(width: 8),
                          Icon(Icons.star, size: 12, color: AppColors.warning),
                          const SizedBox(width: 2),
                          Text(
                            driver['rating'].toStringAsFixed(1),
                            style: GoogleFonts.inter(
                              fontSize: AppConstants.fontSizeXS,
                              color: AppColors.grey600,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                    trailing: _isGroupMode
                        ? Checkbox(
                            value: isSelected,
                            activeColor: AppColors.success,
                            onChanged: (value) {
                              setState(() {
                                if (value == true) {
                                  _selectedMembers.add(driverId);
                                } else {
                                  _selectedMembers.remove(driverId);
                                }
                              });
                            },
                          )
                        : Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: AppColors.grey600,
                          ),
                    onTap: () {
                      if (_isGroupMode) {
                        setState(() {
                          if (isSelected) {
                            _selectedMembers.remove(driverId);
                          } else {
                            _selectedMembers.add(driverId);
                          }
                        });
                      } else {
                        _createDirectConversation(driverId);
                      }
                    },
                  );
                },
              );
            },
          ),
        ),

        // Bouton de création (si mode groupe)
        if (_isGroupMode && _selectedMembers.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(AppConstants.spacingM),
            decoration: BoxDecoration(
              color: AppColors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: ElevatedButton(
                onPressed: _createGroupConversation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: AppColors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'create_group_with_members'.tr(namedArgs: {'count': _selectedMembers.length.toString(), 'label': _selectedMembers.length > 1 ? 'members'.tr() : 'member'.tr()}),
                  style: GoogleFonts.inter(
                    fontSize: AppConstants.fontSizeM,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// 🎯 FONCTION PRINCIPALE : Récupère TOUS les chauffeurs depuis les trip cards
Future<List<Map<String, dynamic>>> _getAllDrivers() async {
  try {
    final extractor = DriverUserIdExtractor();
    return await extractor.getAllDriversWithUserId();
  } catch (e, stackTrace) {
    debugPrint('❌ Erreur _getAllDrivers: $e');
    debugPrint('Stack: $stackTrace');
    rethrow;
  }
}

  void _createDirectConversation(int driverId) {
    debugPrint('🎯 Création de conversation directe avec chauffeur ID: $driverId');
    
    context.read<ConversationBloc>().add(
          CreateDirectConversationEvent(otherUserId: driverId),
        );
    widget.onConversationCreated();
  }

  void _createGroupConversation() {
    final groupName = _groupNameController.text.trim();
    
    // ✅ VALIDATION 1 : Nom du groupe
    if (groupName.isEmpty) {
      debugPrint('❌ Nom du groupe vide');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'enter_group_name'.tr(),
            style: GoogleFonts.inter(fontWeight: FontWeight.w500),
          ),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    // ✅ VALIDATION 2 : Minimum 2 membres
    if (_selectedMembers.length < 2) {
      debugPrint('❌ Pas assez de membres: ${_selectedMembers.length}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'select_at_least_2_members'.tr(),
            style: GoogleFonts.inter(fontWeight: FontWeight.w500),
          ),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: 'OK',
            textColor: AppColors.white,
            onPressed: () {},
          ),
        ),
      );
      return;
    }

    // ✅ TOUT EST BON : Créer le groupe
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint('🎯 Création du groupe "$groupName"');
    debugPrint('👥 Membres sélectionnés: $_selectedMembers');
    debugPrint('📊 Nombre de membres: ${_selectedMembers.length}');
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    // ✅ DISPATCH L'EVENT
    context.read<ConversationBloc>().add(
      CreateGroupConversationEvent(
        name: groupName,
        memberIds: _selectedMembers.toList(),
      ),
    );
    
    // ✅ FERMER LA BOTTOM SHEET
    debugPrint('✅ Event dispatché, fermeture du bottom sheet');
    widget.onConversationCreated();
  }
}

