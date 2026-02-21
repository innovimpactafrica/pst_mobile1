import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:private_school/core/utils/app_colors.dart';
import 'package:private_school/core/utils/app_constants.dart';
import 'package:private_school/core/storage/secure_storage.dart';
import '../../../../../parents/pages/acceuil/domain/bloc/message_bloc.dart';
import '../../../../../parents/pages/acceuil/domain/bloc/message_event.dart';
import '../../../../../parents/pages/acceuil/domain/bloc/message_state.dart';
import '../../domain/bloc/unread_messages_bloc.dart';
import '../../../../../parents/pages/acceuil/data/models/conversation_model.dart';
import '../../../../../parents/pages/acceuil/data/models/message_model.dart';
import '../../data/repositories/messaging_repository.dart';
import '../../../../../parents/pages/acceuil/presentation/widgets/message_bubble_widget.dart';

class DriverChatPage extends StatefulWidget {
  final ConversationModel conversation;

  const DriverChatPage({
    super.key,
    required this.conversation,
  });

  @override
  State<DriverChatPage> createState() => _DriverChatPageState();
}

class _DriverChatPageState extends State<DriverChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final SecureStorage _storage = SecureStorage();
  final MessagingRepository _repository = MessagingRepository();

  int? _currentUserId;
  bool _isLoading = true;
  MessageModel? _editingMessage;
  
  int get _conversationId => widget.conversation.id;

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
      debugPrint('✅ [DriverChatPage] Messages marqués comme lus');
    } catch (e) {
      debugPrint('⚠️ Erreur marquage messages lus: $e');
    }
  }

  Future<void> _loadCurrentUser() async {
    try {
      final userDataRaw = await _storage.getUserData();
      int? extractedId;

      if (userDataRaw != null && userDataRaw.isNotEmpty) {
        try {
          final decoded = jsonDecode(userDataRaw) as Map<String, dynamic>;
          final dynamic idValue = decoded['id'];
          
          if (idValue is int) {
            extractedId = idValue;
          } else if (idValue is String) {
            extractedId = int.tryParse(idValue);
          } else if (idValue != null) {
            extractedId = int.tryParse(idValue.toString());
          }
        } catch (e) {
          final patterns = [
            RegExp(r'"id"\s*:\s*(\d+)'),
            RegExp(r'id\s*:\s*(\d+)'),
          ];

          for (final pattern in patterns) {
            final match = pattern.firstMatch(userDataRaw);
            if (match != null && match.group(1) != null) {
              extractedId = int.tryParse(match.group(1)!);
              if (extractedId != null) break;
            }
          }
        }
      }

      setState(() {
        _currentUserId = extractedId;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _currentUserId = null;
        _isLoading = false;
      });
    }
  }

  int? _resolveCurrentUserId(List<MessageModel> messages) {
    if (_currentUserId != null) return _currentUserId;
    for (final msg in messages) {
      if (msg.senderRole == 'driver') {
        return int.tryParse(msg.senderId.toString()) ?? 0;
      }
    }
    return null;
  }

  @override
  void dispose() {
    _markMessagesAsRead();
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
          backgroundColor: AppColors.primary,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(widget.conversation.displayName,
              style: GoogleFonts.inter(color: AppColors.white)),
        ),
        body: const Center(
            child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      resizeToAvoidBottomInset: false,
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
            _markMessagesAsRead();
          }
          if (state is MessageSent && _editingMessage != null) {
            setState(() => _editingMessage = null);
            UnreadMessagesBloc.notifyNewMessage(_conversationId);
          }
        },
        builder: (context, state) {
          if (state is MessageLoading) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.primary));
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
      backgroundColor: AppColors.primary,
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
                  widget.conversation.otherUserRole == 'parent'
                      ? 'Parent'
                      : widget.conversation.type == 'group'
                          ? '${widget.conversation.memberCount ?? ''} membres'
                          : 'Chauffeur',
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
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border(
          left: BorderSide(
            color: AppColors.primary,
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
                    color: AppColors.primary,
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
         bottom: AppConstants.spacingS, // ← plus de viewInsets.bottom
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
            backgroundColor: AppColors.primary,
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
  return SafeArea(
    child: Column(
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
    ),
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
                      backgroundColor: AppColors.primary,
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
