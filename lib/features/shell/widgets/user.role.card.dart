import 'package:bvibe/const/theme/theme.dart';
import 'package:flutter/material.dart';

class UserRoleCard extends StatelessWidget {
  final bool isOrder ;
  const UserRoleCard({super.key, required this.isOrder});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return !isOrder? Row(
      children: [
        Container(
          width: 35,
          height: 35,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF338f8e),
          ),
          child: Center(
            child: Text(
              "M",
              style: theme.textTheme.bodyLarge!.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.surface,
              ),
            ),
          ),
        ),
        SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Mohamed",
              style: theme.textTheme.labelSmall!.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              "Admin",
              style: theme.textTheme.labelSmall!.copyWith(
                color: AppColors.textHint,
              ),
            ),
          ],
        ),
      ],
    ): Container(
          width: 35,
          height: 35,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF338f8e),
          ),
          child: Center(
            child: Text(
              "M",
              style: theme.textTheme.bodyLarge!.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.surface,
              ),
            ),
          ),
        );
  }
}
