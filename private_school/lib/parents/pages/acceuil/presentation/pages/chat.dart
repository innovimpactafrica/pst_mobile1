import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:private_school/core/utils/app_colors.dart';
import 'package:private_school/core/utils/app_constants.dart';
import 'package:private_school/core/utils/image_url_helper.dart';
import 'package:private_school/core/storage/secure_storage.dart';
import '../../domain/bloc/message_bloc.dart';
import '../../domain/bloc/message_event.dart';
import '../../domain/bloc/message_state.dart';
import '../../domain/bloc/unread_messages_bloc.dart';
import '../../data/models/conversation_model.dart';
import '../../data/models/message_model.dart';
import '../../data/repositories/messaging_repository.dart';
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
  final MessagingRepository _repository = MessagingRepository();

  int? _currentUserId;
  bool _isLoading = true;
  MessageModel? _editingMessage;
  MessageLoaded? _lastLoadedState; 
  int get _conversationId {
    final id = widget.conversation.id;
    debugPrint('🔍 [ChatPage] conversation.id = $id (type: ${id.runtimeType})');
    return id; 
  }


 @override
void initState() {
  super.initState();
  _loadCurrentUser();
  
  context.read<MessageBloc>().add(
    LoadMessagesEvent(conversationId: _conversationId),
  );
  
 
  _markMessagesAsRead();
}

  Future<void> _markMessagesAsRead() async {
  try {
    await _repository.markConversationAsRead(_conversationId);
    
   
    UnreadMessagesBloc.notifyMessageRead(_conversationId);
    
    debugPrint(' [ChatPage] Messages marqués comme lus');
  } catch (e) {
    debugPrint(' Erreur marquage messages lus: $e');
  }
}

Future<void> _loadCurrentUser() async {
  try {
    final userDataRaw = await _storage.getUserData();
    debugPrint(' getUserData type: ${userDataRaw?.runtimeType}');
    debugPrint(' getUserData valeur: $userDataRaw');

    int? extractedId;

    if (userDataRaw != null && userDataRaw.isNotEmpty) {
      debugPrint('📝 String à parser: $userDataRaw');

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
  resizeToAvoidBottomInset: false, // ← Ajouter cette ligne
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
          if (state is MessageSent) {
  _scrollToBottom();
  _markMessagesAsRead();
}
if (state is MessageLoaded) {
  _scrollToBottom();
}
          if (state is MessageSent && _editingMessage != null) {
            setState(() => _editingMessage = null);
            // Notifier qu'un nouveau message a été envoyé
            UnreadMessagesBloc.notifyNewMessage(_conversationId);
          }
        },
        builder: (context, state) {
  // ✅ Mémoriser le dernier état MessageLoaded
  if (state is MessageLoaded) {
    _lastLoadedState = state;
    return _buildChatView(state);
  }

  if (state is MessageLoading) {
    // Premier chargement uniquement
    if (_lastLoadedState == null) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.success));
    }
    // Si on a déjà des messages, garder l'affichage
    return _buildChatView(_lastLoadedState!);
  }

  // ✅ Pour TOUS les autres états transitoires (MessageSent, MessageSending,
  // MessageUpdating, MessageDeleting, MessageRefreshing...)
  // garder le dernier affichage connu
  if (_lastLoadedState != null) {
    return _buildChatView(_lastLoadedState!);
  }

  // Seulement si vraiment aucun message n'a jamais été chargé
  if (state is MessageEmpty) return _buildEmptyWithInput();
  if (state is MessageError) return _buildErrorState(state.message);
  
  return _buildEmptyWithInput();
},
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    debugPrint('🖼️ [ChatPage] displayAvatar: ${widget.conversation.displayAvatar}');
    debugPrint('🖼️ [ChatPage] otherUserId: ${widget.conversation.otherUserId}');
    debugPrint('🖼️ [ChatPage] otherUserAvatar: ${widget.conversation.otherUserAvatar}');
    
    final photoUrl = widget.conversation.otherUserAvatar ?? 
        widget.conversation.displayAvatar ?? 
        (widget.conversation.otherUserId != null 
            ? ImageUrlHelper.getFullImageUrl('uploads/users/${widget.conversation.otherUserId}/profile.jpg')
            : null);
    
    debugPrint('🖼️ [ChatPage] photoUrl finale: $photoUrl');

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
            backgroundImage: photoUrl != null && photoUrl.isNotEmpty
                ? NetworkImage(photoUrl)
                : null,
            onBackgroundImageError: photoUrl != null ? (exception, stackTrace) {
              debugPrint('❌ [ChatPage] Erreur chargement image: $exception');
            } : null,
            child: photoUrl == null || photoUrl.isEmpty
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
  
  return SafeArea(
    child: Column(
      children: [
        if (state.isReplying) _buildReplyPreview(state),
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spacingM,
              vertical: AppConstants.spacingS,
            ),
            itemCount: state.messages.length,
            itemBuilder: (context, index) {
              final message = state.messages[index];
              final isMe = effectiveUserId != null &&
                  message.senderId == effectiveUserId;

              bool showDateSeparator = false;
              if (index == 0) {
                showDateSeparator = true;
              } else {
                final prevMessage = state.messages[index - 1];
                final prevDate = DateTime(
                  prevMessage.createdAt.year,
                  prevMessage.createdAt.month,
                  prevMessage.createdAt.day,
                );
                final currentDate = DateTime(
                  message.createdAt.year,
                  message.createdAt.month,
                  message.createdAt.day,
                );
                showDateSeparator = !prevDate.isAtSameMomentAs(currentDate);
              }

              return Column(
                children: [
                  if (showDateSeparator) _buildDateSeparator(message.createdAt),

                  MessageBubbleWidget(
                    message: message,
                    isMe: isMe,
                    onLongPress: () => _showMessageOptions(message, isMe),
                    onReply: () => _setReplyTo(message),
                    conversationAvatar: widget.conversation.displayAvatar,
                  ),
                ],
              );
            },
          ),
        ),
        _buildMessageInput(state),
      ],
    ),
  );
}

  Widget _buildReplyPreview(MessageLoaded state) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingS),
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingM,
        vertical: AppConstants.spacingS,
      ),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border(
          left: BorderSide(
            color: AppColors.success,
            width: 3,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'reply_to'.tr() + ' ${state.replyToSenderName ?? "unknown".tr()}',
                  style: GoogleFonts.inter(
                    fontSize: AppConstants.fontSizeS,
                    fontWeight: FontWeight.w600,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  state.replyToContent ?? '',
                  style: GoogleFonts.inter(
                    fontSize: AppConstants.fontSizeS,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 20),
            onPressed: () {
              context.read<MessageBloc>().add(
                    const CancelReplyToMessageEvent(),
                  );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDateSeparator(DateTime date) {
    String dateText;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(date.year, date.month, date.day);

    if (messageDate == today) {
      dateText = 'today_label'.tr();
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      dateText = 'yesterday'.tr();
    } else {
      dateText = '${date.day}/${date.month}/${date.year}';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.spacingM),
      child: Row(
        children: [
          Expanded(child: Divider(color: AppColors.grey400)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingM),
            child: Text(
              dateText,
              style: GoogleFonts.inter(
                fontSize: AppConstants.fontSizeS,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(child: Divider(color: AppColors.grey400)),
        ],
      ),
    );
  }

  Widget _buildMessageInput(MessageLoaded state) {
    return Container(
      padding: EdgeInsets.only(
        left: AppConstants.spacingM,
        right: AppConstants.spacingM,
        top: AppConstants.spacingS,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppConstants.spacingS,
      ),
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
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: _editingMessage != null
                    ? 'edit_message'.tr()
                    : 'write_message'.tr(),
                hintStyle: GoogleFonts.inter(
                  color: AppColors.textSecondary,
                  fontSize: AppConstants.fontSizeM,
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spacingM,
                  vertical: AppConstants.spacingS,
                ),
                prefixIcon: _editingMessage != null
                    ? IconButton(
                        icon: const Icon(Icons.close, color: AppColors.error),
                        onPressed: _cancelEdit,
                      )
                    : null,
              ),
              maxLines: null,
              textCapitalization: TextCapitalization.sentences,
            ),
          ),
          const SizedBox(width: AppConstants.spacingS),
          CircleAvatar(
            backgroundColor: AppColors.success,
            child: IconButton(
              icon: Icon(
                _editingMessage != null ? Icons.check : Icons.send,
                color: AppColors.white,
                size: 20,
              ),
              onPressed: () => _sendOrUpdateMessage(state),
            ),
          ),
        ],
      ),
    );
  }

  void _sendOrUpdateMessage(MessageLoaded state) {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    if (_editingMessage != null) {
      context.read<MessageBloc>().add(
            UpdateMessageEvent(
              conversationId: _conversationId,
              messageId: _editingMessage!.id,
              content: content,
            ),
          );
      _cancelEdit();
    } else {
      context.read<MessageBloc>().add(
      SendMessageEvent(
        conversationId: _conversationId,
        content: content,
        replyToId: state.replyToId,
        currentUserId: _currentUserId ?? 0,
      ),
    );
    }

    _messageController.clear();
  }

  void _setReplyTo(MessageModel message) {
    context.read<MessageBloc>().add(
          SetReplyToMessageEvent(
            messageId: message.id,
            messageContent: message.content,
            senderName: message.senderName,
          ),
        );
  }

  void _cancelEdit() {
    setState(() {
      _editingMessage = null;
      _messageController.clear();
    });
  }

  void _showMessageOptions(MessageModel message, bool isMe) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.reply),
              title: Text('reply'.tr()),
              onTap: () {
                Navigator.pop(context);
                _setReplyTo(message);
              },
            ),
            if (isMe) ...[
              ListTile(
                leading: const Icon(Icons.edit),
                title: Text('modify'.tr()),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _editingMessage = message;
                    _messageController.text = message.content;
                  });
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: AppColors.error),
                title: Text('delete'.tr(), style: const TextStyle(color: AppColors.error)),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDeleteMessage(message);
                },
              ),
            ],
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

  void _confirmDeleteMessage(MessageModel message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'delete_message'.tr(),
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'delete_message_confirm'.tr(),
          style: GoogleFonts.inter(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'cancel'.tr(),
              style: GoogleFonts.inter(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              this.context.read<MessageBloc>().add(
                    DeleteMessageEvent(
                      conversationId: _conversationId,
                      messageId: message.id,
                    ),
                  );
            },
            child: Text(
              'delete'.tr(),
              style: GoogleFonts.inter(
                color: AppColors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
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
                Icon(
                  Icons.chat_bubble_outline,
                  size: 80,
                  color: AppColors.grey400,
                ),
                const SizedBox(height: AppConstants.spacingL),
                Text(
                  'no_messages'.tr(),
                  style: GoogleFonts.inter(
                    fontSize: AppConstants.fontSizeXL,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppConstants.spacingS),
                Text(
                  'start_conversation'.tr(),
                  style: GoogleFonts.inter(
                    fontSize: AppConstants.fontSizeM,
                    color: AppColors.grey600,
                  ),
                ),
              ],
            ),
          ),
        ),
        _buildMessageInput(MessageLoaded(
          conversationId: _conversationId,
          messages: const [],
        )),
      ],
    );
  }

  Widget _buildErrorState(String message) {
    return Column(
      children: [
        Expanded(
          child: Center(
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
                      context.read<MessageBloc>().add(
                            LoadMessagesEvent(conversationId: _conversationId),
                          );
                    },
                    icon: const Icon(Icons.refresh),
                    label: Text('retry'.tr()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: AppColors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}