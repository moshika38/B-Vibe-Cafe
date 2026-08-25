import 'package:bvibe/const/theme/theme.dart';
import 'package:flutter/material.dart';

enum HintPosition { inline, below, trailing }

class ShortcutHint extends StatelessWidget {
  final String label;
  final HintPosition position;
  final bool compact;

  const ShortcutHint(
    this.label, {
    super.key,
    this.position = HintPosition.inline,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final isCompact = compact || position == HintPosition.trailing;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 5 : 6,
        vertical: isCompact ? 2 : 3,
      ),
      decoration: BoxDecoration(
        color: AppColors.gold.withOpacity(0.06),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: AppColors.gold.withOpacity(0.12),
          width: 0.5,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: isCompact ? 9 : 10,
          fontWeight: FontWeight.w600,
          color: AppColors.gold.withOpacity(0.7),
          letterSpacing: 0.3,
          height: 1.2,
        ),
      ),
    );
  }
}

class ShortcutHintRow extends StatelessWidget {
  final List<String> keys;
  final String? description;
  final bool showDescription;

  const ShortcutHintRow({
    super.key,
    required this.keys,
    this.description,
    this.showDescription = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...keys.map((k) => Padding(
          padding: const EdgeInsets.only(right: 4),
          child: ShortcutHint(k, compact: true),
        )),
        if (showDescription && description != null) ...[
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              description!,
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textTertiary,
                fontWeight: FontWeight.w400,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ],
    );
  }
}

class ShortcutTooltip extends StatelessWidget {
  final List<ShortcutEntry> shortcuts;
  final Widget child;

  const ShortcutTooltip({
    super.key,
    required this.shortcuts,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      richMessage: WidgetSpan(
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.charcoal,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppColors.gold.withOpacity(0.2),
              width: 0.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: shortcuts.map((s) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: AppColors.gold.withOpacity(0.25),
                          width: 0.5,
                        ),
                      ),
                      child: Text(
                        s.key,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.gold,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      s.description,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.white70,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ),
      preferBelow: false,
      waitDuration: const Duration(milliseconds: 400),
      child: child,
    );
  }
}

class ShortcutEntry {
  final String key;
  final String description;

  const ShortcutEntry({required this.key, required this.description});
}

class ShortcutBadge extends StatelessWidget {
  final String label;
  final bool isActive;

  const ShortcutBadge(
    this.label, {
    super.key,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.gold.withOpacity(0.12)
            : AppColors.gold.withOpacity(0.04),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: AppColors.gold.withOpacity(isActive ? 0.25 : 0.1),
          width: 0.5,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: isActive
              ? AppColors.gold
              : AppColors.gold.withOpacity(0.5),
          fontFamily: 'monospace',
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
