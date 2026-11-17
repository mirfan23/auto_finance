import 'package:auto_finance/features/debug/presentation/pages/debug_transaction_page.dart';
import 'package:auto_finance/features/debug/presentation/pages/notification_page.dart';
import 'package:auto_finance/features/debug/presentation/pages/notification_test_page.dart';
import 'package:auto_finance/features/splash/presentation/pages/splash_page.dart';
import 'package:auto_finance/features/transaction/presentation/pages/transaction_detail_page.dart';
import 'package:auto_finance/features/transaction/presentation/pages/manual_transaction_page.dart';
import 'package:auto_finance/features/transaction/presentation/pages/transaction_page.dart';
import 'package:auto_finance/features/wallet/presentation/pages/wallet_page.dart';
import 'package:auto_finance/features/wallet/presentation/pages/wallet_detail_page.dart';
import 'package:auto_finance/features/notification/presentation/pages/notification_history_page.dart';
import 'package:auto_finance/features/local_ai/presentation/pages/local_ai_settings_page.dart';
import 'package:go_router/go_router.dart';
import 'package:auto_finance/app/navigation/app_shell.dart';

final appRouter = GoRouter(
  initialLocation: "/splash",
  routes: [
    GoRoute(path: "/", builder: (_, _) => const AppShell()),
    GoRoute(path: "/splash", builder: (_, _) => const SplashPage()),
    GoRoute(path: '/transaction', builder: (_, _) => const TransactionPage()),
    GoRoute(
      path: '/transaction/manual',
      builder: (_, _) => const ManualTransactionPage(),
    ),
    GoRoute(path: '/wallet', builder: (_, _) => const WalletPage()),
    GoRoute(
      path: '/wallet/:id',
      builder: (_, state) =>
          WalletDetailPage(walletId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/notifications/history',
      builder: (_, _) => const NotificationHistoryPage(),
    ),
    GoRoute(
      path: '/notifications/action-required',
      builder: (_, _) => const NotificationHistoryPage(attentionOnly: true),
    ),
    GoRoute(
      path: '/settings/local-ai',
      builder: (_, _) => const LocalAiSettingsPage(),
    ),
    GoRoute(
      path: "/transaction/:id",
      builder: (context, state) {
        return TransactionDetailPage(
          transactionId: state.pathParameters["id"]!,
        );
      },
    ),

    // ==========================
    // Developer Routes
    // ==========================
    GoRoute(
      path: "/debug/notification",
      builder: (_, _) => const NotificationPage(),
    ),
    GoRoute(
      path: "/debug/parser",
      builder: (_, _) => const NotificationDebugPage(),
    ),
    GoRoute(
      path: "/debug/transaction",
      builder: (_, _) => const DebugTransactionPage(),
    ),
  ],
);
