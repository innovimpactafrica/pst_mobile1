// Conversation Card Widget
// Path: parents/pages/acceuil/presentation/widgets/conversation_card_widget.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:private_school/core/utils/app_colors.dart';
import 'package:private_school/core/utils/app_constants.dart';
import '../../data/models/conversation_model.dart';

class ConversationCardWidget extends StatelessWidget {
  final ConversationModel conversation;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const ConversationCardWidget({
    super.key,
    required this.conversation,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingM,
          vertical: AppConstants.spacingM,
        ),
        decoration: BoxDecoration(
          color: conversation.unreadCount > 0
              ? AppColors.primary.withValues(alpha: 0.05)
              : AppColors.white,
          border: Border(
            bottom: BorderSide(
              color: AppColors.grey200,
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            // Avatar
            _buildAvatar(),
            const SizedBox(width: AppConstants.spacingM),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Name
                      Expanded(
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                conversation.displayName,
                                style: GoogleFonts.inter(
                                  fontSize: AppConstants.fontSizeL,
                                  fontWeight: conversation.unreadCount > 0
                                      ? FontWeight.bold
                                      : FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (conversation.isMuted)
                              Padding(
                                padding: const EdgeInsets.only(left: 6),
                                child: Icon(
                                  Icons.volume_off,
                                  size: 16,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Time
                      Text(
                        conversation.timeAgo,
                        style: GoogleFonts.inter(
                          fontSize: AppConstants.fontSizeS,
                          color: conversation.unreadCount > 0
                              ? AppColors.primary
                              : AppColors.grey600,
                          fontWeight: conversation.unreadCount > 0
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Last message
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          conversation.lastMessagePreview,
                          style: GoogleFonts.inter(
                            fontSize: AppConstants.fontSizeM,
                            color: conversation.unreadCount > 0
                                ? AppColors.textPrimary
                                : AppColors.grey600,
                            fontWeight: conversation.unreadCount > 0
                                ? FontWeight.w500
                                : FontWeight.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      // Unread badge
                      if (conversation.unreadCount > 0)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            conversation.unreadCount > 99
                                ? '99+'
                                : conversation.unreadCount.toString(),
                            style: GoogleFonts.inter(
                              fontSize: AppConstants.fontSizeXS,
                              color: AppColors.white,
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

  Widget _buildAvatar() {
    return Stack(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
          backgroundImage: conversation.displayAvatar != null
              ? NetworkImage(conversation.displayAvatar!)
              : null,
          child: conversation.displayAvatar == null
              ? Icon(
                  conversation.type == 'group'
                      ? Icons.group
                      : Icons.person,
                  color: AppColors.primary,
                  size: 28,
                )
              : null,
        ),

        // Online indicator (pour les conversations directes)
        if (conversation.type == 'direct')
          Positioned(
            right: 2,
            bottom: 2,
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.white,
                  width: 2,
                ),
              ),
            ),
          ),
      ],
    );
  }
}