import 'package:bvibe/components/app.buttons.dart';
import 'package:bvibe/const/theme.dart';
import 'package:flutter/material.dart';

class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Settings",
                    style: theme.textTheme.titleMedium!.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Configure your workspace and hardware",
                    style: theme.textTheme.titleSmall!.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),

              Padding(
                padding: const EdgeInsets.only(right: 30),
                child: AppButtons(
                  text: "Save Changes",
                  onTap: () {
                    // save changes
                  },
                ),
              ),
            ],
          ),
        ),
        Divider(),
      ],
    );
  }
}
