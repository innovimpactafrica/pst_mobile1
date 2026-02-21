import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:private_school/core/utils/app_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/services/messaging_service.dart';
import '../../data/models/conversation_model.dart' as driver_model;
import '../../../../../parents/pages/acceuil/data/models/conversation_model.dart' as parent_model;
import 'chat_page.dart';
import '../../../../../parents/pages/acceuil/domain/bloc/message_bloc.dart';
import '../../domain/bloc/unread_messages_bloc.dart';

class MessageriePage extends StatefulWidget {
  const MessageriePage({super.key});

  @override
  State<MessageriePage> createState() => _MessageriePageState();
}

class _MessageriePageState extends State<MessageriePage> {
  final MessagingService _messagingService = MessagingService();
  List<driver_model.ConversationModel> _conversations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    try {
      final conversations = await _messagingService.getConversations();
      setState(() {
        _conversations = conversations;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading conversations: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _conversations.isEmpty
                        ? Center(
                            child: Text(
                              'no_conversation'.tr(),
                              style: const TextStyle(color: Colors.grey),
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadConversations,
                            child: ListView(
                              padding: const EdgeInsets.all(16),
                              children: [
                                _buildSearchBar(),
                                const SizedBox(height: 16),
                                ..._conversations.map((conv) => _buildConversationCard(conv)),
                              ],
                            ),
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
              size: 20,
            ),
          ),
          Text(
            'discussions'.tr(),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'search'.tr(),
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
        prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
      ),
    );
  }

  Widget _buildConversationCard(driver_model.ConversationModel conversation) {
  final parentConversation = parent_model.ConversationModel(
    id: int.tryParse(conversation.id) ?? 0,
    type: 'direct',
    createdAt: conversation.lastMessageTime ?? DateTime.now(),
    updatedAt: conversation.lastMessageTime ?? DateTime.now(),
    lastMessageContent: conversation.lastMessagePreview,
    lastMessageTime: conversation.lastMessageTime,
    unreadCount: conversation.unreadCount,
    isArchived: false,
    isMuted: false,
    otherUserId: int.tryParse(conversation.participantId) ?? 0,
    otherUserName: conversation.displayName,
    otherUserAvatar: conversation.displayAvatar,
    otherUserRole: conversation.participantType,
  );

  return GestureDetector(
    onTap: () async {
      // ✅ Marquer comme lu immédiatement localement
      setState(() {
        final index = _conversations.indexOf(conversation);
        if (index != -1) {
          _conversations[index] = driver_model.ConversationModel(
            id: conversation.id,
            displayName: conversation.displayName,
            displayAvatar: conversation.displayAvatar,
            lastMessagePreview: conversation.lastMessagePreview,
            timeAgo: conversation.timeAgo,
            unreadCount: 0, // ← mettre à 0 immédiatement
            lastMessageTime: conversation.lastMessageTime,
            participantId: conversation.participantId,
            participantType: conversation.participantType,
          );
        }
      });

      // ✅ Notifier le bloc du dashboard
      UnreadMessagesBloc.instance?.add(RefreshUnreadCountEvent());

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => MessageBloc(),
            child: DriverChatPage(conversation: parentConversation),
          ),
        ),
      );

      if (mounted) {
        _loadConversations();
        UnreadMessagesBloc.instance?.add(RefreshUnreadCountEvent());
      }
    },
    child: Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: conversation.unreadCount > 0
              ? AppColors.primary.withValues(alpha: 0.3)
              : const Color(0xFFE5E7EB),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primary.withValues(alpha: 0.2),
            backgroundImage: conversation.displayAvatar != null
                ? NetworkImage(conversation.displayAvatar!)
                : null,
            child: conversation.displayAvatar == null
                ? Text(
                    conversation.displayName.isNotEmpty
                        ? conversation.displayName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        conversation.displayName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1F2937),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      conversation.timeAgo,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        conversation.lastMessagePreview,
                        style: TextStyle(
                          fontSize: 14,
                          color: conversation.unreadCount > 0
                              ? const Color(0xFF1F2937)
                              : const Color(0xFF6B7280),
                          fontWeight: conversation.unreadCount > 0
                              ? FontWeight.w500
                              : FontWeight.normal,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // ✅ Badge avec nombre de messages non lus
                    if (conversation.unreadCount > 0)
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          conversation.unreadCount > 99
                              ? '99+'
                              : conversation.unreadCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
}