import 'package:bvibe/const/theme.dart';
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
              // Image.asset('assets/img/logo.png', width: 60),
              Container(
                width: 35,
                height: 35,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary,
                ),
                child: Center(
                  child: Text(
                    "L",
                    style: theme.textTheme.bodyLarge!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.surface,
                    ),
                  ),
                ),
              ),

              SizedBox(width: 10),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "B-Vibe",
                    style: theme.textTheme.titleSmall!.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    "Cafe & Restaurant",
                    style: theme.textTheme.labelSmall!.copyWith(
                      color: AppColors.textHint,
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
