import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../data/providers/onboarding_provider.dart';
import '../../widgets/onboarding/welcome_step.dart';
import '../../widgets/onboarding/budget_step.dart';
import '../../widgets/onboarding/awareness_step.dart';
import '../../widgets/onboarding/categories_step.dart';
import '../../widgets/onboarding/add_subscriptions_step.dart';
import '../../widgets/onboarding/pain_points_step.dart';
import '../../widgets/onboarding/goals_step.dart';
import '../../widgets/onboarding/alerts_step.dart';
import '../../widgets/onboarding/completion_step.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void nextPage() {
    ref.read(onboardingProvider.notifier).nextStep();
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: Column(
          children: [
            if (_currentPage < 8) _buildProgressIndicator(),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [
                  WelcomeStep(onNext: nextPage),
                  BudgetStep(onNext: nextPage),
                  AwarenessStep(onNext: nextPage),
                  CategoriesStep(onNext: nextPage),
                  AddSubscriptionsStep(onNext: nextPage),
                  PainPointsStep(onNext: nextPage),
                  GoalsStep(onNext: nextPage),
                  AlertsStep(onNext: nextPage),
                  CompletionStep(
                    onComplete: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    final totalSteps = 8;
    final progress = (_currentPage / totalSteps).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_currentPage + 1} of $totalSteps',
                style: Theme.of(
                  context,
                ).textTheme.labelMedium?.copyWith(color: AppColors.textMuted),
              ),
              TextButton(
                onPressed: nextPage,
                child: Text(
                  'Skip',
                  style: Theme.of(
                    context,
                  ).textTheme.labelMedium?.copyWith(color: AppColors.textMuted),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.glassBackground,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.active),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }
}
