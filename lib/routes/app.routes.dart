import 'package:bvibe/features/auth/presentation/create.screen.dart';
import 'package:bvibe/features/auth/presentation/login_screen.dart';
import 'package:bvibe/features/dashboard/presentation/dashboard.dart';
import 'package:bvibe/features/menu/presentation/menu.dart';
import 'package:bvibe/features/orders/presentation/checkOut.dart';
import 'package:bvibe/features/orders/presentation/new.order.dart';
import 'package:bvibe/features/orders/presentation/orders.dart';
import 'package:bvibe/features/history/presentation/history.dart';
import 'package:bvibe/features/settings/presentation/settings.dart';
import 'package:bvibe/features/shell/presentation/main.shell.dart';
import 'package:go_router/go_router.dart';

class AppRoutes {
  static final GoRouter router = GoRouter(
    initialLocation: "/",
    routes: [
      GoRoute(path: '/', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/create',
        builder: (context, state) => const CreateScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) {
          return MainShell(child: child);
        },
        routes: [
          GoRoute(path: '/dashboard', builder: (context, state) => Dashboard()),
          GoRoute(path: '/menu', builder: (context, state) => AppMenu()),
          GoRoute(
            path: '/orders',
            builder: (context, state) => Orders(),
            routes: [
              GoRoute(
                path: '/checkout',
                builder: (context, state) => CheckoutPage(),
              ),
              GoRoute(
                path: '/newOrder',
                builder: (context, state) => NewOrders(),
              ),
            ],
          ),
          GoRoute(path: '/history', builder: (context, state) => History()),
          GoRoute(path: '/settings', builder: (context, state) => Settings()),
        ],
      ),
    ],
  );
}
