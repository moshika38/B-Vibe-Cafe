import 'package:bvibe/data/helper/auth.helper.dart';
import 'package:flutter/material.dart';
import 'package:bvibe/const/theme.dart';

class PinConfirmDialog extends StatefulWidget {
  final String title;

  const PinConfirmDialog({super.key, this.title = "Confirm PIN"});

  @override
  State<PinConfirmDialog> createState() => _PinConfirmDialogState();
}

class _PinConfirmDialogState extends State<PinConfirmDialog> {
  final TextEditingController _pinController = TextEditingController();
  String? error;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  Future<void> validatePin() async {
    final user = await AuthHelper.instance.readAllUsers();

    if (user?.passCode == _pinController.text) {
      Navigator.pop(context, true);
    } else {
      setState(() {
        error = "Incorrect PIN";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Container(
        width: 360,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 26),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// Lock Icon
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(.08),
              ),
              child: const Icon(
                Icons.lock_outline,
                size: 34,
                color: AppColors.primary,
              ),
            ),

            const SizedBox(height: 16),

            /// Title
            Text(
              widget.title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 6),

            /// Subtitle
            Text(
              "Enter your PIN to continue",
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),

            const SizedBox(height: 22),

            /// PIN Input
            TextField(
              autofocus: true,
              controller: _pinController,
              obscureText: true,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(
                letterSpacing: 16,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                counterText: "",
                hintText: "••••••",
                filled: true,
                fillColor: AppColors.inputFill.withOpacity(.3),

                errorText: error,

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),

                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 1.2,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            /// Buttons
            Row(
              children: [
                /// Cancel
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, false); // cancel
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.inputBorder,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Cancel",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),

                const SizedBox(width: 14),

                /// Confirm
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      await validatePin();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Confirm",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Future<bool> showPinDialog(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => const PinConfirmDialog(),
  );

  return result ?? false;
}
