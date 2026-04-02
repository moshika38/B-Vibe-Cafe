import 'package:bvibe/const/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';

class CreateStaffCard extends StatelessWidget {
  final TextEditingController staffIdController;
  final TextEditingController pinController;
  final bool obscurePin;
  final VoidCallback onCreate;
  final VoidCallback onToggleObscurePin;
  final VoidCallback onBackToLogin;

  const CreateStaffCard({
    super.key,
    required this.staffIdController,
    required this.pinController,
    required this.obscurePin,
    required this.onCreate,
    required this.onToggleObscurePin,
    required this.onBackToLogin,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: 480,
          padding: const EdgeInsets.all(48),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.5), // Frosted glass look
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.8),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo inside header
              Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person_add_alt_1_rounded,
                    size: 48,
                    color: AppColors.primary,
                  ),
                ).animate().scale(curve: Curves.easeOutBack, duration: 600.ms),
              ),
              const SizedBox(height: 24),

              Text(
                'Create New Staff',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),

              const SizedBox(height: 8),

              Text(
                'Register a new staff member to the system.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0),

              const SizedBox(height: 40),

              _buildLabel(context, 'Staff ID'),
              const SizedBox(height: 8),
              TextField(
                controller: staffIdController,
                decoration: const InputDecoration(
                  hintText: 'Enter staff ID number',
                  prefixIcon: Icon(
                    Icons.badge_outlined,
                    color: AppColors.textHint,
                  ),
                ),
              ).animate().fadeIn(delay: 400.ms).slideX(begin: 0.1, end: 0),

              const SizedBox(height: 24),

              _buildLabel(context, 'Security PIN'),
              const SizedBox(height: 8),
              TextField(
                controller: pinController,
                obscureText: obscurePin,
                decoration: InputDecoration(
                  hintText: '••••••••',
                  prefixIcon: const Icon(
                    Icons.lock_outline,
                    color: AppColors.textHint,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscurePin
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: AppColors.textHint,
                    ),
                    onPressed: onToggleObscurePin,
                  ),
                ),
              ).animate().fadeIn(delay: 500.ms).slideX(begin: 0.1, end: 0),

              const SizedBox(height: 40),

              ElevatedButton(
                onPressed: onCreate,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  elevation: 0,
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shadowColor: AppColors.primary.withValues(alpha: 0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Complete Registration',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ).animate().fadeIn(delay: 600.ms).scale(),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(BuildContext context, String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
