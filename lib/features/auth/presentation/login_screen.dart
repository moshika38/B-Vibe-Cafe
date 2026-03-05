import 'package:bvibe/features/auth/widgets/form.panel.dart';
import 'package:bvibe/features/auth/widgets/img.panel.dart';
import 'package:flutter/material.dart';
import 'package:bvibe/const/theme.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _staffIdController = TextEditingController();
  final _pinController = TextEditingController();
  final bool _obscurePin = true;

  @override
  void dispose() {
    _staffIdController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1100, maxHeight: 700),
          margin: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 40,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Row(
              children: [
                // ── Left: Image Panel ──
                Expanded(child: ImgPanel()),
                // ── Right: Form Panel ──
                Expanded(child: FormPanel(
                  staffIdController: _staffIdController,
                  pinController: _pinController,
                  obscurePin: _obscurePin,
                  onLogin: () {
                    // TODO: Login logic
                   
                      context.go('/dashboard');
                  },
                  onForgotPassword: () {
                    // TODO: Forgot PIN flow
                  },
                  onChangeStation: () {
                    // TODO: Change station flow
                  },
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }

   
}
