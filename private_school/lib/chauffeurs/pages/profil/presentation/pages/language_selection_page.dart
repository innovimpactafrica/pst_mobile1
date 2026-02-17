import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/app_constants.dart';

class LanguageSelectionPage extends StatefulWidget {
  const LanguageSelectionPage({super.key});

  @override
  State<LanguageSelectionPage> createState() => _LanguageSelectionPageState();
}

class _LanguageSelectionPageState extends State<LanguageSelectionPage> {
  // Langue sélectionnée par défaut (à lier plus tard à ton système de trad)
  String selectedLanguage = 'Français';

  final List<Map<String, String>> languages = [
    {'name': 'Français', 'code': 'fr'},
    {'name': 'English', 'code': 'en'},
    {'name': 'Arabic', 'code': 'ar'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary, // Le violet du profil
      body: SafeArea(
        child: Column(
          children: [
            // Header avec bouton retour et titre
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spacingL,
                vertical: AppConstants.spacingXL,
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
                  ),
                  Text(
                    'Langue',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textWhite,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppConstants.spacingL),

            // Zone blanche
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(AppConstants.radiusXXL),
                    topRight: Radius.circular(AppConstants.radiusXXL),
                  ),
                ),
                child: ListView.separated(
                  padding: const EdgeInsets.all(AppConstants.spacingXL),
                  itemCount: languages.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final lang = languages[index];
                    final isSelected = selectedLanguage == lang['name'];

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedLanguage = lang['name']!;
                        });
                        // TODO: Ajouter ici la logique pour changer la locale (ex: Bloc ou EasyLocalization)
                      },
                      child: Container(
                        
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.spacingXL,
                          vertical: AppConstants.spacingL + 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(AppConstants.radiusL),
                          border: Border.all(
                            color: isSelected ? AppColors.primary : Colors.transparent,
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              lang['name']!,
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                color: isSelected ? AppColors.primary : AppColors.textPrimary,
                              ),
                            ),
                            if (isSelected)
                              const Icon(
                                Icons.check_circle,
                                color: AppColors.primary,
                                size: 24,
                              )
                            else
                              Icon(
                                Icons.circle_outlined,
                                color: AppColors.grey200,
                                size: 24,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}