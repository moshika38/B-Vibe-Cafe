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
      AppSnack.errorSnack(context, "Please enter both staff ID and PIN");
      return;
    }

    if (pin.length < 6) {
      AppSnack.errorSnack(context, "PIN must be 6 digits");
      return;
    }

    final user = AuthModel(userName: staffId, passCode: pin);

    try {
      final result = await AuthHelper.instance.insertUser(user);
      if (result > 0) {
        if (mounted) {
          AppSnack.successSnack(context, "Successfully created account");
        }
        _staffIdController.clear();
        _pinController.clear();
        context.go('/');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Unique animated glowing background ──
          const AuthBgDecoration(),

          // ── Centered Glassmorphic Form Card ──
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
                onBackToLogin: () {},
              ),
            ),
          ),
        ],
      ),
    );
  }
}
