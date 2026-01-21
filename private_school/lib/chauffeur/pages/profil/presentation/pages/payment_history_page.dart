import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../utils/app_colors.dart';

class PaymentHistoryPage extends StatelessWidget {
  const PaymentHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Historique des paiements',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          // BARRE DE RECHERCHE
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Rechercher',
                  hintStyle: GoogleFonts.inter(color: Colors.grey.shade400),
                  border: InputBorder.none,
                  icon: Icon(Icons.search, color: Colors.grey.shade400),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // LISTE DES PAIEMENTS
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _buildPaymentCard(
                  date: '04 oct., 22:05',
                  amount: '25 000 F',
                  status: 'Payé',
                  statusColor: AppColors.primaryGreen,
                  icon: Icons.receipt_long,
                ),
                _buildPaymentCard(
                  date: '04 oct., 22:05',
                  amount: '25 000 F',
                  status: 'Payé',
                  statusColor: AppColors.primaryGreen,
                  icon: Icons.receipt_long,
                ),
                _buildPaymentCard(
                  date: '28 sept., 18:30',
                  amount: '20 000 F',
                  status: 'En attente',
                  statusColor: Colors.orange,
                  icon: Icons.receipt_long,
                ),
                _buildPaymentCard(
                  date: '15 sept., 14:20',
                  amount: '25 000 F',
                  status: 'Payé',
                  statusColor: AppColors.primaryGreen,
                  icon: Icons.receipt_long,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCard({
    required String date,
    required String amount,
    required String status,
    required Color statusColor,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: statusColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Paiement',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  status,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}