import 'package:auto_finance/features/splash/splash_page.dart';
import 'package:go_router/go_router.dart';

import 'package:auto_finance/app/navigation/app_shell.dart';

final appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/', builder: (_, _) => const AppShell()),
    GoRoute(path: '/splash', builder: (_, _) => const SplashPage()),
  ],
);
