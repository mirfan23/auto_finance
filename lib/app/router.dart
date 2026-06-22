import 'package:go_router/go_router.dart';

import 'package:auto_finance/app/navigation/app_shell.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [GoRoute(path: '/', builder: (_, _) => const AppShell())],
);
