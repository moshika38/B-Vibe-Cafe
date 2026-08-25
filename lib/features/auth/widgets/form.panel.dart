import 'package:bvibe/const/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      padding: const EdgeInsets.symmetric(horizontal: 56, vertical: 44),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLogo()
              .animate()
              .fadeIn(delay: 200.ms, duration: 400.ms)
              .slideY(begin: -0.1, end: 0),

          const SizedBox(height: 36),

          Text(
                'Welcome back',
                style: Theme.of(context).textTheme.headlineMedium,
              )
              .animate()
              .fadeIn(delay: 300.ms, duration: 400.ms)
              .slideY(begin: 0.15, end: 0),

          const SizedBox(height: 8),

          Text(
                'Sign in to your station to begin your shift',
                style: Theme.of(context).textTheme.bodyMedium,
              )
              .animate()
              .fadeIn(delay: 350.ms, duration: 400.ms)
              .slideY(begin: 0.15, end: 0),

          const SizedBox(height: 38),

          _buildLabel('Staff ID'),
          const SizedBox(height: 10),
          TextField(
                autofocus: true,
                controller: widget.staffIdController,
                textInputAction: TextInputAction.next,
                onSubmitted: (_) => FocusScope.of(context).nextFocus(),
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

          const SizedBox(height: 24),

          _buildLabel('PIN / Password'),
          const SizedBox(height: 10),
          TextField(
                autofocus: false,
                controller: widget.pinController,
                obscureText: widget.obscurePin,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(8),
                ],
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => widget.onLogin(),
                decoration: InputDecoration(
                  hintText: '\u2022\u2022\u2022\u2022\u2022\u2022\u2022\u2022',
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

          const SizedBox(height: 32),

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

          Container(
            height: 1,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: const BoxDecoration(
              color: AppColors.divider,
            ),
          ),
          const SizedBox(height: 8),

          Center(
            child: TextButton.icon(
              onPressed: widget.onForgotPassword,
              icon: const Icon(
                Icons.lock_reset,
                size: 18,
                color: AppColors.textSecondary,
              ),
              label: Text(
                'Forgot PIN?',
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
          ),

          const SizedBox(height: 4),

          Center(
            child: TextButton.icon(
              onPressed: widget.onChangeStation,
              icon: const Icon(
                Icons.swap_horiz,
                size: 18,
                color: AppColors.textSecondary,
              ),
              label: Text(
                'Change Station',
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
          ),

          const SizedBox(height: 12),

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
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x3316A34A),
                        blurRadius: 6,
                      ),
                    ],
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
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primarySoft,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.restaurant, color: AppColors.primary, size: 22),
        ),
        const SizedBox(width: 10),
        Text('Lumina', style: Theme.of(context).textTheme.headlineSmall),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Text(text, style: Theme.of(context).textTheme.labelMedium);
  }
}
