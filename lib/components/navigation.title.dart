import 'package:bvibe/const/theme.dart';
import 'package:flutter/material.dart';

class NavigationTitle extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool? isBackIcon;
  const NavigationTitle({
    super.key,
    required this.title,
    required this.subtitle,
    this.isBackIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          isBackIcon == true? IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(
              Icons.arrow_back,
              size: 20,
              color: AppColors.textPrimary,
            ),
          ):SizedBox.shrink() ,
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(width: 5),
          Icon(
            Icons.arrow_forward_ios_rounded,
            color: AppColors.textSecondary,
            size: 12,
          ),
          SizedBox(width: 5),
          Padding(
            padding: const EdgeInsets.only(top: 1.5),
            child: Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
