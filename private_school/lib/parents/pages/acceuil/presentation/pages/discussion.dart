

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:private_school/core/utils/app_colors.dart';
import 'package:private_school/core/utils/app_constants.dart';
import '../../domain/bloc/conversation_bloc.dart';
import '../../domain/bloc/conversation_event.dart';
import '../../domain/bloc/conversation_state.dart';
import '../../data/models/conversation_model.dart';
import '../widgets/conversation_card_widget.dart';
import 'chat.dart';
import '../../../trajets/data/services/trip_service.dart';

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
                message = 'Conversation archivée';
                break;
              case 'unarchived':
                message = 'Conversation désarchivée';
                break;
              case 'muted':
                message = 'Notifications désactivées';
                break;
              case 'unmuted':
                message = 'Notifications activées';
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
        _showArchived ? 'Conversations archivées' : 'Discussions',
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
            const PopupMenuItem(
              value: 'refresh',
              child: Row(
                children: [
                  Icon(Icons.refresh, size: 20),
                  SizedBox(width: 12),
                  Text('Actualiser'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'settings',
              child: Row(
                children: [
                  Icon(Icons.settings, size: 20),
                  SizedBox(width: 12),
                  Text('Paramètres'),
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
          hintText: 'Rechercher une conversation...',
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
    debugPrint('🔄 Ouverture du chat: ${conversation.displayName}');
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatPage(conversation: conversation),
      ),
    );
    
    if (mounted) {
      context.read<ConversationBloc>().add(const RefreshConversationsEvent());
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
              title: Text(conversation.isMuted ? 'Réactiver' : 'Mettre en sourdine'),
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
              title: Text(conversation.isArchived ? 'Désarchiver' : 'Archiver'),
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
              title: const Text('Annuler'),
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
                        'Nouvelle conversation',
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
                  ? 'Aucune conversation archivée'
                  : 'Aucune conversation',
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
                  ? 'Les conversations archivées apparaîtront ici'
                  : 'Commencez une nouvelle conversation\nen appuyant sur le bouton +',
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
              'Erreur',
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
              label: const Text('Réessayer'),
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


// Widget pour créer une nouvelle conversation
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
                  label: const Text('Conversation directe'),
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
                  label: const Text('Groupe'),
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
                labelText: 'Nom du groupe',
                hintText: 'Entrez le nom du groupe',
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
              hintText: 'Rechercher un chauffeur...',
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
            future: _getAvailableDrivers(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.success),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Erreur: ${snapshot.error}',
                    style: GoogleFonts.inter(color: AppColors.error),
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
                  child: Text(
                    'Aucun chauffeur disponible',
                    style: GoogleFonts.inter(color: AppColors.textSecondary),
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
                    leading: CircleAvatar(
                      backgroundColor: AppColors.success,
                      child: Text(
                        driver['name'].toString()[0].toUpperCase(),
                        style: GoogleFonts.inter(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      driver['name'].toString(),
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      'Chauffeur',
                      style: GoogleFonts.inter(
                        fontSize: AppConstants.fontSizeS,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    trailing: _isGroupMode
                        ? Checkbox(
                            value: isSelected,
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
                        : const Icon(Icons.arrow_forward_ios, size: 16),
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
                  'Créer le groupe (${_selectedMembers.length} membres)',
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

  Future<List<Map<String, dynamic>>> _getAvailableDrivers() async {
    try {
      final tripService = TripService();
      
      // Récupérer TOUS les trajets (réservés + disponibles)
      final reservedTrips = await tripService.getMyReservations();
      final availableTrips = await tripService.getAllTrips();
      
      // Combiner les deux listes
      final allTrips = [...reservedTrips, ...availableTrips];
      
      // Extraire les chauffeurs uniques
      final driversMap = <int, Map<String, dynamic>>{};
      
      for (final trip in allTrips) {
        if (trip.driver != null) {
          final driverId = int.tryParse(trip.driver!.id);
          if (driverId != null && !driversMap.containsKey(driverId)) {
            driversMap[driverId] = {
              'id': driverId,
              'name': trip.driver!.fullName,
              'phone': trip.driver!.phone,
              'photo': trip.driver!.photo,
            };
          }
        } else if (trip.driverId != null) {
          final driverId = int.tryParse(trip.driverId!);
          if (driverId != null && !driversMap.containsKey(driverId)) {
            driversMap[driverId] = {
              'id': driverId,
              'name': trip.driverName,
              'phone': trip.driverPhone ?? '',
              'photo': trip.driverPhoto,
            };
          }
        }
      }
      
      return driversMap.values.toList();
    } catch (e) {
      debugPrint('❌ Erreur lors de la récupération des chauffeurs: $e');
      return [];
    }
  }

  void _createDirectConversation(int driverId) {
    context.read<ConversationBloc>().add(
          CreateDirectConversationEvent(otherUserId: driverId),
        );
    widget.onConversationCreated();
  }

  void _createGroupConversation() {
    final groupName = _groupNameController.text.trim();
    if (groupName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez entrer un nom de groupe'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_selectedMembers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner au moins un membre'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    context.read<ConversationBloc>().add(
          CreateGroupConversationEvent(
            name: groupName,
            memberIds: _selectedMembers.toList(),
          ),
        );
    widget.onConversationCreated();
  }
}
