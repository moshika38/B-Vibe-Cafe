import 'package:bvibe/const/theme/theme.dart';
import 'package:flutter/material.dart';

class AppTitle extends StatelessWidget {
  final bool isOrder;
  const AppTitle({super.key, required this.isOrder});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return !isOrder
        ? Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    "B",
                    style: theme.textTheme.bodyLarge!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.surface,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "B-Vibe",
                    style: theme.textTheme.titleSmall!.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                  Text(
                    "Cafe & Restaurant",
                    style: theme.textTheme.labelSmall!.copyWith(
                      color: AppColors.textHint,
                      letterSpacing: 0,
                    ),
                  ),
                ],
              ),
            ],
          )
        : Container(
            decoration: BoxDecoration(
              border: Border.all(width: 0.1, color: AppColors.primary),
              borderRadius: BorderRadius.circular(5),
              color: AppColors.surface,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 7),
              child: Center(
                child: Icon(Icons.menu, color: AppColors.primary, size: 30),
              ),
            ),
          );
  }
}
