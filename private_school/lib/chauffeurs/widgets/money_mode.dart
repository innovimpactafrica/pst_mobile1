import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../core/utils/app_colors.dart';
import '../../chauffeurs/pages/abonnement/data/models/subscription_model.dart';

class PaymentModal extends StatefulWidget {
  final SubscriptionPlan plan;
  final VoidCallback? onPaymentComplete;

  const PaymentModal({super.key, required this.plan, this.onPaymentComplete});

  @override
  State<PaymentModal> createState() => _PaymentModalState();
}

class _PaymentModalState extends State<PaymentModal> {
  bool isCard = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildSubscriptionDetails(),
              const SizedBox(height: 24),
              _buildSectionTitle('payment_info'.tr()),
              const SizedBox(height: 16),
              _buildPaymentMethodTabs(),
              const SizedBox(height: 24),
              if (isCard) _buildCardForm() else _buildMobileMoney(),
              const SizedBox(height: 24),
              _buildPayButton(),
              const SizedBox(height: 16),
              _buildTermsText(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'subscription_payment'.tr(),
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close, color: AppColors.textSecondary),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  Widget _buildSubscriptionDetails() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.plan.name,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.plan.durationDays <= 31
                      ? 'monthly_billing'.tr()
                      : 'annual_billing'.tr(),
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${widget.plan.price.toStringAsFixed(0)} F cfa',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildPaymentMethodTabs() {
    return Row(
      children: [
        Expanded(
          child: _buildPaymentTab(
            icon: Icons.credit_card,
            label: 'bank_card'.tr(),
            isSelected: isCard,
            onTap: () => setState(() => isCard = true),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildPaymentTab(
            icon: Icons.phone_android_outlined,
            label: 'mobile_money'.tr(),
            isSelected: !isCard,
            onTap: () => setState(() => isCard = false),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentTab({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : Colors.white,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.textSecondary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(
          label: 'cardholder_name'.tr(),
          hint: 'Lamine wade',
          icon: Icons.person_outline,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          label: 'card_number'.tr(),
          hint: '1234 5678 9012 3456',
          icon: Icons.credit_card,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                label: 'expiry_date'.tr(),
                hint: 'MM/AA',
                keyboardType: TextInputType.datetime,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTextField(
                label: 'CVV',
                hint: '123',
                keyboardType: TextInputType.number,
                obscureText: true,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    IconData? icon,
    TextInputType? keyboardType,
    bool obscureText = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          keyboardType: keyboardType,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            ),
            prefixIcon: icon != null
                ? Icon(icon, color: AppColors.textSecondary, size: 20)
                : null,
            filled: true,
            fillColor: AppColors.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileMoney() {
    final providers = [
      {'image': 'assets/images/2.png', 'name': 'Wave'},
      {'image': 'assets/images/3.png', 'name': 'Yas money'},
      {'image': 'assets/images/4.png', 'name': 'Orange money'},
      {'image': 'assets/images/5.png', 'name': 'Kay pay'},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.2,
      ),
      itemCount: providers.length,
      itemBuilder: (context, index) {
        final provider = providers[index];
        return _buildPaymentProviderCard(provider['image']!, provider['name']!);
      },
    );
  }

  Widget _buildPaymentProviderCard(String imagePath, String name) {
    return InkWell(
      onTap: () => _processPayment(paymentMethod: name),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              imagePath,
              width: 50,
              height: 50,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.account_balance_wallet,
                  size: 50,
                  color: AppColors.primary,
                );
              },
            ),
            const SizedBox(height: 8),
            Text(
              name,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPayButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.success,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          elevation: 0,
        ),
        onPressed: () => _processPayment(),
        child: Text(
          'pay'.tr(), // "Payer"
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildTermsText() {
    return Text(
      'payment_terms'.tr(),
      textAlign: TextAlign.center,
      style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
    );
  }

  void _processPayment({String? paymentMethod}) {
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          paymentMethod != null
              ? 'payment_via'.tr(namedArgs: {'method': paymentMethod})
              : 'payment_processing'.tr(),
        ),
        backgroundColor: AppColors.success,
      ),
    );

    // Appeler le callback si fourni
    if (widget.onPaymentComplete != null) {
      widget.onPaymentComplete!();
    }
  }
}

/// Helper function to show payment modal
void showPaymentModal(
  BuildContext context, {
  required SubscriptionPlan plan,
  VoidCallback? onPaymentComplete,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) =>
        PaymentModal(plan: plan, onPaymentComplete: onPaymentComplete),
  );
}
