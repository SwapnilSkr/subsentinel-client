import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class WelcomeStep extends StatelessWidget {
  final VoidCallback onNext;

  const WelcomeStep({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.primaryCard,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: const Icon(
              Icons.subscriptions_rounded,
              size: 60,
              color: AppColors.active,
            ),
          ),
          const SizedBox(height: 40),
          Text(
            'Welcome to\nSubSentinel',
            style: Theme.of(
              context,
            ).textTheme.displayMedium?.copyWith(color: AppColors.textPrimary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            "Let's personalize your experience.\nWe'll ask a few questions to help you track\nand manage your subscriptions.",
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.active,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Get Started',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
