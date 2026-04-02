import 'package:bvibe/const/theme/theme.dart';
import 'package:bvibe/data/helper/auth.helper.dart';
import 'package:bvibe/data/model/auth.model.dart';
import 'package:flutter/material.dart';

class UserRoleCard extends StatefulWidget {
  final bool isOrder;
  const UserRoleCard({super.key, required this.isOrder});

  @override
  State<UserRoleCard> createState() => _UserRoleCardState();
}

class _UserRoleCardState extends State<UserRoleCard> {
  AuthModel? user;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userData = await AuthHelper.instance.readCurrentUserData();
    if (mounted) {
      setState(() => user = userData);
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return !widget.isOrder
        ? Row(
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
                    user?.userName.isNotEmpty == true
                        ? user!.userName[0].toUpperCase()
                        : "U",
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
                    user?.userName ?? "User",
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
          )
        : Container(
            width: 35,
            height: 35,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF338f8e),
            ),
            child: Center(
              child: Text(
                user?.userName.isNotEmpty == true
                    ? user!.userName[0].toUpperCase()
                    : "U",
                style: theme.textTheme.bodyLarge!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.surface,
                ),
              ),
            ),
          );
  }
}
