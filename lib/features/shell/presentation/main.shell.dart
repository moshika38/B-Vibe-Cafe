import 'package:bvibe/features/shell/widgets/menu.item.dart';
import 'package:bvibe/features/shell/widgets/title.dart';
import 'package:bvibe/features/shell/widgets/user.role.card.dart';
import 'package:bvibe/provider/screen.provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

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
          Consumer<ScreenProvider>(
            builder: (context, screenProvider, child) => Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                border: Border(
                  right: BorderSide(color: Colors.grey.shade300, width: 1),
                ),
              ),
              width: screenProvider.isOrder ? 70 : 250,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 24,
                ),
                child: Column(
                  children: [
                    AppTitle(isOrder: screenProvider.isOrder),
                    const SizedBox(height: 40),

                    MenuItem(
                      isOrder: screenProvider.isOrder,
                      isActive: isActive('/dashboard'),
                      icon: Symbols.dashboard,
                      label: "Dashboard",
                      onTap: () {
                        context.go('/dashboard');
                        screenProvider.updateScreenStatus(false);
                      },
                    ),

                    MenuItem(
                      isOrder: screenProvider.isOrder,
                      isActive: isActive('/menu'),
                      icon: Symbols.local_dining,
                      label: "Menu Management",
                      onTap: () {
                        screenProvider.updateScreenStatus(false);
                        context.go('/menu');
                      },
                    ),

                    MenuItem(
                      isOrder: screenProvider.isOrder,
                      isActive: isActive('/orders'),
                      icon: Symbols.receipt_long,
                      label: "Orders",
                      onTap: () {
                        screenProvider.updateScreenStatus(true);
                        context.go('/orders');
                      },
                    ),

                    MenuItem(
                      isActive: isActive('/history'),
                      icon: Symbols.analytics,
                      isOrder: screenProvider.isOrder,
                      label: "Bill History",
                      onTap: () {
                        screenProvider.updateScreenStatus(false);
                        context.go('/history');
                      },
                    ),

                    MenuItem(
                      isOrder: screenProvider.isOrder,
                      isActive: isActive('/settings'),
                      icon: Symbols.settings,
                      label: "Settings",
                      onTap: () {
                        screenProvider.updateScreenStatus(false);
                        context.go('/settings');
                      },
                    ),

                    const Spacer(),

                    const Divider(),
                    const SizedBox(height: 10),
                    UserRoleCard(isOrder: screenProvider.isOrder),
                  ],
                ),
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
