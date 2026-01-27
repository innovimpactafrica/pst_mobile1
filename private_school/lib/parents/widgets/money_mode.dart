import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../utils/HexColor.dart';

class PaymentModal extends StatefulWidget {
  final VoidCallback? onClose; // ✅ callback vers MdpOubliePage

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
            color: Colors.white, // ✅ fond blanc
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
                  // === HEADER ===
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          "Paiement de l'abonnement",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: HexColor('#2F2884'),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.grey),
                        onPressed: () {
                          Navigator.pop(context);
                          if (widget.onClose != null){
                                 widget.onClose!(); // ✅ notifier MdpOubliePage
                          }
                           
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // === DÉTAILS ABONNEMENT ===
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: HexColor('#F9FAFB'),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: HexColor('#E5E7EB')),
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
                              ),
                            ),
                            Text(
                              "Facturation annuelle",
                              style: TextStyle(
                                fontSize: 13,
                                color: HexColor('#6B7280'),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          "29.900 F cfa",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: HexColor('#2F2884'),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  // === Onglets Carte / Mobile Money ===
                  Row(
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
                                ? HexColor('#F3F0FF')
                                : Colors.white,
                            side: BorderSide(
                              color: isCard
                                  ? HexColor('#2F2884')
                                  : HexColor('#CBD5E1'),
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
                                ? HexColor('#F3F0FF')
                                : Colors.white,
                            side: BorderSide(
                              color: !isCard
                                  ? HexColor('#2F2884')
                                  : HexColor('#CBD5E1'),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  // === Contenu dynamique ===
                  if (isCard) _buildCardForm() else _buildMobileMoney(),

                  const SizedBox(height: 25),

                  Text(
                    "En effectuant ce paiement, vous acceptez nos conditions générales d’utilisation et notre politique de confidentialité.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: HexColor('#6B7280')),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // === Formulaire Carte bancaire (labels au-dessus) ===
  Widget _buildCardForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Nom sur la carte",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        TextField(
          decoration: InputDecoration(
            hintText: "Lamine wade",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),

        const SizedBox(height: 16),

        const Text(
          "Numéro de carte",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        TextField(
          decoration: InputDecoration(
            hintText: "1234 5678 9012 3456",
            prefixIcon: const Icon(Icons.credit_card),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),

        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Date d’expiration",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    decoration: InputDecoration(
                      hintText: "MM/AA",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
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
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    decoration: InputDecoration(
                      hintText: "123",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 25),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: HexColor('#38AA36'),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Payer",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }

  // === Mobile Money ===
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
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: HexColor('#E5E7EB')),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(img, width: 45, height: 45),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: HexColor('#111827'),
            ),
          ),
        ],
      ),
    );
  }
}
