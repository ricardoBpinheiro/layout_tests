import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:layout_tests/core/layout/app_shell.dart';
import 'package:layout_tests/features/auth/pages/login_page.dart';
import 'package:layout_tests/features/inspections/pages/inspection_template_form_screen.dart';
import 'package:layout_tests/features/user/presentation/user_form_screen.dart';
import 'package:layout_tests/pages/dashboard_page.dart';
import 'package:layout_tests/pages/not_found_page.dart';
import 'package:layout_tests/features/inspections/pages/inspection_templates_content.dart';
import 'package:layout_tests/pages/reports_page.dart';
import 'package:layout_tests/pages/settings_page.dart';
import 'package:layout_tests/features/user/presentation/users_content.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(path: '/login', builder: (context, state) => LoginScreen()),
      ShellRoute(
        builder: (context, state, child) {
          return AppShell(child: child);
        },
        routes: [
          GoRoute(
            path: '/home',
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
            path: '/users/create',
            builder: (context, state) => const UserFormScreen(),
          ),
          GoRoute(
            path: '/users/edit/:id',
            builder: (context, state) =>
                UserFormScreen(userId: state.pathParameters['id']),
          ),
          GoRoute(
            path: '/templates',
            builder: (context, state) =>
                Scaffold(body: InspectionTemplatesContent()),
          ),
          GoRoute(
            path: '/templates/create',
            builder: (context, state) => InspectionTemplateFormScreen(),
          ),
          GoRoute(
            path: '/templates/edit/:id',
            builder: (context, state) => InspectionTemplateFormScreen(
              templateId: state.pathParameters['id'],
            ),
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
