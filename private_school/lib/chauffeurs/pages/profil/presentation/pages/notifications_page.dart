import 'package:flutter/material.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final List<Map<String, dynamic>> _notifications = [
    {
      'id': '1',
      'title': 'Trajet commencé',
      'message': 'Le conducteur a commencé le trajet vers École Primaire Saint-Joseph',
      'time': 'Aujourd\'hui, 07:39',
      'type': 'trip_started',
      'isRead': false,
    },
    {
      'id': '2',
      'title': 'Trajet terminé',
      'message': 'Votre enfant est arrivé à destination en toute sécurité',
      'time': 'Aujourd\'hui, 07:55',
      'type': 'trip_completed',
      'isRead': false,
    },
    {
      'id': '3',
      'title': 'Alerte météo',
      'message': 'Soyez prudent, des fortes pluies sont prévues ce soir',
      'time': 'Hier, 07:35',
      'type': 'weather_alert',
      'isRead': false,
    },
    {
      'id': '4',
      'title': 'Abonnement',
      'message': 'Votre abonnement expire dans 7 jours',
      'time': 'Il y a 2 jours',
      'type': 'subscription',
      'isRead': false,
    },
  ];

  //String _selectedFilter = 'Tous';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2E3192),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const Text(
                    'Notifications',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  children: [
                    // Search Bar
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Rechercher',
                          hintStyle: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: Colors.grey[400],
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.grey[300]!,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.grey[300]!,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Filter Chips
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        children: [
                          _buildFilterChip('Tous', true),
                          const SizedBox(width: 8),
                          _buildFilterChip('Incident', false),
                          const SizedBox(width: 8),
                          _buildFilterChip('Litiges', false),
                          const SizedBox(width: 8),
                          _buildFilterChip('Sécurité', false),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Notifications List
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        children: [
                          // Today Section
                          const Padding(
                            padding: EdgeInsets.only(bottom: 12),
                            child: Text(
                              'Aujourd\'hui',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ),
                          ..._notifications
                              .where((n) => n['time'].toString().contains('Aujourd\'hui'))
                              .map((n) => _buildNotificationCard(n)),
                          const SizedBox(height: 24),
                          // Yesterday Section
                          const Padding(
                            padding: EdgeInsets.only(bottom: 12),
                            child: Text(
                              'Hier',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ),
                          ..._notifications
                              .where((n) => n['time'].toString().contains('Hier') || n['time'].toString().contains('jours'))
                              .map((n) => _buildNotificationCard(n)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF10B981) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? const Color(0xFF10B981) : const Color(0xFFE5E7EB),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: isSelected ? Colors.white : const Color(0xFF6B7280),
        ),
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification) {
    IconData icon;
    Color iconColor;

    switch (notification['type']) {
      case 'trip_started':
        icon = Icons.play_circle_outline;
        iconColor = const Color(0xFF3B82F6);
        break;
      case 'trip_completed':
        icon = Icons.check_circle_outline;
        iconColor = const Color(0xFF10B981);
        break;
      case 'weather_alert':
        icon = Icons.warning_amber;
        iconColor = const Color(0xFFF59E0B);
        break;
      case 'subscription':
        icon = Icons.notifications_active_outlined;
        iconColor = const Color(0xFF3B82F6);
        break;
      default:
        icon = Icons.info_outline;
        iconColor = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: notification['isRead'] ? Colors.white : const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: notification['isRead'] ? const Color(0xFFE5E7EB) : const Color(0xFF3B82F6).withValues(alpha:0.2),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha:0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      notification['title'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    Text(
                      notification['time'].toString().split(',').last.trim(),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  notification['message'],
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}