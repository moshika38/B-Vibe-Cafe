import 'package:bvibe/const/theme/theme.dart';
import 'package:flutter/material.dart';
 
class CateCard extends StatelessWidget {
  final bool isActive;
  final String title;
  final int imageNumber;
  final String count;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final Widget? dragHandle;

  const CateCard({
    super.key,
    required this.isActive,
    required this.title,
    required this.count,
    required this.onTap,
    required this.imageNumber,
    this.onEdit,
    this.dragHandle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: GestureDetector(
        onTap: onTap,
        onLongPress: onEdit,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: isActive ? AppColors.surface : Colors.transparent,
            border: Border.all(
              color: isActive ? AppColors.textHint : Colors.transparent,
              width: 0.15,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      SizedBox(
                        width: 30,
                        height: 30,
                        child: Image.asset(
                          "assets/cate/$imageNumber.png",
                          fit: BoxFit.cover,
                          gaplessPlayback: true,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          title,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: theme.textTheme.labelSmall,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isActive && onEdit != null) ...[
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    onPressed: onEdit,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    visualDensity: VisualDensity.compact,
                  ),
                  const SizedBox(width: 3), // Space between edit and drag
                ],
                ?dragHandle,
                const SizedBox(width: 8),
                Text(count, style: theme.textTheme.labelSmall),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
