import 'package:flutter/material.dart';
import 'package:bvibe/const/snack/app.snack.dart';
import 'package:bvibe/data/helper/auth.helper.dart';
import 'package:bvibe/data/model/auth.model.dart';
import 'package:bvibe/features/auth/widgets/auth_bg.decoration.dart';
import 'package:bvibe/features/auth/widgets/create_staff.card.dart';
import 'package:go_router/go_router.dart';

class CreateScreen extends StatefulWidget {
  const CreateScreen({super.key});

  @override
  State<CreateScreen> createState() => _CreateScreenState();
}

class _CreateScreenState extends State<CreateScreen> {
  final _staffIdController = TextEditingController();
  final _pinController = TextEditingController();
  bool _obscurePin = true;

  @override
  void dispose() {
    _staffIdController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _createAccount() async {
    final staffId = _staffIdController.text.trim();
    final pin = _pinController.text.trim();

    if (staffId.isEmpty || pin.isEmpty) {
      AppSnack.errorSnack(context, "Please enter both Staff ID and PIN");
      return;
    }

    if (pin.length < 4 || pin.length > 8 || !RegExp(r'^\d+$').hasMatch(pin)) {
      AppSnack.errorSnack(context, "PIN must be 4–8 digits");
      return;
    }

    final user = AuthModel(userName: staffId, passCode: pin);

    try {
      final result = await AuthHelper.instance.insertUser(user);
      if (result > 0) {
        if (mounted) {
          AppSnack.successSnack(context, "Successfully created account. Please log in.");
        }
        _staffIdController.clear();
        _pinController.clear();
        if (mounted) {
          context.go('/');
        }
      } else {
        if (mounted) {
          AppSnack.errorSnack(context, "Failed to create account");
        }
      }
    } catch (e) {
      if (mounted) {
        AppSnack.errorSnack(context, "Database error: $e");
      }
    }
  }

  void _handleBackToLogin() async {
    final hasUser = await AuthHelper.instance.hasUsers();
    if (!hasUser) {
      if (mounted) {
        AppSnack.errorSnack(context, "Please create an account first to continue.");
      }
    } else {
      if (mounted) {
        context.go('/');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Unique animated glowing background ──
          const AuthBgDecoration(),

          // ── Centered   Form Card ──
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: CreateStaffCard(
                staffIdController: _staffIdController,
                pinController: _pinController,
                obscurePin: _obscurePin,
                onCreate: _createAccount,
                onToggleObscurePin: () {
                  setState(() {
                    _obscurePin = !_obscurePin;
                  });
                },
                onBackToLogin: _handleBackToLogin,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
