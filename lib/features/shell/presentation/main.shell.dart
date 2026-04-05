import 'package:bvibe/features/shell/widgets/menu.item.dart';
import 'package:bvibe/features/shell/widgets/title.dart';
import 'package:bvibe/features/shell/widgets/user.role.card.dart';
import 'package:bvibe/features/lock/lock.screen.dart';
import 'package:bvibe/provider/screen.provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

class MainShell extends StatelessWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  void _showLockScreen(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      useSafeArea: false,
      builder: (context) => const LockScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    ThemeData theme = Theme.of(context);

    bool isActive(String route) => location.startsWith(route);

    final List<Map<String, dynamic>> menuRoutes = [
      {'path': '/dashboard', 'isOrder': false},
      {'path': '/menu', 'isOrder': false},
      {'path': '/orders', 'isOrder': true},
      {'path': '/history', 'isOrder': false},
      {'path': '/analyze', 'isOrder': false},
      {'path': '/expenses', 'isOrder': false},
      {'path': '/settings', 'isOrder': false},
    ];

    return Consumer<ScreenProvider>(
      builder: (context, screenProvider, _) => Focus(
        autofocus: true,
        onKeyEvent: (node, event) {
          if (event is KeyDownEvent) {
            // Tab key navigation
            if (event.logicalKey == LogicalKeyboardKey.tab) {
              final int currentIndex = menuRoutes.indexWhere(
                (route) => isActive(route['path']),
              );
              final int nextIndex = (currentIndex + 1) % menuRoutes.length;
              final Map<String, dynamic> nextRoute = menuRoutes[nextIndex];
              context.go(nextRoute['path']);
              screenProvider.updateScreenStatus(nextRoute['isOrder']);
              return KeyEventResult.handled;
            }

            // Ctrl + L for Lock Screen
            if (event.logicalKey == LogicalKeyboardKey.keyL &&
                HardwareKeyboard.instance.isControlPressed) {
              _showLockScreen(context);
              return KeyEventResult.handled;
            }
          }
          return KeyEventResult.ignored;
        },
        child: Scaffold(
          body: Row(
            children: [
              Container(
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
                        icon: Symbols.history,
                        isOrder: screenProvider.isOrder,
                        label: "Bill History",
                        onTap: () {
                          screenProvider.updateScreenStatus(false);
                          context.go('/history');
                        },
                      ),

                      MenuItem(
                        isActive: isActive('/analyze'),
                        icon: Symbols.analytics,
                        isOrder: screenProvider.isOrder,
                        label: "Analyze",
                        onTap: () {
                          screenProvider.updateScreenStatus(false);
                          context.go('/analyze');
                        },
                      ),

                      MenuItem(
                        isActive: isActive('/expenses'),
                        icon: Symbols.account_balance_wallet,
                        isOrder: screenProvider.isOrder,
                        label: "Expenses",
                        onTap: () {
                          screenProvider.updateScreenStatus(false);
                          context.go('/expenses');
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

              Expanded(
                child: Padding(padding: const EdgeInsets.all(0), child: child),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
