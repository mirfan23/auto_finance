import 'package:auto_finance/features/debug/debug_transaction_page.dart';
import 'package:auto_finance/features/debug/notification_page.dart';
import 'package:auto_finance/features/debug/notification_test_page.dart';
import 'package:auto_finance/features/splash/splash_page.dart';
import 'package:auto_finance/features/transaction/pages/transaction_detail_page.dart';
import 'package:auto_finance/features/transaction/pages/transaction_page.dart';
import 'package:auto_finance/features/wallet/pages/wallet_page.dart';
import 'package:auto_finance/features/wallet/pages/wallet_detail_page.dart';
import 'package:auto_finance/features/notification/pages/notification_history_page.dart';
import 'package:go_router/go_router.dart';
import 'package:auto_finance/app/navigation/app_shell.dart';

final appRouter = GoRouter(
  initialLocation: "/splash",
  routes: [
    GoRoute(path: "/", builder: (_, _) => const AppShell()),
    GoRoute(path: "/splash", builder: (_, _) => const SplashPage()),
    GoRoute(path: '/transaction', builder: (_, _) => const TransactionPage()),
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
