import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bvibe/const/theme.dart';

// ─── Shortcut Model ────────────────────────────────────────────

class ShortcutEntry {
  final String action;
  final String category;
  final List<String> keys;

  ShortcutEntry({
    required this.action,
    required this.category,
    required this.keys,
  });

  ShortcutEntry copyWith({List<String>? keys}) => ShortcutEntry(
    action: action,
    category: category,
    keys: keys ?? this.keys,
  );
}

// ─── Default Shortcuts ─────────────────────────────────────────

class DefaultShortcuts {
  static List<ShortcutEntry> get all => [
    ShortcutEntry(
      action: "Place Order",
      category: "Order",
      keys: ["Numpad Enter"],
    ),
    ShortcutEntry(action: "Add Item", category: "Order", keys: ["Enter"]),
    ShortcutEntry(
      action: "Select Qty Menu",
      category: "Order",
      keys: ["Shift", "Enter"],
    ),
    ShortcutEntry(action: "Cancel Item", category: "Order", keys: ["Delete"]),
    ShortcutEntry(action: "Hold Order", category: "Order", keys: ["F4"]),
    ShortcutEntry(
      action: "Search Product",
      category: "Navigation",
      keys: ["Ctrl", "F"],
    ),
    ShortcutEntry(action: "Next Field", category: "Navigation", keys: ["Tab"]),
    ShortcutEntry(
      action: "Prev Field",
      category: "Navigation",
      keys: ["Shift", "Tab"],
    ),
    ShortcutEntry(action: "Open Payment", category: "Payment", keys: ["F2"]),
    ShortcutEntry(action: "Open Discount", category: "Payment", keys: ["F3"]),
    ShortcutEntry(action: "Refund", category: "Payment", keys: ["F5"]),
    ShortcutEntry(
      action: "Print Receipt",
      category: "Payment",
      keys: ["Ctrl", "P"],
    ),
  ];
}

// ─── Key Capture Dialog ────────────────────────────────────────

class _KeyCaptureDialog extends StatefulWidget {
  final ShortcutEntry entry;
  const _KeyCaptureDialog({required this.entry});

  @override
  State<_KeyCaptureDialog> createState() => _KeyCaptureDialogState();
}

class _KeyCaptureDialogState extends State<_KeyCaptureDialog> {
  List<String> _capturedKeys = [];
  bool _isListening = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _capturedKeys = List.from(widget.entry.keys);
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  String _keyToLabel(LogicalKeyboardKey key) {
    if (key == LogicalKeyboardKey.shiftLeft ||
        key == LogicalKeyboardKey.shiftRight ||
        key == LogicalKeyboardKey.shift) {
      return "Shift";
    }
    if (key == LogicalKeyboardKey.controlLeft ||
        key == LogicalKeyboardKey.controlRight ||
        key == LogicalKeyboardKey.control) {
      return "Ctrl";
    }
    if (key == LogicalKeyboardKey.altLeft ||
        key == LogicalKeyboardKey.altRight ||
        key == LogicalKeyboardKey.alt) {
      return "Alt";
    }
    if (key == LogicalKeyboardKey.numpadEnter) return "Numpad Enter";
    if (key == LogicalKeyboardKey.enter) return "Enter";
    if (key == LogicalKeyboardKey.tab) return "Tab";
    if (key == LogicalKeyboardKey.escape) return "Escape";
    if (key == LogicalKeyboardKey.delete) return "Delete";
    if (key == LogicalKeyboardKey.backspace) return "Backspace";
    if (key == LogicalKeyboardKey.space) return "Space";
    if (key == LogicalKeyboardKey.f1) return "F1";
    if (key == LogicalKeyboardKey.f2) return "F2";
    if (key == LogicalKeyboardKey.f3) return "F3";
    if (key == LogicalKeyboardKey.f4) return "F4";
    if (key == LogicalKeyboardKey.f5) return "F5";
    if (key == LogicalKeyboardKey.f6) return "F6";
    if (key == LogicalKeyboardKey.f7) return "F7";
    if (key == LogicalKeyboardKey.f8) return "F8";
    if (key == LogicalKeyboardKey.f9) return "F9";
    if (key == LogicalKeyboardKey.f10) return "F10";
    if (key == LogicalKeyboardKey.f11) return "F11";
    if (key == LogicalKeyboardKey.f12) return "F12";
    final label = key.keyLabel;
    return label.isNotEmpty ? label.toUpperCase() : (key.debugName ?? "?");
  }

  void _startListening() {
    setState(() {
      _isListening = true;
      _capturedKeys = [];
    });
    _focusNode.requestFocus();
  }

  void _handleKeyEvent(KeyEvent event) {
    if (!_isListening || event is! KeyDownEvent) return;
    final label = _keyToLabel(event.logicalKey);

    // 
     
    const modifiers = {"Shift", "Ctrl", "Alt", "Meta"};
    if (modifiers.contains(label)) return;  

    final List<String> pressed = [];
    if (HardwareKeyboard.instance.isControlPressed) pressed.add("Ctrl");
    if (HardwareKeyboard.instance.isShiftPressed) pressed.add("Shift");
    if (HardwareKeyboard.instance.isAltPressed) pressed.add("Alt");
    pressed.add(label);

    setState(() {
      _capturedKeys = pressed;
      _isListening = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return KeyboardListener(
      focusNode: _focusNode,
      onKeyEvent: _handleKeyEvent,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: 420,
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.keyboard_alt_outlined,
                      color: AppColors.primary,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Edit Shortcut",
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        widget.entry.action,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // Capture area
              GestureDetector(
                onTap: _startListening,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: double.infinity,
                  height: 80,
                  decoration: BoxDecoration(
                    color: _isListening
                        ? AppColors.primary.withValues(alpha: 0.05)
                        : AppColors.background,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _isListening
                          ? AppColors.primary
                          : AppColors.inputBorder,
                      width: _isListening ? 1.5 : 1,
                    ),
                  ),
                  child: Center(
                    child: _isListening
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                "Press your shortcut key...",
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          )
                        : _capturedKeys.isEmpty
                        ? Text(
                            "Click to record shortcut",
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: AppColors.textHint,
                            ),
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: _capturedKeys
                                .expand(
                                  (k) => [
                                    _buildKeyChip(k, large: true),
                                    if (k != _capturedKeys.last)
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                        ),
                                        child: Text(
                                          "+",
                                          style: theme.textTheme.labelMedium
                                              ?.copyWith(
                                                color: AppColors.textSecondary,
                                                fontWeight: FontWeight.w700,
                                              ),
                                        ),
                                      ),
                                  ],
                                )
                                .toList(),
                          ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              Text(
                _isListening
                    ? "Release keys to confirm"
                    : "Click the box and press the key combination",
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.textHint,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0,
                ),
              ),

              const SizedBox(height: 28),

              // Actions
              Row(
                children: [
                  if (!_isListening && _capturedKeys.isNotEmpty)
                    TextButton.icon(
                      onPressed: _startListening,
                      icon: const Icon(Icons.refresh_rounded, size: 14),
                      label: const Text("Re-record"),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        textStyle: theme.textTheme.labelSmall?.copyWith(
                          letterSpacing: 0,
                        ),
                      ),
                    ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      "Cancel",
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _capturedKeys.isEmpty
                        ? null
                        : () => Navigator.pop(context, _capturedKeys),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: AppColors.primary.withValues(
                        alpha: 0.4,
                      ),
                      minimumSize: Size.zero,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text("Save"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKeyChip(String key, {bool large = false}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: large ? 14 : 10,
        vertical: large ? 8 : 5,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.inputBorder, width: 1),
        boxShadow: const [
          BoxShadow(
            color: AppColors.inputBorder,
            blurRadius: 0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        key,
        style: TextStyle(
          fontFamily: 'monospace',
          fontSize: large ? 13 : 11,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

// ─── Key Preview Widget ────────────────────────────────────────

class KeyPreview extends StatefulWidget {
  const KeyPreview({super.key});

  @override
  State<KeyPreview> createState() => _KeyPreviewState();
}

class _KeyPreviewState extends State<KeyPreview> {
  late List<ShortcutEntry> _shortcuts;

  @override
  void initState() {
    super.initState();
    _shortcuts = DefaultShortcuts.all;
  }

  Future<void> _editShortcut(ShortcutEntry entry) async {
    final result = await showDialog<List<String>>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _KeyCaptureDialog(entry: entry),
    );

    if (result != null && mounted) {
      setState(() {
        final idx = _shortcuts.indexWhere((s) => s.action == entry.action);
        if (idx != -1) _shortcuts[idx] = _shortcuts[idx].copyWith(keys: result);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("'${entry.action}' shortcut updated"),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  void _resetToDefault() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Reset Shortcuts"),
        content: const Text(
          "All shortcuts will be reset to their default values. Continue?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              minimumSize: Size.zero,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              setState(() => _shortcuts = DefaultShortcuts.all);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text("Shortcuts reset to default"),
                  backgroundColor: AppColors.primary,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            },
            child: const Text("Reset"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final Map<String, List<ShortcutEntry>> grouped = {};
    for (final s in _shortcuts) {
      grouped.putIfAbsent(s.category, () => []).add(s);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Keyboard Shortcuts",
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Click any row to edit its key binding.",
                  style: theme.textTheme.labelSmall,
                ),
              ],
            ),
            const Spacer(),
            OutlinedButton.icon(
              onPressed: _resetToDefault,
              icon: const Icon(Icons.restart_alt_rounded, size: 16),
              label: const Text("Reset to Default"),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
                side: const BorderSide(color: AppColors.inputBorder),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                textStyle: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        ...grouped.entries.map(
          (entry) => _buildGroup(theme, entry.key, entry.value),
        ),
      ],
    );
  }

  Widget _buildGroup(
    ThemeData theme,
    String category,
    List<ShortcutEntry> entries,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.textSecondary.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 14,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    category,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Divider(color: AppColors.divider, height: 1, thickness: 1),
            ...entries.asMap().entries.map((e) {
              final isLast = e.key == entries.length - 1;
              return _buildShortcutRow(theme, e.value, isLast);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildShortcutRow(ThemeData theme, ShortcutEntry entry, bool isLast) {
    return InkWell(
      onTap: () => _editShortcut(entry),
      borderRadius: BorderRadius.vertical(
        bottom: isLast ? const Radius.circular(16) : Radius.zero,
      ),
      hoverColor: AppColors.primary.withValues(alpha: 0.03),
      child: Container(
        decoration: BoxDecoration(
          border: isLast
              ? null
              : const Border(
                  bottom: BorderSide(color: AppColors.divider, width: 0.5),
                ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            // Action label
            Expanded(
              child: Text(
                entry.action,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ),

            // Key chips
            Row(
              children: entry.keys
                  .expand(
                    (key) => [
                      _buildKeyChip(key),
                      if (key != entry.keys.last)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Text(
                            "+",
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                    ],
                  )
                  .toList(),
            ),

            const SizedBox(width: 12),

            // Edit icon
            const Icon(
              Icons.edit_outlined,
              size: 14,
              color: AppColors.textHint,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeyChip(String key) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.inputBorder, width: 1),
        boxShadow: const [
          BoxShadow(
            color: AppColors.inputBorder,
            blurRadius: 0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        key,
        style: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
