// Subscription page with real API data
// Path: lib/chauffeurs/pages/abonnement/presentation/pages/abonnement_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../../core/utils/app_colors.dart';
import '../../domain/bloc/subscription_bloc.dart';
import '../../domain/bloc/subscription_event.dart';
import '../../domain/bloc/subscription_state.dart';
import '../../data/models/subscription_model.dart';
import '../widgets/subscription_card.dart';
import '../widgets/current_subscription_card.dart';
import '../widgets/plan_toggle.dart';

class AbonnementPage extends StatefulWidget {
  const AbonnementPage({super.key});

  @override
  State<AbonnementPage> createState() => _AbonnementPageState();
}

class _AbonnementPageState extends State<AbonnementPage> {
  bool _isAnnual = false;
  SubscriptionModel? _currentSubscription;

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
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: BlocListener<SubscriptionBloc, SubscriptionState>(
                listener: (context, state) {
                 if (state is CurrentSubscriptionLoaded) {
                 debugPrint("Abonnement reçu: ${state.subscription?.plan}");
                 setState(() {
                 _currentSubscription = state.subscription;
                });
                } else if (state is SubscriptionActive) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Abonnement activé avec succès !'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                    _loadData();
                  }
                },
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildCurrentSubscription(),
                      const SizedBox(height: 24),
                      _buildPlanToggle(),
                      const SizedBox(height: 20),
                      _buildPlansSection(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Abonnements',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textWhite,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentSubscription() {
    if (_currentSubscription == null) {
      return CurrentSubscriptionCard(
        plan: 'Aucun abonnement actif',
        expiryDate: '-',
        isActive: false,
      );
    }

    final dateFormat = DateFormat('dd/MM/yyyy');

    return CurrentSubscriptionCard(
      plan: _currentSubscription!.plan,
      expiryDate: dateFormat.format(_currentSubscription!.expiryDate),
      isActive: _currentSubscription!.isActive,
    );
  }

  Widget _buildPlanToggle() {
    return PlanToggle(
      isAnnual: _isAnnual,
      onToggle: (value) {
        setState(() {
          _isAnnual = value;
        });
      },
    );
  }

  Widget _buildPlansSection() {
    return BlocBuilder<SubscriptionBloc, SubscriptionState>(
      builder: (context, state) {
        if (state is SubscriptionLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (state is SubscriptionError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                children: [
                  Icon(Icons.error_outline, size: 48, color: AppColors.error),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.error),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    ),
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is SubscriptionPlansLoaded) {
          final plans = state.plans;

          if (plans.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Text(
                  'Aucun plan disponible',
                  style: TextStyle(color: AppColors.textGrey),
                ),
              ),
            );
          }

          return Column(
            children: plans.map((plan) {
              final isAnnualPlan = plan.durationDays >= 365;
              final shouldShow = _isAnnual ? isAnnualPlan : !isAnnualPlan;

              if (!shouldShow) return const SizedBox.shrink();

              final displayPrice = plan.price;
             // final pricePerMonth = isAnnualPlan ? plan.price / 12 : plan.price;
              final savingsPercent = isAnnualPlan ? 30 : 0;

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: SubscriptionCard(
                  title: plan.name,
                  price: displayPrice,
                  period: _isAnnual ? '/an' : '/mois',
                  features: plan.features.isNotEmpty
                      ? plan.features
                      : [
                          'Profil visible auprès des parents',
                          'Réception des demandes de trajets',
                          'Support prioritaire',
                        ],
                  isRecommended: isAnnualPlan && _isAnnual,
                  savings: isAnnualPlan && _isAnnual
                      ? 'Économisez $savingsPercent% par rapport à l\'abonnement mensuel'
                      : null,
                  onSelect: () => _onSelectPlan(plan),
                ),
              );
            }).toList(),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  void _onSelectPlan(SubscriptionPlan plan) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildPaymentSheet(plan),
    );
  }

  Widget _buildPaymentSheet(SubscriptionPlan plan) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.textWhite,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Confirmer votre abonnement',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Vous allez souscrire à ${plan.name}',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '${plan.price.toStringAsFixed(0)} FCFA',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
                context.read<SubscriptionBloc>().add(
                  SubscribeEvent(plan.id, 'default_payment_method'),
                );
              },
              child: Text(
                'Sélectionner',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textWhite,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
