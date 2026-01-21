import 'package:flutter/material.dart';

class ModalHelper {
  /// Show modal with slide animation from bottom to top
  static Future<T?> showSlideModal<T>({
    required BuildContext context,
    required Widget child,
    bool isScrollControlled = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      backgroundColor: Colors.transparent,
      transitionAnimationController: AnimationController(
        vsync: Navigator.of(context),
        duration: const Duration(milliseconds: 300),
      ),
      builder: (context) => SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 1), // Start from bottom
          end: Offset.zero, // End at current position
        ).animate(
          CurvedAnimation(
            parent: ModalRoute.of(context)!.animation!,
            curve: Curves.easeOutCubic,
          ),
        ),
        child: child,
      ),
    );
  }
}