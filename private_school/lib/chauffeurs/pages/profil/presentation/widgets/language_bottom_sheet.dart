import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../../core/utils/app_colors.dart';


class LanguageBottomSheet extends StatefulWidget {
  const LanguageBottomSheet({super.key});

  @override
  State<LanguageBottomSheet> createState() => _LanguageBottomSheetState();
}

class _LanguageBottomSheetState extends State<LanguageBottomSheet> {
  final List<Map<String, dynamic>> languages = [
    {
      'name': 'Français',
      'code': 'fr',
      'flag': '🇫🇷',
    },
    {
      'name': 'Anglais',
      'code': 'en',
      'flag': '🇬🇧',
    },
  ];

  String? selectedLanguage;

  @override
void initState() {
  super.initState();
  
}

@override
void didChangeDependencies() {
  super.didChangeDependencies();
  if (selectedLanguage == null) {
    setState(() {
      selectedLanguage = context.locale.languageCode;
    });
  }
}

  void _changeLanguage(String languageCode) async {
    setState(() {
      selectedLanguage = languageCode;
    });

    // Changer la langue avec easy_localization
    await context.setLocale(Locale(languageCode));

    // Attendre un peu pour que l'utilisateur voie la sélection
    await Future.delayed(const Duration(milliseconds: 300));

    // Fermer le modal
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header avec titre et bouton fermer
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'change_language'.tr(), // Traduction
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    child: const Icon(
                      Icons.close,
                      color: AppColors.textPrimary,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Liste des langues
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
            child: Column(
              children: languages.map((lang) {
                final isSelected = selectedLanguage == lang['code'];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GestureDetector(
                    onTap: () => _changeLanguage(lang['code']),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textSecondary.withValues(alpha: 0.2),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          // Drapeau
                          Text(
                            lang['flag'],
                            style: const TextStyle(fontSize: 24),
                          ),
                          const SizedBox(width: 12),

                          // Nom de la langue
                          Expanded(
                            child: Text(
                              lang['name'],
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight:
                                    isSelected ? FontWeight.w600 : FontWeight.w400,
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.textPrimary,
                              ),
                            ),
                          ),

                          // Icône de sélection
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected ? AppColors.primary : null,
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.textSecondary.withValues(alpha: 0.3),
                                width: 2,
                              ),
                            ),
                            child: isSelected
                                ? const Icon(
                                    Icons.check,
                                    size: 16,
                                    color: AppColors.white,
                                  )
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// Fonction helper pour afficher le modal
void showLanguageBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => const LanguageBottomSheet(),
  );
}