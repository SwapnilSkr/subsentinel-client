import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/onboarding_provider.dart';

class IntegrationStep extends ConsumerStatefulWidget {
  final VoidCallback onNext;

  const IntegrationStep({super.key, required this.onNext});

  @override
  ConsumerState<IntegrationStep> createState() => _IntegrationStepState();
}

class _IntegrationStepState extends ConsumerState<IntegrationStep> {
  bool _gmailEnabled = false;
  bool _smsEnabled = false;
  bool _initialized = false;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final onboardingState = ref.watch(onboardingProvider);
    final user = authState.user;
    final gmailAvailable =
        (user?.googleId?.trim().isNotEmpty ?? false) ||
        (user?.email?.trim().isNotEmpty ?? false);
    final smsAvailable = user?.phone?.trim().isNotEmpty ?? false;

    if (!_initialized) {
      _gmailEnabled =
          onboardingState.data.gmailIntegrationEnabled && gmailAvailable;
      _smsEnabled = onboardingState.data.smsIntegrationEnabled && smsAvailable;
      _initialized = true;
    }

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          Text(
            'Which alert sources\nshould we use?',
            style: Theme.of(
              context,
            ).textTheme.headlineLarge?.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 12),
          Text(
            'Pick the channels you want SubSentinel to prioritize for detecting billing signals.',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 32),
          _IntegrationOptionCard(
            title: 'Gmail inbox',
            description: gmailAvailable
                ? 'Use your signed-in Google account to detect bank and subscription emails.'
                : 'Unavailable right now. Sign in with Google if you want Gmail-based detection.',
            icon: Icons.mail_outline_rounded,
            accentColor: AppColors.active,
            value: _gmailEnabled,
            enabled: gmailAvailable,
            onChanged: (value) {
              HapticFeedback.selectionClick();
              setState(() => _gmailEnabled = value);
            },
          ),
          const SizedBox(height: 12),
          _IntegrationOptionCard(
            title: 'SMS alerts',
            description: smsAvailable
                ? 'Use your verified phone as an SMS signal source preference for transaction and renewal alerts.'
                : 'Unavailable right now. Verify a phone number if you want SMS-based signals.',
            icon: Icons.sms_outlined,
            accentColor: AppColors.scanLine,
            value: _smsEnabled,
            enabled: smsAvailable,
            onChanged: (value) {
              HapticFeedback.selectionClick();
              setState(() => _smsEnabled = value);
            },
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'These choices are stored as data-source preferences and used in your dashboard and account state. They do not replace your sign-in method.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                ref
                    .read(onboardingProvider.notifier)
                    .updateIntegrations(
                      gmail: _gmailEnabled && gmailAvailable,
                      sms: _smsEnabled && smsAvailable,
                    );
                widget.onNext();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.active,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Continue',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IntegrationOptionCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color accentColor;
  final bool value;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  const _IntegrationOptionCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.accentColor,
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = value ? accentColor : AppColors.glassBorder;
    final backgroundColor = value
        ? accentColor.withValues(alpha: 0.1)
        : AppColors.primaryCard;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: enabled ? 1 : 0.6,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: value ? 2 : 1),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: accentColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Switch.adaptive(
              value: value,
              onChanged: enabled ? onChanged : null,
              activeColor: accentColor,
            ),
          ],
        ),
      ),
    );
  }
}
