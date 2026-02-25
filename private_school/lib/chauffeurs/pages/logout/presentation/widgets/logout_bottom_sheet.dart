

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/app_constants.dart';
import '../../domain/bloc/logout_bloc.dart';
import '../../domain/bloc/logout_event.dart';
import '../../domain/bloc/logout_state.dart';

void showLogoutBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    isDismissible: true,
    enableDrag: true,
    builder: (context) => BlocProvider(
      create: (_) => LogoutBloc(),
      child: const LogoutBottomSheet(),
    ),
  );
}

class LogoutBottomSheet extends StatelessWidget {
  const LogoutBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<LogoutBloc, LogoutState>(
      listener: (context, state) {
        if (state is LogoutSuccess) {
          Navigator.pop(context);
          Navigator.pushNamedAndRemoveUntil(
            context,
           '/role-selection', 
            (route) => false, 
          );
        } else if (state is LogoutError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: AppConstants.spacingXXL, vertical: 40),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppConstants.radiusXL),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spacingXXL),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.grey200,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              const SizedBox(height: AppConstants.spacingXXL),

              Text(
                'logout'.tr(),
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: AppConstants.spacingM),
              // Message de confirmation
              Text(
                'logout_confirm_message'.tr(),
                style: GoogleFonts.inter(
                  fontSize: AppConstants.fontSizeL,
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: AppConstants.spacingXXXL),

              // Boutons
              BlocBuilder<LogoutBloc, LogoutState>(
                builder: (context, state) {
                  final isLoading = state is LogoutLoading;

                  return IntrinsicHeight( 
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Bouton "Annuler"
                        Expanded(
                          child: TextButton(
                            onPressed: isLoading
                                ? null
                                : () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                vertical: AppConstants.spacingL,
                              ),
                            ),
                            child: Text(
                             'cancel'.tr(),
                              style: GoogleFonts.inter(
                                fontSize: AppConstants.fontSizeL,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary, 
                              ),
                            ),
                          ),
                        ),

                        
                        const VerticalDivider(
                          color: AppColors.divider, 
                          thickness: 1,
                          width: 1,
                          indent: 8, 
                          endIndent: 8, 
                        ),

                        
                        Expanded(
                          child: TextButton(
                            onPressed: isLoading
                                ? null
                                : () {
                                    context
                                        .read<LogoutBloc>()
                                        .add(LogoutRequestedEvent());
                                  },
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                vertical: AppConstants.spacingL,
                              ),
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.error,
                                    ),
                                  )
                                : Text(
                                   'logout'.tr(), 
                                    style: GoogleFonts.inter(
                                      fontSize: AppConstants.fontSizeL,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.error, 
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
  
}