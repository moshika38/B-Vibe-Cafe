import 'package:bvibe/const/snack/app.snack.dart';
import 'package:bvibe/const/theme/theme.dart';
import 'package:bvibe/data/helper/auth.helper.dart';
import 'package:bvibe/data/model/auth.model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

class ResetPinScreen extends StatefulWidget {
  const ResetPinScreen({super.key});

  @override
  State<ResetPinScreen> createState() => _ResetPinScreenState();
}

class _ResetPinScreenState extends State<ResetPinScreen> {
  final _usernameController = TextEditingController();
  final _newPinController = TextEditingController();
  final _confirmPinController = TextEditingController();
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _newPinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final username = _usernameController.text.trim();
    final newPin = _newPinController.text.trim();
    final confirmPin = _confirmPinController.text.trim();

    if (username.isEmpty) {
      AppSnack.errorSnack(context, "Please enter a username");
      return;
    }

    if (newPin.isEmpty || confirmPin.isEmpty) {
      AppSnack.errorSnack(context, "Please fill in both PIN fields");
      return;
    }

    if (newPin.length < 4 ||
        newPin.length > 8 ||
        !RegExp(r'^\d+$').hasMatch(newPin)) {
      AppSnack.errorSnack(context, "PIN must be 4\u20138 digits");
      return;
    }

    if (newPin != confirmPin) {
      AppSnack.errorSnack(context, "PINs do not match");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final currentUser = await AuthHelper.instance.readCurrentUserData();

      if (currentUser != null) {
        final updatedUser = AuthModel(
          id: currentUser.id,
          userName: username,
          passCode: newPin,
        );
        await AuthHelper.instance.updateUser(updatedUser);
      } else {
        await AuthHelper.instance.insertUser(
          AuthModel(userName: username, passCode: newPin),
        );
      }

      if (mounted) {
        AppSnack.successSnack(context, "Account updated successfully");
        context.go('/');
      }
    } catch (e) {
      if (mounted) {
        AppSnack.errorSnack(context, "Failed to save. Please try again.");
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 440,
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.cardBorder),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 40,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withOpacity(0.12),
                        AppColors.primary.withOpacity(0.04),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Icon(
                    Icons.admin_panel_settings,
                    size: 32,
                    color: AppColors.primary,
                  ),
                )
                    .animate()
                    .fadeIn(delay: 200.ms, duration: 400.ms)
                    .scale(begin: const Offset(0.8, 0.8)),

                const SizedBox(height: 20),

                Text(
                  "Update Account",
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ).animate().fadeIn(delay: 300.ms, duration: 400.ms).slideY(begin: 0.1, end: 0),

                const SizedBox(height: 8),

                Text(
                  "Set a new username and PIN for this station",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ).animate().fadeIn(delay: 350.ms, duration: 400.ms).slideY(begin: 0.1, end: 0),

                const SizedBox(height: 30),

                // Username field
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Username", style: theme.textTheme.labelMedium),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _usernameController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    hintText: "Enter new username",
                    prefixIcon: Icon(Icons.person_outline, color: AppColors.textHint),
                  ),
                ).animate().fadeIn(delay: 400.ms, duration: 400.ms).slideY(begin: 0.15, end: 0),

                const SizedBox(height: 20),

                // New PIN field
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text("New PIN", style: theme.textTheme.labelMedium),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _newPinController,
                  obscureText: _obscureNew,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(8),
                  ],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    letterSpacing: 12,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    counterText: "",
                    hintText: "\u2022\u2022\u2022\u2022",
                    hintStyle: const TextStyle(letterSpacing: 12),
                    prefixIcon: const Icon(Icons.lock_outline, color: AppColors.textHint),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureNew ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: AppColors.textHint,
                      ),
                      onPressed: () => setState(() => _obscureNew = !_obscureNew),
                    ),
                  ),
                ).animate().fadeIn(delay: 450.ms, duration: 400.ms).slideY(begin: 0.15, end: 0),

                const SizedBox(height: 20),

                // Confirm PIN field
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Confirm PIN", style: theme.textTheme.labelMedium),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _confirmPinController,
                  obscureText: _obscureConfirm,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(8),
                  ],
                  textAlign: TextAlign.center,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _save(),
                  style: const TextStyle(
                    letterSpacing: 12,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    counterText: "",
                    hintText: "\u2022\u2022\u2022\u2022",
                    hintStyle: const TextStyle(letterSpacing: 12),
                    prefixIcon: const Icon(Icons.lock_outline, color: AppColors.textHint),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: AppColors.textHint,
                      ),
                      onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                    ),
                  ),
                ).animate().fadeIn(delay: 500.ms, duration: 400.ms).slideY(begin: 0.15, end: 0),

                const SizedBox(height: 32),

                // Save button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            "Save Changes",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ).animate().fadeIn(delay: 550.ms, duration: 400.ms).slideY(begin: 0.2, end: 0),

                const SizedBox(height: 16),

                TextButton(
                  onPressed: () => context.go('/'),
                  child: Text(
                    "Back to Login",
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: AppColors.textSecondary,
                    ),
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
