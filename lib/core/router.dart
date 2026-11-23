import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../shell/admin_shell.dart';
import 'modules.dart';
import 'session.dart';

final appRouter = GoRouter(
  initialLocation: '/dashboard',
  routes: [
    GoRoute(path: '/', redirect: (_, _) => '/dashboard'),
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
          ),
      ],
    ),
  ],
  errorBuilder: (context, state) => const Scaffold(
    body: Center(child: Text('Page not found')),
  ),
);
