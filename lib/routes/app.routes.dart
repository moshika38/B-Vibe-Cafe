import 'package:bvibe/features/auth/presentation/login_screen.dart';
import 'package:bvibe/features/dashboard/presentation/dashboard.dart';
import 'package:bvibe/features/menu/presentation/menu.dart';
import 'package:bvibe/features/orders/presentation/orders.dart';
import 'package:bvibe/features/reports/reports.dart';
import 'package:bvibe/features/settings/settings.dart';
import 'package:bvibe/features/shell/presentation/main.shell.dart';
import 'package:go_router/go_router.dart';

class AppRoutes {
  static final GoRouter router = GoRouter(
    initialLocation: "/",
    routes: [
      GoRoute(path: '/', builder: (context, state) => const LoginScreen()),
      ShellRoute(
        builder: (context, state, child) {
          return MainShell(child: child);
        },
        routes: [
          GoRoute(path: '/dashboard', builder: (context, state) => Dashboard()),
          GoRoute(path: '/menu', builder: (context, state) => AppMenu()),
          GoRoute(path: '/orders', builder: (context, state) => Orders()),
          GoRoute(path: '/reports', builder: (context, state) => Reports()),
          GoRoute(path: '/settings', builder: (context, state) => Settings()),
        ],
      ),
    ],
  );
}
