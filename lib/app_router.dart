import 'package:go_router/go_router.dart';
import 'package:layout_tests/core/layout/app_shell.dart';
import 'package:layout_tests/pages/dashboard_page.dart';
import 'package:layout_tests/pages/login_page.dart';
import 'package:layout_tests/pages/not_found_page.dart';
import 'package:layout_tests/pages/products_page.dart';
import 'package:layout_tests/pages/reports_page.dart';
import 'package:layout_tests/pages/settings_page.dart';
import 'package:layout_tests/pages/users_content.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/dashboard',
    routes: [
      GoRoute(path: '/login', builder: (context, state) => LoginPage()),
      ShellRoute(
        builder: (context, state, child) {
          return AppShell(child: child);
        },
        routes: [
          GoRoute(
            path: '/dashboard',
            pageBuilder: (context, state) {
              return NoTransitionPage(child: DashboardContent());
            },
          ),
          GoRoute(
            path: '/users',
            pageBuilder: (context, state) {
              return NoTransitionPage(child: UsersContent());
            },
          ),
          GoRoute(
            path: '/products',
            pageBuilder: (context, state) {
              return NoTransitionPage(child: ProductsContent());
            },
          ),
          GoRoute(
            path: '/reports',
            pageBuilder: (context, state) {
              return NoTransitionPage(child: ReportsContent());
            },
          ),
          GoRoute(
            path: '/settings',
            pageBuilder: (context, state) {
              return NoTransitionPage(child: SettingsContent());
            },
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => NotFoundPage(),
  );
}
