import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'conversation_page.dart';

class DiscussionsPage extends StatelessWidget {
  const DiscussionsPage({super.key});

  final List<Map<String, dynamic>> discussions = const [
    {
      'name': 'Marie Mendy',
      'message': 'Bonjour, est-ce que vous pouvez prendre mon fils',
      'time': 'Aujourd\'hui, 14:25',
      'avatar': 'assets/images/marie.png',
    },
    {
      'name': 'Moussa Wane',
      'message': 'Votre vérification de profil a été approuvée...',
      'time': 'Aujourd\'hui, 10:27',
      'avatar': 'assets/images/moussa.png',
    },
    {
      'name': 'Ibrahima Sow',
      'message': 'Mon enfant ne sera pas présent aujourd\'hui...',
      'time': 'Hier, 18:34',
      'avatar': 'assets/images/ibrahima.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Discussions", style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        backgroundColor: const Color(0xFF2C1E85),
        leading: BackButton(color: Colors.white),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: discussions.length,
        separatorBuilder: (_, __) => const Divider(height: 20),
        itemBuilder: (context, index) {
          final discussion = discussions[index];
          return ListTile(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => ConversationPage(name: discussion['name'])),
              );
            },
            leading: CircleAvatar(
              radius: 25,
              backgroundImage: AssetImage(discussion['avatar']),
            ),
            title: Text(
              discussion['name'],
              style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Text(
              discussion['message'],
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(color: Colors.grey.shade700),
            ),
            trailing: Text(
              discussion['time'],
              style: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
            ),
          );
        },
      ),
    );
  }
}
