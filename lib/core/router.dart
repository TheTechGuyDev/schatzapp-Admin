import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../features/auth/login_page.dart';
import '../features/users/user_profile_page.dart';
import '../shell/admin_shell.dart';
import 'modules.dart';
import 'session.dart';

final appRouter = GoRouter(
  initialLocation: '/dashboard',
  refreshListenable: AdminSession.instance,
  redirect: (context, state) {
    final signedIn = AdminSession.instance.signedIn;
    final atLogin = state.uri.path == '/login';
    if (!signedIn && !atLogin) return '/login';
    if (signedIn && atLogin) return '/dashboard';
    return null;
  },
  routes: [
    GoRoute(path: '/', redirect: (_, _) => '/dashboard'),
    GoRoute(
      path: '/login',
      pageBuilder: (context, state) =>
          NoTransitionPage(key: state.pageKey, child: const LoginPage()),
    ),
    ShellRoute(
      builder: (context, state, child) =>
          AdminShell(location: state.uri.path, child: child),
      routes: [
        for (final m in adminModules)
          GoRoute(
            path: m.path,
            redirect: (_, _) =>
                AdminSession.instance.can(m.permission) ? null : '/dashboard',
            pageBuilder: (context, state) =>
                NoTransitionPage(key: state.pageKey, child: m.builder(context)),
            routes: [
              if (m.id == 'users')
                GoRoute(
                  path: ':id',
                  pageBuilder: (context, state) => NoTransitionPage(
                    key: state.pageKey,
                    child: UserProfilePage(userId: state.pathParameters['id']!),
                  ),
                ),
            ],
          ),
      ],
    ),
  ],
  errorBuilder: (context, state) =>
      const Scaffold(body: Center(child: Text('Page not found'))),
);
