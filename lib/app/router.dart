import 'package:auto_finance/features/debug/debug_transaction_page.dart';
import 'package:auto_finance/features/debug/notification_page.dart';
import 'package:auto_finance/features/debug/notification_test_page.dart';
import 'package:auto_finance/features/splash/splash_page.dart';
import 'package:auto_finance/features/transaction/pages/transaction_detail_page.dart';
import 'package:auto_finance/features/transaction/pages/transaction_page.dart';
import 'package:auto_finance/features/wallet/pages/wallet_page.dart';
import 'package:go_router/go_router.dart';
import 'package:auto_finance/app/navigation/app_shell.dart';

final appRouter = GoRouter(
  initialLocation: "/splash",
  routes: [
    GoRoute(path: "/", builder: (_, __) => const AppShell()),
    GoRoute(path: "/splash", builder: (_, __) => const SplashPage()),
    GoRoute(path: '/transaction', builder: (_, _) => const TransactionPage()),
    GoRoute(path: '/wallet', builder: (_, _) => const WalletPage()),
    GoRoute(
      path: "/transaction/:id",
      builder: (context, state) {
        return TransactionDetailPage(transactionId: state.pathParameters["id"]!);
      },
    ),

    // ==========================
    // Developer Routes
    // ==========================
    GoRoute(path: "/debug/notification", builder: (_, __) => const NotificationPage()),
    GoRoute(path: "/debug/parser", builder: (_, __) => const NotificationDebugPage()),
    GoRoute(path: "/debug/transaction", builder: (_, __) => const DebugTransactionPage()),
  ],
);
