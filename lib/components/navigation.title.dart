import 'package:bvibe/const/theme/theme.dart';
import 'package:flutter/material.dart';

class NavigationTitle extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? btnText;
  final bool? isBackIcon;
  final VoidCallback? onTap;
  final bool? isBtn;
  const NavigationTitle({
    super.key,
    required this.title,
    required this.subtitle,
    this.isBackIcon,
    this.onTap,
    this.isBtn,
    this.btnText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          isBackIcon == true
              ? Container(
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.arrow_back,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                  ),
                )
              : const SizedBox.shrink(),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(width: 6),
          Icon(
            Icons.arrow_forward_ios_rounded,
            color: AppColors.textHint,
            size: 11,
          ),
          const SizedBox(width: 6),
          Padding(
            padding: const EdgeInsets.only(top: 1.5),
            child: Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          isBtn == true ? const Spacer() : const SizedBox.shrink(),
          isBtn == true
              ? SizedBox(
                  width: 210,
                  child: ElevatedButton(
                    onPressed: onTap,
                    child: Text(
                      btnText != null ? btnText! : "New Order (Ctrl + N)",
                      style: theme.labelSmall!.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ],
      ),
    );
  }
}
