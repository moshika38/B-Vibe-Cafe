import 'package:bvibe/const/snack/app.snack.dart';
import 'package:bvibe/data/helper/auth.helper.dart';
import 'package:bvibe/features/auth/widgets/form.panel.dart';
import 'package:bvibe/features/auth/widgets/img.panel.dart';
import 'package:flutter/material.dart';
import 'package:bvibe/const/theme/theme.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _staffIdController = TextEditingController();
  final _pinController = TextEditingController();
  bool obscurePin = true;

  @override
  void dispose() {
    _staffIdController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  void checkAuth() async {
    final staffId = _staffIdController.text.trim();
    final pin = _pinController.text.trim();

    if (staffId.isEmpty || pin.isEmpty) {
      AppSnack.errorSnack(context, "Please enter Staff ID and PIN");
      return;
    }

    if (pin.length < 4 || pin.length > 8 || !RegExp(r'^\d+$').hasMatch(pin)) {
      AppSnack.errorSnack(context, "PIN must be 4–8 digits");
      return;
    }

    final userMap = await AuthHelper.instance.getUser(staffId);

    if (userMap != null && userMap['password'] == pin) {
      if (mounted) {
        context.go('/dashboard');
      }
    } else {
      if (mounted) {
        AppSnack.errorSnack(context, "Invalid Staff ID or PIN");
      }
    }
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
            border: Border.all(color: AppColors.cardBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 48,
                offset: const Offset(0, 16),
                spreadRadius: -4,
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
                Expanded(
                  child: FormPanel(
                    staffIdController: _staffIdController,
                    pinController: _pinController,
                    obscurePin: obscurePin,
                    onLogin: () {
                      checkAuth();
                    },
                    onForgotPassword: () {},
                    onChangeStation: () {
                      setState(() {
                        obscurePin = !obscurePin;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
