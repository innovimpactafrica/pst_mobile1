import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:private_school/core/utils/app_colors.dart';
import 'package:private_school/core/utils/app_constants.dart';
import 'package:private_school/core/storage/secure_storage.dart';
import '../../domain/bloc/message_bloc.dart';
import '../../domain/bloc/message_event.dart';
import '../../domain/bloc/message_state.dart';
import '../../data/models/conversation_model.dart';
import '../../data/models/message_model.dart';
import '../widgets/message_bubble_widget.dart';

class ChatPage extends StatefulWidget {
  final ConversationModel conversation;

  const ChatPage({
    super.key,
    required this.conversation,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final SecureStorage _storage = SecureStorage();

  int? _currentUserId;
  bool _isLoading = true;
  MessageModel? _editingMessage;

  // ✅ GETTER PROTÉGÉ : Gère int et String
  int get _conversationId {
    final id = widget.conversation.id;
    debugPrint('🔍 [ChatPage] conversation.id = $id (type: ${id.runtimeType})');
    return id; // Déjà un int selon votre modèle
  }

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    
    // ✅ Utiliser le getter protégé
    context.read<MessageBloc>().add(
          LoadMessagesEvent(conversationId: _conversationId),
        );
  }

Future<void> _loadCurrentUser() async {
  try {
    final userDataRaw = await _storage.getUserData();
    debugPrint('📦 getUserData type: ${userDataRaw?.runtimeType}');
    debugPrint('📦 getUserData valeur: $userDataRaw');

    int? extractedId;

    if (userDataRaw != null && userDataRaw.isNotEmpty) {
      debugPrint('📝 String à parser: $userDataRaw');

      // ✅ MÉTHODE 1 : Parser JSON
      try {
        final decoded = jsonDecode(userDataRaw) as Map<String, dynamic>;
        final dynamic idValue = decoded['id'];
        
        if (idValue is int) {
          extractedId = idValue;
          debugPrint('✅ ID extrait (JSON int): $extractedId');
        } else if (idValue is String) {
          extractedId = int.tryParse(idValue);
          debugPrint('✅ ID extrait (JSON string): $extractedId');
        } else if (idValue != null) {
          extractedId = int.tryParse(idValue.toString());
          debugPrint('✅ ID extrait (JSON autre): $extractedId');
        }
      } catch (e) {
        debugPrint('⚠️ Erreur parsing JSON: $e');
        
        // ✅ MÉTHODE 2 : Extraction par Regex
        final patterns = [
          RegExp(r'"id"\s*:\s*(\d+)'),
          RegExp(r'id\s*:\s*(\d+)'),
          RegExp(r"'id'\s*:\s*(\d+)"),
          RegExp(r'id=(\d+)'),
        ];

        for (final pattern in patterns) {
          final match = pattern.firstMatch(userDataRaw);
          if (match != null && match.group(1) != null) {
            extractedId = int.tryParse(match.group(1)!);
            if (extractedId != null) {
              debugPrint('✅ ID extrait (Regex): $extractedId');
              break;
            }
          }
        }
      }
    }

    if (extractedId == null) {
      debugPrint('⚠️ Impossible d\'extraire l\'ID utilisateur');
    }

    setState(() {
      _currentUserId = extractedId;
      _isLoading = false;
    });
    
    debugPrint('✅ Current user ID final: $_currentUserId');
  } catch (e, stackTrace) {
    debugPrint('❌ Erreur chargement utilisateur: $e');
    debugPrint('📋 StackTrace: $stackTrace');
    setState(() {
      _currentUserId = null;
      _isLoading = false;
    });
  }
}

  int? _resolveCurrentUserId(List<MessageModel> messages) {
    if (_currentUserId != null) return _currentUserId;
    for (final msg in messages) {
      if (msg.senderRole == 'parent') {
        return int.tryParse(msg.senderId.toString()) ?? 0;
      }
    }
    return null;
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 150), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.grey.shade100,
        appBar: AppBar(
          backgroundColor: AppColors.success,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(widget.conversation.displayName,
              style: GoogleFonts.inter(color: AppColors.white)),
        ),
        body: const Center(
            child: CircularProgressIndicator(color: AppColors.success)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: _buildAppBar(),
      body: BlocConsumer<MessageBloc, MessageState>(
        listener: (context, state) {
          if (state is MessageError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ));
          }
          if (state is MessageSent || state is MessageLoaded) {
            _scrollToBottom();
          }
          if (state is MessageSent && _editingMessage != null) {
            setState(() => _editingMessage = null);
          }
        },
        builder: (context, state) {
          if (state is MessageLoading) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.success));
          }
          if (state is MessageLoaded) return _buildChatView(state);
          if (state is MessageEmpty) return _buildEmptyWithInput();
          if (state is MessageError) return _buildErrorState(state.message);
          return _buildEmptyWithInput();
        },
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
      title: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.white.withValues(alpha: 0.2),
            backgroundImage: widget.conversation.displayAvatar != null
                ? NetworkImage(widget.conversation.displayAvatar!)
                : null,
            child: widget.conversation.displayAvatar == null
                ? Icon(
                    widget.conversation.type == 'group'
                        ? Icons.group
                        : Icons.person,
                    color: AppColors.white,
                    size: 20,
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.conversation.displayName,
                  style: GoogleFonts.inter(
                    color: AppColors.white,
                    fontSize: AppConstants.fontSizeL,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  widget.conversation.otherUserRole == 'driver'
                      ? 'Chauffeur'
                      : widget.conversation.type == 'group'
                          ? '${widget.conversation.memberCount ?? ''} membres'
                          : 'Parent',
                  style: GoogleFonts.inter(
                    color: AppColors.white.withValues(alpha: 0.8),
                    fontSize: AppConstants.fontSizeS,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: AppColors.white),
          onPressed: () {
            // ✅ Utiliser le getter protégé
            context.read<MessageBloc>().add(
                  RefreshMessagesEvent(conversationId: _conversationId),
                );
          },
        ),
      ],
    );
  }

  Widget _buildChatView(MessageLoaded state) {
    final effectiveUserId = _resolveCurrentUserId(state.messages);

    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            color: AppColors.success,
            onRefresh: () async {
              // ✅ Utiliser le getter protégé
              context.read<MessageBloc>().add(
                    RefreshMessagesEvent(conversationId: _conversationId),
                  );
              await Future.delayed(const Duration(seconds: 1));
            },
            child: ListView.builder(
              controller: _scrollController,
              padding:
                  const EdgeInsets.symmetric(vertical: AppConstants.spacingM),
              itemCount: state.messages.length,
              itemBuilder: (context, index) {
                final message = state.messages[index];
                final isCurrentUser = effectiveUserId != null &&
                    message.isSentByCurrentUser(effectiveUserId);

                bool showDate = index == 0 ||
                    message.formattedDate !=
                        state.messages[index - 1].formattedDate;

                return Column(
                  children: [
                    if (showDate) _buildDateSeparator(message.formattedDate),
                    MessageBubbleWidget(
                      message: message,
                      isCurrentUser: isCurrentUser,
                      onLongPress: () =>
                          _showMessageOptions(message, isCurrentUser),
                      onReply: () => _setReplyToMessage(message),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
        if (state.isReplying) _buildReplyBar(state),
        if (_editingMessage != null) _buildEditBar(),
        _buildInput(),
      ],
    );
  }

  Widget _buildDateSeparator(String date) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(date,
              style: GoogleFonts.inter(
                  fontSize: 12, color: Colors.grey.shade700)),
        ),
      ),
    );
  }

  Widget _buildReplyBar(MessageLoaded state) {
    return Container(
      padding: const EdgeInsets.all(8),
      color: AppColors.white,
      child: Row(
        children: [
          Container(
            width: 3,
            height: 36,
            color: AppColors.success,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Répondre à ${state.replyToSenderName ?? ''}',
                  style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.success),
                ),
                Text(
                  state.replyToContent ?? '',
                  style: GoogleFonts.inter(
                      fontSize: 12, color: Colors.grey.shade600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            onPressed: () => context
                .read<MessageBloc>()
                .add(const CancelReplyToMessageEvent()),
          ),
        ],
      ),
    );
  }

  Widget _buildEditBar() {
    return Container(
      padding: const EdgeInsets.all(8),
      color: Colors.amber.shade50,
      child: Row(
        children: [
          Container(width: 3, height: 36, color: Colors.amber),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Modifier le message',
                    style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.amber.shade800)),
                Text(
                  _editingMessage?.content ?? '',
                  style: GoogleFonts.inter(
                      fontSize: 12, color: Colors.grey.shade600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            onPressed: () {
              setState(() {
                _editingMessage = null;
                _messageController.clear();
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInput() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, -2))
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _messageController,
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: _editingMessage != null
                        ? 'Modifier...'
                        : 'Écrire un message...',
                    hintStyle:
                        GoogleFonts.inter(color: Colors.grey.shade600),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _sendOrUpdate,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _editingMessage != null
                      ? Colors.amber
                      : AppColors.success,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _editingMessage != null ? Icons.check : Icons.send,
                  color: AppColors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyWithInput() {
    return Column(
      children: [
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.chat_bubble_outline,
                    size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text('Aucun message',
                    style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary)),
                Text('Envoyez le premier message !',
                    style: GoogleFonts.inter(
                        fontSize: 14, color: Colors.grey.shade600)),
              ],
            ),
          ),
        ),
        _buildInput(),
      ],
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: AppColors.error),
          const SizedBox(height: 16),
          Text('Erreur',
              style: GoogleFonts.inter(
                  fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(message,
                style: GoogleFonts.inter(color: Colors.grey.shade600),
                textAlign: TextAlign.center),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              // ✅ Utiliser le getter protégé
              context.read<MessageBloc>().add(
                    LoadMessagesEvent(conversationId: _conversationId),
                  );
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Réessayer'),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: AppColors.white),
          ),
        ],
      ),
    );
  }

  void _sendOrUpdate() {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    if (_editingMessage != null) {
      // ✅ Utiliser le getter protégé
      context.read<MessageBloc>().add(UpdateMessageEvent(
            conversationId: _conversationId,
            messageId: _editingMessage!.id,
            content: content,
          ));
      setState(() => _editingMessage = null);
    } else {
      final state = context.read<MessageBloc>().state;
      int? replyToId;
      if (state is MessageLoaded && state.isReplying) {
        replyToId = state.replyToId;
      }
      // ✅ Utiliser le getter protégé
      context.read<MessageBloc>().add(SendMessageEvent(
            conversationId: _conversationId,
            content: content,
            replyToId: replyToId,
          ));
    }
    _messageController.clear();
  }

  void _setReplyToMessage(MessageModel message) {
    context.read<MessageBloc>().add(SetReplyToMessageEvent(
          messageId: message.id,
          messageContent: message.content,
          senderName: message.senderName,
        ));
  }

  void _showMessageOptions(MessageModel message, bool isCurrentUser) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.reply, color: AppColors.success),
              title: const Text('Répondre'),
              onTap: () {
                Navigator.pop(ctx);
                _setReplyToMessage(message);
              },
            ),
            if (isCurrentUser) ...[
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.amber),
                title: const Text('Modifier'),
                onTap: () {
                  Navigator.pop(ctx);
                  _messageController.text = message.content;
                  setState(() => _editingMessage = message);
                },
              ),
              ListTile(
                leading:
                    const Icon(Icons.delete, color: AppColors.error),
                title: const Text('Supprimer',
                    style: TextStyle(color: AppColors.error)),
                onTap: () {
                  Navigator.pop(ctx);
                  _confirmDelete(message);
                },
              ),
            ],
            const Divider(),
            ListTile(
              leading: const Icon(Icons.cancel, color: Colors.grey),
              title: const Text('Annuler'),
              onTap: () => Navigator.pop(ctx),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(MessageModel message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer le message'),
        content: const Text(
            'Êtes-vous sûr de vouloir supprimer ce message ?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Annuler')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              // ✅ Utiliser le getter protégé
              context.read<MessageBloc>().add(DeleteMessageEvent(
                    conversationId: _conversationId,
                    messageId: message.id,
                  ));
            },
            child: const Text('Supprimer',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}