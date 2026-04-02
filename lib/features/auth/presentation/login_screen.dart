import 'package:bvibe/components/popup.window.dart';
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
    if (_staffIdController.text.isEmpty || _pinController.text.isEmpty) {
      AppSnack.errorSnack(context, "Please enter staff ID and PIN");
    } else {
      final userMap = await AuthHelper.instance.getUser(
        _staffIdController.text,
      );

      if (userMap != null && userMap['password'] == _pinController.text) {
        if (userMap['username'] == "user" && userMap['password'] == "1234") {
          PopupWindow.show(
            context: context,
            type: PopupType.warning,
            title: "Warning",
            message: "You have using dummy account. Please Create account",
            primaryButtonText: "Create Now",
            onPrimaryPressed: () {
              Navigator.pop(context);
              context.go('/create');
            },
          );
        } else {
          context.go('/dashboard');
        }
      } else {
        AppSnack.errorSnack(context, "Invalid staff ID or PIN");
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
