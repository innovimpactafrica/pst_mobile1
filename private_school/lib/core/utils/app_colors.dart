import 'package:flutter/material.dart';

/// Centralization of all application colors
/// Location: lib/core/utils/app_colors.dart
class AppColors {
  AppColors._();
  
  // Primary colors
  static const Color primary = Color(0xFF2E3B82);
  static const Color secondary = Color(0xFF5B4FC7);
  static const Color primaryLight = Color(0xFF4A5BC7);
  
  // Background colors
  static const Color background = Color(0xFFF5F5F5);
  static const Color backgroundLight = Color(0xFFF9FAFB);
  static const Color surface = Colors.white;
  static const Color imagePlaceholder = Color(0xFFEEEEEE);
  static const Color white = Colors.white;
  static const Color cardBackground = Color(0xFFF0F0F0);
   
  // Text colors
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color textGrey = Color(0xFF9E9E9E);
  static const Color textWhite = Colors.white;
  
  // Status colors
  static const Color success = Color(0xFF4CAF50);
  static const Color successLight = Color(0xFFF0FDF4);
  static const Color successDark = Color(0xFF388E3C);
  
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);
  
  // Status backgrounds
  static const Color statusPendingBg = Color(0xFFFFF3E0);
  static const Color statusActiveBg = Color(0xFFE3F2FD);
  static const Color statusStartedBg = Color(0xFFE3F2FD);
  static const Color statusCompletedBg = Color(0xFFE8F5E9);
  static const Color statusCanceledBg = Color(0xFFFFEBEE);
  
  static const Color successBackground = Color(0xFFE8F5E9);
  static const Color warningBackground = Color(0xFFFFF3E0);
  static const Color errorBackground = Color(0xFFFFEBEE);
  static const Color infoBackground = Color(0xFFE3F2FD);
  
  // Border colors
  static const Color border = Color(0xFFE0E0E0);
  static const Color borderLight = Color(0xFFE5E7EB);
  static const Color grey200 = Color(0xFFE0E0E0);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey400 = Color(0xFFBDBDBD);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey700 = Color(0xFF616161);
  static const Color divider = Color(0xFFE0E0E0);
  
  // Social media
  static const Color whatsapp = Color(0xFF25D366);
  static const Color instagram = Color(0xFFE4405F);
  static const Color messenger = Color(0xFF0084FF);
  static const Color twitter = Color(0xFF000000);
  
  // Location
  static const Color locationStart = Colors.green;
  static const Color locationDestination = Colors.red;
  
  // Status
  static const Color statusPending = Colors.orange;
  static const Color statusActive = Colors.blue;
  static const Color statusStarted = Colors.blue;
  static const Color statusCompleted = Color(0xFF4CAF50);
  static const Color statusCanceled = Color(0xFFF44336);
  
  // Rating
  static const Color rating = Color(0xFFFFB300);
  
  // Opacity helpers
  static final Color whiteOpacity20 = Colors.white.withValues(alpha: 0.2);
  static final Color blackOpacity10 = Colors.black.withValues(alpha: 0.1);
  static final Color blackOpacity05 = Colors.black.withValues(alpha: 0.05);
}