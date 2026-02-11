// Message Bubble Widget
// Path: parents/pages/acceuil/presentation/widgets/message_bubble_widget.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:private_school/core/utils/app_colors.dart';
import 'package:private_school/core/utils/app_constants.dart';
import '../../data/models/message_model.dart';

class MessageBubbleWidget extends StatelessWidget {
  final MessageModel message;
  final bool isCurrentUser;
  final VoidCallback? onLongPress;
  final VoidCallback? onReply;

  const MessageBubbleWidget({
    super.key,
    required this.message,
    required this.isCurrentUser,
    this.onLongPress,
    this.onReply,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onLongPress,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingM,
          vertical: 4,
        ),
        child: Row(
          mainAxisAlignment:
              isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Avatar (pour les autres utilisateurs)
            if (!isCurrentUser) ...[
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                backgroundImage: message.senderAvatar != null
                    ? NetworkImage(message.senderAvatar!)
                    : null,
                child: message.senderAvatar == null
                    ? Icon(
                        Icons.person,
                        color: AppColors.primary,
                        size: 18,
                      )
                    : null,
              ),
              const SizedBox(width: 8),
            ],

            // Message bubble
            Flexible(
              child: Column(
                crossAxisAlignment: isCurrentUser
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  // Sender name (pour les messages de groupe)
                  if (!isCurrentUser)
                    Padding(
                      padding: const EdgeInsets.only(left: 12, bottom: 2),
                      child: Text(
                        message.senderName,
                        style: GoogleFonts.inter(
                          fontSize: AppConstants.fontSizeS,
                          fontWeight: FontWeight.w600,
                          color: _getSenderColor(),
                        ),
                      ),
                    ),

                  // Reply preview (si le message est une réponse)
                  if (message.replyToContent != null) _buildReplyPreview(),

                  // Message content
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.spacingM,
                      vertical: AppConstants.spacingS,
                    ),
                    decoration: BoxDecoration(
                      color: isCurrentUser
                          ? AppColors.primary
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: Radius.circular(isCurrentUser ? 16 : 4),
                        bottomRight: Radius.circular(isCurrentUser ? 4 : 16),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          message.content,
                          style: GoogleFonts.inter(
                            fontSize: AppConstants.fontSizeM,
                            color: isCurrentUser
                                ? AppColors.white
                                : AppColors.textPrimary,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              message.formattedTime,
                              style: GoogleFonts.inter(
                                fontSize: AppConstants.fontSizeXS,
                                color: isCurrentUser
                                    ? AppColors.white.withValues(alpha: 0.7)
                                    : Colors.grey.shade600,
                              ),
                            ),
                            if (message.isEdited) ...[
                              const SizedBox(width: 4),
                              Text(
                                '(modifié)',
                                style: GoogleFonts.inter(
                                  fontSize: AppConstants.fontSizeXS,
                                  fontStyle: FontStyle.italic,
                                  color: isCurrentUser
                                      ? AppColors.white.withValues(alpha: 0.7)
                                      : Colors.grey.shade600,
                                ),
                              ),
                            ],
                            if (isCurrentUser) ...[
                              const SizedBox(width: 4),
                              Icon(
                                message.isRead
                                    ? Icons.done_all
                                    : Icons.done,
                                size: 14,
                                color: message.isRead
                                    ? AppColors.info
                                    : AppColors.white.withValues(alpha: 0.7),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Spacing pour l'alignement
            if (isCurrentUser) const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildReplyPreview() {
    return Container(
      margin: EdgeInsets.only(
        left: isCurrentUser ? 0 : 12,
        right: isCurrentUser ? 12 : 0,
        bottom: 4,
      ),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isCurrentUser
            ? AppColors.primary.withValues(alpha: 0.2)
            : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(8),
        border: Border(
          left: BorderSide(
            color: isCurrentUser ? AppColors.primary : AppColors.textSecondary,
            width: 3,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message.replyToSenderName ?? 'Utilisateur',
            style: GoogleFonts.inter(
              fontSize: AppConstants.fontSizeS,
              fontWeight: FontWeight.w600,
              color: isCurrentUser ? AppColors.primary : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            message.replyToContent!.length > 50
                ? '${message.replyToContent!.substring(0, 50)}...'
                : message.replyToContent!,
            style: GoogleFonts.inter(
              fontSize: AppConstants.fontSizeS,
              color: Colors.grey.shade700,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Color _getSenderColor() {
    // Générer une couleur basée sur le nom de l'expéditeur
    final colors = [
      AppColors.primary,
      AppColors.success,
      AppColors.warning,
      AppColors.info,
      Colors.purple,
      Colors.pink,
      Colors.teal,
    ];
    
    final hash = message.senderName.hashCode;
    return colors[hash.abs() % colors.length];
  }
}