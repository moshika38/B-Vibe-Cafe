import 'package:bvibe/const/snack/app.snack.dart';
import 'package:bvibe/const/theme/theme.dart';
import 'package:bvibe/data/helper/auth.helper.dart';
import 'package:bvibe/data/model/auth.model.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class SecurityPage extends StatefulWidget {
  const SecurityPage({super.key});

  @override
  State<SecurityPage> createState() => _SecurityPageState();
}

class _SecurityPageState extends State<SecurityPage> {
  final _currentPinCtrl = TextEditingController();
  final _newPinCtrl = TextEditingController();
  final _confirmPinCtrl = TextEditingController();
  final _newUsernameCtrl = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  String? _pinError;
  String? _usernameError;
  bool _success = false;
  bool _usernameSuccess = false;

  @override
  void dispose() {
    _currentPinCtrl.dispose();
    _newPinCtrl.dispose();
    _confirmPinCtrl.dispose();
    _newUsernameCtrl.dispose();
    super.dispose();
  }

  void _changePin() {
    setState(() {
      _pinError = null;
      _success = false;
    });

    if (_currentPinCtrl.text.length < 4) {
      setState(() => _pinError = "Current PIN must be at least 4 digits.");
      return;
    }
    if (_newPinCtrl.text.length < 4) {
      setState(() => _pinError = "New PIN must be at least 4 digits.");
      return;
    }
    if (_newPinCtrl.text == _currentPinCtrl.text) {
      setState(() => _pinError = "New PIN must be different from current PIN.");
      return;
    }
    if (_newPinCtrl.text != _confirmPinCtrl.text) {
      setState(() => _pinError = "PINs do not match.");
      return;
    }
    if (_currentPinCtrl.text != cPin) {
      setState(() => _pinError = "Current PIN is incorrect.");
      return;
    }

    // update password
    _updateNewUser();

    _currentPinCtrl.clear();
    _newPinCtrl.clear();
    _confirmPinCtrl.clear();
    setState(() => _success = true);
  }

  @override
  void initState() {
    super.initState();
    _loadAuthData();
  }

  String cUser = "";
  String cPin = "";

  Future<void> _loadAuthData() async {
    final currentUser = await AuthHelper.instance.readCurrentUserData();
    if (currentUser != null) {
      setState(() {
        cPin = currentUser.passCode;
        cUser = currentUser.userName;
        _newUsernameCtrl.text = currentUser.userName;
      });
    }
  }

  Future<void> _updateNewUser() async {
    final user = AuthModel(userName: cUser, passCode: _newPinCtrl.text);
    final result = await AuthHelper.instance.insertUser(user);
    if (result > 0) {
      setState(() => cPin = _newPinCtrl.text);
      if (mounted) {
        AppSnack.successSnack(context, "Successfully updated PIN");
      }
    }
  }

  Future<void> _updateUsername() async {
    final user = AuthModel(userName: _newUsernameCtrl.text, passCode: cPin);
    final result = await AuthHelper.instance.insertUser(user);
    if (result > 0) {
      setState(() {
        cUser = _newUsernameCtrl.text;
        _usernameSuccess = true;
      });
      if (mounted) {
        AppSnack.successSnack(context, "Successfully updated Username");
      }
    }
  }

  Future<void> _showVerifyPinDialog() async {
    final TextEditingController verifyPinCtrl = TextEditingController();
    bool obscure = true;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(
            "Verify PIN",
            style: theme.textTheme.labelMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Please enter your current PIN to authorize this change.",
                style: theme.textTheme.labelSmall,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: verifyPinCtrl,
                obscureText: obscure,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Symbols.lock, size: 18),
                  hintText: "Enter Current PIN",
                  suffixIcon: IconButton(
                    onPressed: () => setDialogState(() => obscure = !obscure),
                    icon: Icon(
                      obscure ? Symbols.visibility : Symbols.visibility_off,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel"),
            ),
            FilledButton(
              onPressed: () {
                if (verifyPinCtrl.text == cPin) {
                  Navigator.pop(context, true);
                } else {
                  AppSnack.errorSnack(context, "Incorrect PIN");
                }
              },
              child: const Text("Verify"),
            ),
          ],
        ),
      ),
    );

    if (confirmed == true) {
      _updateUsername();
    }
  }

  late ThemeData theme;

  @override
  Widget build(BuildContext context) {
    theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Text(
          "Security",
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "Manage your PIN and access credentials.",
          style: theme.textTheme.labelSmall,
        ),

        const SizedBox(height: 30),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Form
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  _buildUsernameCard(theme),
                  const SizedBox(height: 20),
                  _buildPinCard(theme),
                ],
              ),
            ),

            const SizedBox(width: 30),

            // Tips
            Expanded(child: _buildTipsCard(theme)),
          ],
        ),
      ],
    );
  }

  Widget _buildPinCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.textSecondary.withValues(alpha: 0.07),
            blurRadius: 14,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon + title
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Symbols.lock,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Change PIN",
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    "Update your 4–8 digit access PIN",
                    style: theme.textTheme.labelSmall,
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 24),
          Divider(color: AppColors.divider, height: 1),
          const SizedBox(height: 20),

          // Fields
          _pinField(
            theme,
            label: "Current PIN",
            controller: _currentPinCtrl,
            obscure: _obscureCurrent,
            onToggle: () => setState(() => _obscureCurrent = !_obscureCurrent),
          ),
          const SizedBox(height: 14),
          _pinField(
            theme,
            label: "New PIN",
            controller: _newPinCtrl,
            obscure: _obscureNew,
            onToggle: () => setState(() => _obscureNew = !_obscureNew),
          ),
          const SizedBox(height: 14),
          _pinField(
            theme,
            label: "Confirm New PIN",
            controller: _confirmPinCtrl,
            obscure: _obscureConfirm,
            onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
          ),

          // Error
          if (_pinError != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Symbols.error, size: 16, color: Colors.red),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _pinError!,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Success
          if (_success) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF22C55E).withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFF22C55E).withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Symbols.check_circle,
                    size: 16,
                    color: Color(0xFF22C55E),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "PIN updated successfully.",
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: const Color(0xFF22C55E),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _changePin,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                "Update PIN",
                style: theme.textTheme.labelMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pinField(
    ThemeData theme, {
    required String label,
    required TextEditingController controller,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.labelMedium),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscure,

          onChanged: (_) => setState(() {
            _pinError = null;
            _success = false;
          }),
          decoration: InputDecoration(
            prefixIcon: const Icon(Symbols.pin, size: 18),
            suffixIcon: IconButton(
              onPressed: onToggle,
              icon: Icon(
                obscure ? Symbols.visibility : Symbols.visibility_off,
                size: 18,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTipsCard(ThemeData theme) {
    final tips = [
      (Symbols.check, "Use 4–8 digits"),
      (Symbols.check, "Avoid sequential numbers like 1234"),
      (Symbols.check, "Don't share your PIN with others"),
      (Symbols.check, "Change your PIN regularly"),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Symbols.shield, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                "PIN Tips",
                style: theme.textTheme.labelMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...tips.map(
            (t) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(t.$1, size: 14, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      t.$2,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsernameCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.textSecondary.withValues(alpha: 0.07),
            blurRadius: 14,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Symbols.person,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Change Username",
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    "Update your system access name",
                    style: theme.textTheme.labelSmall,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Divider(color: AppColors.divider, height: 1),
          const SizedBox(height: 20),
          Text("New Username", style: theme.textTheme.labelMedium),
          const SizedBox(height: 6),
          TextField(
            controller: _newUsernameCtrl,
            onChanged: (v) => setState(() {
              _usernameError = null;
              _usernameSuccess = false;
            }),
            decoration: const InputDecoration(
              prefixIcon: Icon(Symbols.person_outline, size: 18),
              hintText: "Enter new username",
            ),
          ),
          if (_usernameError != null) ...[
            const SizedBox(height: 12),
            Text(
              _usernameError!,
              style: theme.textTheme.labelSmall?.copyWith(color: Colors.red),
            ),
          ],
          if (_usernameSuccess) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF22C55E).withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFF22C55E).withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Symbols.check_circle,
                    size: 16,
                    color: Color(0xFF22C55E),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Username updated successfully.",
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: const Color(0xFF22C55E),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                if (_newUsernameCtrl.text.isEmpty) {
                  setState(() => _usernameError = "Username cannot be empty.");
                  return;
                }
                _showVerifyPinDialog();
              },
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                "Update Username",
                style: theme.textTheme.labelMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
