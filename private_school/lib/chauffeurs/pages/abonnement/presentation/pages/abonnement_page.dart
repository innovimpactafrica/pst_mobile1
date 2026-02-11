

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../../core/utils/app_colors.dart';
import '../../domain/bloc/subscription_bloc.dart';
import '../../domain/bloc/subscription_event.dart';
import '../../domain/bloc/subscription_state.dart';
import '../../data/models/subscription_model.dart';
import '../../../../../chauffeurs/widgets/money_mode.dart';

class AbonnementPage extends StatefulWidget {
  const AbonnementPage({super.key});

  @override
  State<AbonnementPage> createState() => _AbonnementPageState();
}

class _AbonnementPageState extends State<AbonnementPage> {
  SubscriptionModel? _currentSubscription;
  List<SubscriptionPlan> _plans = [];
  bool _isAnnual = false; // 🆕 Toggle state

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    context.read<SubscriptionBloc>().add(LoadSubscriptionPlansEvent());
    context.read<SubscriptionBloc>().add(LoadCurrentSubscriptionEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: BlocListener<SubscriptionBloc, SubscriptionState>(
                  listener: (context, state) {
                    if (state is SubscriptionPlansLoaded) {
                      setState(() {
                        _plans = state.plans;
                      });
                    } else if (state is CurrentSubscriptionLoaded) {
                      setState(() {
                        _currentSubscription = state.subscription;
                      });
                    } else if (state is SubscriptionActive) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('subscription_activated'.tr()),
                          backgroundColor: AppColors.success,
                        ),
                      );
                      _loadData();
                    }
                  },
                  child: _buildContent(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Text(
            'subscription'.tr(),
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return BlocBuilder<SubscriptionBloc, SubscriptionState>(
      builder: (context, state) {
        if (state is SubscriptionLoading) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(color: AppColors.primary),
                const SizedBox(height: 12),
                Text('loading'.tr()),
              ],
            ),
          );
        }

        if (state is SubscriptionError) {
          return _buildErrorWidget(state.message);
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCurrentSubscriptionCard(),
              const SizedBox(height: 24),
              _buildChooseYourPlanSection(),
              const SizedBox(height: 16),
              _buildToggle(), // 🆕 Toggle Mensuel/Annuel
              const SizedBox(height: 20),
              _buildAvailablePlansSection(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCurrentSubscriptionCard() {
    final bool hasSubscription = _currentSubscription != null;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.blackOpacity05,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.card_membership,
              color: AppColors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'my_subscription'.tr(), 
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    if (hasSubscription)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '● ${'active'.tr()}', // "● Actif"
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.success,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                 hasSubscription
    ? '${'expires_on'.tr()}: ${DateFormat.yMd(context.locale.toString()).format(_currentSubscription!.expiryDate)}'
    : 'no_active_subscription'.tr(),

                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChooseYourPlanSection() {
    return Text(
      'choose_your_plan'.tr(), // "Choisissez votre plan"
      style: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  // 🆕 Toggle Mensuel/Annuel avec couleurs exactes Figma
  Widget _buildToggle() {
    return Row(
      children: [
        Expanded(
          child: _buildToggleButton(
            label: 'monthly'.tr(), // "Mensuel"
            isSelected: !_isAnnual,
            onTap: () => setState(() => _isAnnual = false),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildToggleButton(
            label: 'annual'.tr(), // "Annuel"
            isSelected: _isAnnual,
            onTap: () => setState(() => _isAnnual = true),
          ),
        ),
      ],
    );
  }

  Widget _buildToggleButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1) 
              : AppColors.white, 
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: isSelected
                  ? AppColors.primary 
                  : AppColors.textPrimary, 
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvailablePlansSection() {
    if (_plans.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Text(
            'no_plans_available'.tr(),
            style: GoogleFonts.inter(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    // Filtrer les plans selon le toggle
    final filteredPlans = _plans.where((plan) {
      final isMonthly = plan.durationDays <= 31;
      return _isAnnual ? !isMonthly : isMonthly;
    }).toList();

    if (filteredPlans.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Text(
            'no_plans_available'.tr(),
            style: GoogleFonts.inter(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    return Column(
      children: filteredPlans.map((plan) => _buildPlanCard(plan)).toList(),
    );
  }

  Widget _buildPlanCard(SubscriptionPlan plan) {
    final bool isAnnual = plan.durationDays > 31;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isAnnual
              ? AppColors.primary
              : AppColors.border,
          width: isAnnual ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.blackOpacity05,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🆕 Badge "Recommandé" pour l'annuel
          if (isAnnual)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'recommended'.tr(), // "Recommandé"
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.white,
                ),
              ),
            ),
          if (isAnnual) const SizedBox(height: 12),

          Text(
            plan.name,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),

          // Prix
          Row(
            children: [
              Text(
                '${plan.price.toStringAsFixed(0)} FCFA',
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
             Text(
         isAnnual ? 'per_year'.tr() : 'per_month_short'.tr(),

                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Description
          Text(
            isAnnual ? 'annual_billing'.tr() : 'monthly_billing'.tr(),
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),

          // Features avec checkmarks violets
          if (plan.features.isNotEmpty) ...[
            const SizedBox(height: 16),
            ...plan.features.take(3).map(
                  (feature) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check,
                          size: 20,
                          color: AppColors.primary, 
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            feature,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          ],
          const SizedBox(height: 16),

         
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () => _showPaymentModal(plan),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                'select'.tr(), // 🆕 "Sélectionner"
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPaymentModal(SubscriptionPlan plan) {
    showPaymentModal(
      context,
      plan: plan,
      onPaymentComplete: () {
        _loadData();
      },
    );
  }

  Widget _buildErrorWidget(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
             'error'.tr(),

              textAlign: TextAlign.center,
              style: GoogleFonts.inter(color: AppColors.error),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadData,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: Text('retry'.tr()),
            ),
          ],
        ),
      ),
    );
  }
}