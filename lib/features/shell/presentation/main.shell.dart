import 'package:bvibe/features/shell/widgets/menu.item.dart';
import 'package:bvibe/features/shell/widgets/title.dart';
import 'package:bvibe/features/shell/widgets/user.role.card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

class MainShell extends StatelessWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    ThemeData theme = Theme.of(context);

    bool isActive(String route) => location.startsWith(route);

    return Scaffold(
      body: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border(
                right: BorderSide(color: Colors.grey.shade300, width: 1),
              ),
            ),
            width: 250,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Column(
                children: [
                  AppTitle(),
                  const SizedBox(height: 40),

                  MenuItem(
                    isActive: isActive('/dashboard'),
                    icon: Symbols.dashboard,
                    label: "Dashboard",
                    onTap: () => context.go('/dashboard'),
                  ),

                  MenuItem(
                    isActive: isActive('/menu'),
                    icon: Symbols.local_dining,
                    label: "Menu Management",
                    onTap: () => context.go('/menu'),
                  ),

                  MenuItem(
                    isActive: isActive('/orders'),
                    icon: Symbols.receipt_long,
                    label: "Orders",
                    onTap: () => context.go('/orders'),
                  ),

                  MenuItem(
                    isActive: isActive('/history'),
                    icon: Symbols.analytics,
                    label: "Bill History",
                    onTap: () => context.go('/history'),
                  ),

                  MenuItem(
                    isActive: isActive('/settings'),
                    icon: Symbols.settings,
                    label: "Settings",
                    onTap: () => context.go('/settings'),
                  ),

                  const Spacer(),
                  const Divider(),
                  const SizedBox(height: 10),
                  UserRoleCard(),
                ],
              ),
            ),
          ),

         
          Expanded(
            child: Padding(padding: const EdgeInsets.all(0), child: child),
          ),
        ],
      ),
    );
  }
}
