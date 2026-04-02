import 'package:bvibe/const/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class FormPanel extends StatefulWidget {
  final TextEditingController staffIdController;
  final TextEditingController pinController;
  final bool obscurePin;
  final VoidCallback onLogin;
  final VoidCallback onForgotPassword;
  final VoidCallback onChangeStation;

  const FormPanel({
    super.key,
    required this.staffIdController,
    required this.pinController,
    required this.obscurePin,
    required this.onLogin,
    required this.onForgotPassword,
    required this.onChangeStation,
  });

  @override
  State<FormPanel> createState() => _FormPanelState();
}

class _FormPanelState extends State<FormPanel> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 52, vertical: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Logo ──
          _buildLogo()
              .animate()
              .fadeIn(delay: 200.ms, duration: 400.ms)
              .slideY(begin: -0.1, end: 0),

          const SizedBox(height: 32),

          // ── Heading ──
          Text(
                'Welcome back',
                style: Theme.of(context).textTheme.headlineMedium,
              )
              .animate()
              .fadeIn(delay: 300.ms, duration: 400.ms)
              .slideY(begin: 0.15, end: 0),

          const SizedBox(height: 6),

          Text(
                'Sign in to your station to begin your shift',
                style: Theme.of(context).textTheme.bodyMedium,
              )
              .animate()
              .fadeIn(delay: 350.ms, duration: 400.ms)
              .slideY(begin: 0.15, end: 0),

          const SizedBox(height: 36),

          // ── Staff ID ──
          _buildLabel('Staff ID'),
          const SizedBox(height: 8),
          TextField(
                autofocus: true,
                controller: widget.staffIdController,
                decoration: const InputDecoration(
                  hintText: 'Enter your ID number',
                  prefixIcon: Icon(
                    Icons.badge_outlined,
                    color: AppColors.textHint,
                  ),
                ),
              )
              .animate()
              .fadeIn(delay: 400.ms, duration: 400.ms)
              .slideY(begin: 0.15, end: 0),

          const SizedBox(height: 22),

          // ── PIN / Password ──
          _buildLabel('PIN / Password'),

          const SizedBox(height: 8),
          TextField(
                autofocus: true,
                controller: widget.pinController,
                obscureText: widget.obscurePin,
                decoration: InputDecoration(
                  hintText: '••••••••',
                  prefixIcon: const Icon(
                    Icons.lock_outline,
                    color: AppColors.textHint,
                  ),

                  suffixIcon: IconButton(
                    icon: Icon(
                      widget.obscurePin
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: AppColors.textHint,
                    ),
                    onPressed: widget.onChangeStation,
                  ),
                ),
              )
              .animate()
              .fadeIn(delay: 450.ms, duration: 400.ms)
              .slideY(begin: 0.15, end: 0),

          const SizedBox(height: 28),

          // ── Login Button ──
          ElevatedButton(
                onPressed: widget.onLogin,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Login to Station'),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward, size: 20),
                  ],
                ),
              )
              .animate()
              .fadeIn(delay: 500.ms, duration: 400.ms)
              .slideY(begin: 0.2, end: 0),

          const Spacer(),

          // ── Divider ──
          const Divider(color: AppColors.divider),
          const SizedBox(height: 12),

          // ── Change Station ──
          Center(
            child: TextButton.icon(
              onPressed: widget.onChangeStation,
              icon: const Icon(
                Icons.swap_horiz,
                size: 20,
                color: AppColors.textSecondary,
              ),
              label: Text(
                'Change Station',
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
          ),

          const SizedBox(height: 8),

          // ── Status Footer ──
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.online,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'SYSTEM ONLINE',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                const SizedBox(width: 16),
                Text(
                  'V2.4.0-BUILD',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.textHint,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Row(
      children: [
        Icon(Icons.restaurant, color: AppColors.primary, size: 26),
        const SizedBox(width: 8),
        Text('Lumina', style: Theme.of(context).textTheme.headlineSmall),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Text(text, style: Theme.of(context).textTheme.labelMedium);
  }
}
