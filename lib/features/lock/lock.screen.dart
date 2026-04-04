import 'package:bvibe/const/snack/app.snack.dart';
import 'package:bvibe/const/theme/theme.dart';
import 'package:bvibe/data/helper/auth.helper.dart';
import 'package:bvibe/features/auth/widgets/img.panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
 import 'package:material_symbols_icons/symbols.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  final _pinController = TextEditingController();
  bool _obscurePin = true;
  String _userName = "User";
  String _expectedPin = "";
  late Timer _timer;
  late DateTime _now;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() => _now = DateTime.now());
      }
    });
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = await AuthHelper.instance.readCurrentUserData();
    if (user != null) {
      setState(() {
        _userName = user.userName;
        _expectedPin = user.passCode;
      });
    }
  }

  @override
  void dispose() {
    _pinController.dispose();
    _timer.cancel();
    super.dispose();
  }

  void _handleUnlock() {
    if (_pinController.text == _expectedPin) {
      Navigator.pop(context);
    } else {
      AppSnack.errorSnack(context, "Invalid PIN. Please try again.");
      _pinController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                const Expanded(child: ImgPanel()),

                // ── Right: Lock Form ──
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 52, vertical: 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Clock & Date ──
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  DateFormat('hh:mm a').format(_now),
                                  style: theme.textTheme.headlineSmall?.copyWith(
                                    color: AppColors.textPrimary,
                                    fontSize: 24,
                                  ),
                                ),
                                Text(
                                  DateFormat('EEEE, MMMM d').format(_now),
                                  style: theme.textTheme.labelSmall,
                                ),
                              ],
                            ),
                            const Icon(Symbols.lock_open, color: AppColors.primary, size: 28),
                          ],
                        ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1),

                        const Spacer(),

                        // ── Welcome User ──
                        Center(
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Symbols.person, size: 48, color: AppColors.primary),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'Locked',
                                style: theme.textTheme.headlineMedium,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Session for $_userName',
                                style: theme.textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ).animate().fadeIn(delay: 200.ms, duration: 500.ms).scale(begin: const Offset(0.95, 0.95)),

                        const SizedBox(height: 48),

                        // ── PIN Input ──
                        Text('Enter Security PIN', style: theme.textTheme.labelMedium),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _pinController,
                          obscureText: _obscurePin,
                          keyboardType: TextInputType.number,
                          autofocus: true,
                          onSubmitted: (_) => _handleUnlock(),
                          decoration: InputDecoration(
                            hintText: '••••',
                            prefixIcon: const Icon(Symbols.key, size: 20, color: AppColors.textHint),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePin ? Symbols.visibility : Symbols.visibility_off,
                                size: 20,
                                color: AppColors.textHint,
                              ),
                              onPressed: () => setState(() => _obscurePin = !_obscurePin),
                            ),
                          ),
                        ).animate().fadeIn(delay: 400.ms, duration: 400.ms).slideY(begin: 0.1),

                        const SizedBox(height: 28),

                        // ── Unlock Button ──
                        ElevatedButton(
                          onPressed: _handleUnlock,
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Unlock Station'),
                              SizedBox(width: 8),
                              Icon(Symbols.arrow_forward, size: 20),
                            ],
                          ),
                        ).animate().fadeIn(delay: 500.ms, duration: 400.ms).slideY(begin: 0.1),

                        const Spacer(),

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
                              Text('SYSTEM ONLINE', style: theme.textTheme.labelSmall),
                            ],
                          ),
                        ),
                      ],
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
