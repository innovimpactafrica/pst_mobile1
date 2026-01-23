import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../utils/HexColor.dart';
import '../../widgets/money_mode.dart';
import 'verification.dart';

class MdpOubliePage extends StatefulWidget {
  const MdpOubliePage({super.key});

  @override
  State<MdpOubliePage> createState() => _MdpOubliePageState();
}

class _MdpOubliePageState extends State<MdpOubliePage> {
  bool usePhone = true;
  final TextEditingController _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  // ✅ Fenêtre modale blanche
  void _showSubscriptionModal(BuildContext context) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Subscription',
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 400),
    pageBuilder: (_, __, ___) => const SizedBox.shrink(),
    transitionBuilder: (context, anim, _, child) {
      final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, -1),
          end: Offset.zero,
        ).animate(curved),
        child: PaymentModal(
          onClose: () {
            setState(() {
              usePhone = true; // ✅ revient automatiquement à l’onglet Téléphone
            });
          },
        ),
      );
    },
  );
}


  void _onSendCode() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const Verification()),
    );
  }

  Widget _buildSegmentedControl() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: HexColor('#EEF2F8'),
        borderRadius: BorderRadius.circular(40),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => usePhone = true),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: usePhone ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(36),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.phone,
                        color: usePhone
                            ? HexColor('#2F2884')
                            : HexColor('#4B5563')),
                    const SizedBox(width: 8),
                    Text(
                      'Téléphone',
                      style: TextStyle(
                        color: usePhone
                            ? HexColor('#2F2884')
                            : HexColor('#4B5563'),
                        fontWeight:
                            usePhone ? FontWeight.w700 : FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() => usePhone = false);
                Future.delayed(const Duration(milliseconds: 100), () {
                  _showSubscriptionModal(context);
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: !usePhone ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(36),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.email,
                        color: !usePhone
                            ? HexColor('#2F2884')
                            : HexColor('#4B5563')),
                    const SizedBox(width: 8),
                    Text(
                      'Email',
                      style: TextStyle(
                        color: !usePhone
                            ? HexColor('#2F2884')
                            : HexColor('#4B5563'),
                        fontWeight:
                            !usePhone ? FontWeight.w700 : FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // ✅ Fond blanc pur
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: HexColor('#F8FAFC'),
                        shape: BoxShape.circle,
                      ),
                      child: SvgPicture.asset('assets/icons/back.svg'),
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      SvgPicture.asset('assets/icons/4.svg'),
                      const SizedBox(width: 8),
                      Text(
                        'Français',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: HexColor('#374151'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 18),
              Image.asset('assets/images/2.jpg',
                  width: 120, height: 120, fit: BoxFit.contain),

              const SizedBox(height: 18),
              Text(
                'Mot de passe oublié',
                style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: HexColor('#2F2884')),
              ),
              const SizedBox(height: 12),
              Text(
                "Entrer votre numéro de téléphone ou votre\nadresse email pour recevoir un OTP",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: HexColor('#4B5563')),
              ),
              const SizedBox(height: 22),

              _buildSegmentedControl(),
              const SizedBox(height: 20),

              if (usePhone) ...[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Numéro de téléphone',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: HexColor('#111827'),
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: 'Ex: 77 123 45 67',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          BorderSide(color: HexColor('#E6EEF6')),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          BorderSide(color: HexColor('#E6EEF6')),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                  ),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: HexColor('#2F2884'),
                      padding:
                          const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                    onPressed: _onSendCode,
                    child: const Text(
                      'Envoyer le code',
                      style:
                          TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
