import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/utils/app_colors.dart';

/// Payment modal for subscription
/// Location: lib/chauffeurs/widgets/money_mode.dart
class PaymentModal extends StatefulWidget {
  final VoidCallback? onClose;

  const PaymentModal({super.key, this.onClose});

  @override
  State<PaymentModal> createState() => _PaymentModalState();
}

class _PaymentModalState extends State<PaymentModal> {
  bool isCard = true;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Material(
      color: Colors.transparent,
      child: Align(
        alignment: Alignment.topCenter,
        child: Container(
          height: screenHeight * 0.92,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  _buildHeader(),
                  const SizedBox(height: 20),

                  // Subscription details
                  _buildSubscriptionDetails(),
                  const SizedBox(height: 25),

                  // Payment method tabs
                  _buildPaymentMethodTabs(),
                  const SizedBox(height: 25),

                  // Dynamic content
                  if (isCard) _buildCardForm() else _buildMobileMoney(),
                  const SizedBox(height: 25),

                  // Terms and conditions
                  _buildTermsText(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Flexible(
          child: Text(
            "Paiement de l'abonnement",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close, color: AppColors.textSecondary),
          onPressed: () {
            Navigator.pop(context);
            if (widget.onClose != null) {
              widget.onClose!();
            }
          },
        ),
      ],
    );
  }

  Widget _buildSubscriptionDetails() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Abonnement Annuelle",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                "Facturation annuelle",
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const Text(
            "29.900 F cfa",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodTabs() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => setState(() => isCard = true),
            icon: SvgPicture.asset(
              'assets/icons/7.svg',
              width: 18,
            ),
            label: const Text("Carte bancaire"),
            style: OutlinedButton.styleFrom(
              backgroundColor: isCard
                  ? AppColors.primary.withValues(alpha: 0.1)
                  : Colors.white,
              foregroundColor: isCard ? AppColors.primary : AppColors.textPrimary,
              side: BorderSide(
                color: isCard ? AppColors.primary : AppColors.border,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => setState(() => isCard = false),
            icon: const Icon(Icons.phone_android_outlined),
            label: const Text("Mobile money"),
            style: OutlinedButton.styleFrom(
              backgroundColor: !isCard
                  ? AppColors.primary.withValues(alpha: 0.1)
                  : Colors.white,
              foregroundColor: !isCard ? AppColors.primary : AppColors.textPrimary,
              side: BorderSide(
                color: !isCard ? AppColors.primary : AppColors.border,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCardForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Card holder name
        const Text(
          "Nom sur la carte",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          decoration: InputDecoration(
            hintText: "Lamine wade",
            hintStyle: TextStyle(color: AppColors.textSecondary.withValues(alpha: 0.5)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Card number
        const Text(
          "Numéro de carte",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: "1234 5678 9012 3456",
            hintStyle: TextStyle(color: AppColors.textSecondary.withValues(alpha: 0.5)),
            prefixIcon: const Icon(Icons.credit_card, color: AppColors.primary),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Expiry date and CVV
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Date d'expiration",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    keyboardType: TextInputType.datetime,
                    decoration: InputDecoration(
                      hintText: "MM/AA",
                      hintStyle: TextStyle(color: AppColors.textSecondary.withValues(alpha: 0.5)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: AppColors.primary),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "CVV",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: "123",
                      hintStyle: TextStyle(color: AppColors.textSecondary.withValues(alpha: 0.5)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: AppColors.primary),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 25),

        // Pay button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
              elevation: 0,
            ),
            onPressed: () {
              // Handle payment
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Paiement en cours...'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: const Text(
              "Payer",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileMoney() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: [
        _buildPayBox('assets/images/2.png', "Wave"),
        _buildPayBox('assets/images/3.png', "Yas money"),
        _buildPayBox('assets/images/4.png', "Orange money"),
        _buildPayBox('assets/images/5.png', "Kay pay"),
      ],
    );
  }

  Widget _buildPayBox(String img, String label) {
    return GestureDetector(
      onTap: () {
        // Handle mobile money selection
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Paiement via $label en cours...'),
            backgroundColor: AppColors.success,
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              img,
              width: 45,
              height: 45,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.account_balance_wallet,
                  size: 45,
                  color: AppColors.primary,
                );
              },
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTermsText() {
    return Text(
      "En effectuant ce paiement, vous acceptez nos conditions générales d'utilisation et notre politique de confidentialité.",
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 12,
        color: AppColors.textSecondary,
      ),
    );
  }
}

/// Helper function to show payment modal
void showPaymentModal(BuildContext context, {VoidCallback? onClose}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => PaymentModal(onClose: onClose),
  );
}