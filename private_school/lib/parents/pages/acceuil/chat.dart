import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ConversationPage extends StatelessWidget {
  final String name;
  const ConversationPage({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(name, style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        backgroundColor: const Color(0xFF2C1E85),
        leading: BackButton(color: Colors.white),
      ),
      body: Center(
        child: Text(
          "Conversation avec $name",
          style: GoogleFonts.inter(fontSize: 18),
        ),
      ),
    );
  }
}
