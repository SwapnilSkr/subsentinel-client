import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'otp_screen.dart';
import '../../data/providers/auth_provider.dart';
import '../../core/theme/app_colors.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    // Navigate to OTP if success (handled here for simplicity or use listener)
    // Actually better to handle navigation in button press with await

    return Scaffold(
      backgroundColor: AppColors.canvasFor(context),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo
              Text(
                "SubSentinel",
                textAlign: TextAlign.center,
                style: GoogleFonts.interTight(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimaryFor(context),
                  letterSpacing: -1.0,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "The 2026 Financial Cockpit",
                textAlign: TextAlign.center,
                style: GoogleFonts.interTight(
                  fontSize: 16,
                  color: AppColors.textSecondaryFor(context),
                ),
              ),
              const SizedBox(height: 48),

              // Phone Input Card
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceFor(context),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.glassBorderFor(context)),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.active.withValues(alpha: 0.05),
                      blurRadius: 20,
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: TextField(
                  controller: _phoneController,
                  style: GoogleFonts.interTight(
                    color: AppColors.textPrimaryFor(context),
                    fontSize: 18,
                  ),
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "+1 555 000 0000",
                    hintStyle: TextStyle(
                      color: AppColors.textMutedFor(context),
                    ),
                    icon: Icon(Icons.phone_iphone, color: AppColors.active),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Send Code Button
              ElevatedButton(
                onPressed: _isLoading ? null : _handleSendOtp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.active,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.black,
                        ),
                      )
                    : Text(
                        "Send Access Code",
                        style: GoogleFonts.interTight(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
              ),

              const SizedBox(height: 32),

              // Divider
              Row(
                children: [
                  Expanded(
                    child: Divider(color: AppColors.glassBorderFor(context)),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      "OR",
                      style: TextStyle(color: AppColors.textMutedFor(context)),
                    ),
                  ),
                  Expanded(
                    child: Divider(color: AppColors.glassBorderFor(context)),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Google Button
              OutlinedButton.icon(
                onPressed: _handleGoogleSignIn,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: AppColors.glassBorderFor(context)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: Icon(
                  Icons.g_mobiledata,
                  size: 28,
                  color: AppColors.textPrimaryFor(context),
                ),
                label: Text(
                  "Continue with Google",
                  style: GoogleFonts.interTight(
                    color: AppColors.textPrimaryFor(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleSendOtp() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      // Call provider
      await ref.read(authProvider.notifier).sendOtp(phone);

      if (mounted) {
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => OtpScreen(phone: phone)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(authProvider.notifier).signInWithGoogle();
      // If success, the main.dart router will handle navigation based on auth state
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Google Sign-In Failed: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
