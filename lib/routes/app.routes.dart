import 'package:bvibe/data/helper/auth.helper.dart';
import 'package:bvibe/features/auth/presentation/create.screen.dart';
import 'package:bvibe/features/auth/presentation/login_screen.dart';
import 'package:bvibe/features/dashboard/presentation/dashboard.dart';
import 'package:bvibe/features/menu/presentation/menu.dart';
import 'package:bvibe/features/orders/presentation/check.out.dart';
import 'package:bvibe/features/orders/presentation/create.order.dart';
import 'package:bvibe/features/orders/presentation/recent.orders.dart';
import 'package:bvibe/features/history/presentation/history.dart';
import 'package:bvibe/features/analyze/presentation/analyze.dart';
import 'package:bvibe/features/expenses/presentation/expenses.dart';
import 'package:bvibe/features/orders/presentation/view.order.dart';
import 'package:bvibe/features/settings/presentation/settings.dart';
import 'package:bvibe/features/shell/presentation/main.shell.dart';
import 'package:go_router/go_router.dart';

class AppRoutes {
  static final GoRouter router = GoRouter(
    initialLocation: "/",
    redirect: (context, state) async {
      final hasUser = await AuthHelper.instance.hasUsers();
      final isCreating = state.matchedLocation == '/create';

      if (!hasUser) {
        return isCreating ? null : '/create';
      }

      return null;
    },
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
            builder: (context, state) => RecentOrders(),
            routes: [
              GoRoute(
                path: '/checkout',
                builder: (context, state) =>
                    CheckoutPage(receiptId: state.extra as String),
              ),
              GoRoute(
                path: '/newOrder',
                builder: (context, state) =>
                    CreateOrders(invoiceId: state.extra as String),
              ),
              GoRoute(
                path: '/viewOrder',
                builder: (context, state) =>
                    ViewOrder(receiptId: state.extra as String),
              ),
            ],
          ),
          GoRoute(path: '/history', builder: (context, state) => History()),
          GoRoute(
            path: '/analyze',
            builder: (context, state) => AnalyzeScreen(),
          ),
          GoRoute(
            path: '/expenses',
            builder: (context, state) => ExpensesPage(),
          ),
          GoRoute(path: '/settings', builder: (context, state) => Settings()),
        ],
      ),
    ],
  );
}
