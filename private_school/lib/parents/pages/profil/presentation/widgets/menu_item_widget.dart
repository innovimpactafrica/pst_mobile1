import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MenuItemWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color iconColor;
  final VoidCallback onTap;
  final bool showChevron;
  final Widget? trailing;

  const MenuItemWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.iconColor,
    required this.onTap,
    this.showChevron = true,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade200, width: 1),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
            if (trailing != null)
              trailing!
            else if (showChevron)
              Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 24),
          ],
        ),
      ),
    );
  }
}
