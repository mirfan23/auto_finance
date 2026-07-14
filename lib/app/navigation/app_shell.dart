// import 'package:auto_finance/app/navigation/bottomnav_provider.dart';
// import 'package:auto_finance/features/dashboard/dashboard_page.dart';
// import 'package:auto_finance/features/debug/debug_transaction_page.dart';
// import 'package:auto_finance/features/wallet/pages/wallet_page.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// import '../../features/debug/notification_page.dart';
// import '../../features/debug/notification_test_page.dart';

// class AppShell extends ConsumerWidget {
//   const AppShell({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final index = ref.watch(bottomNavIndexProvider);

//     // final pages = const [DashboardPage(), NotificationPage(), NotificationDebugPage(), DebugTransactionPage()];
//     // final pages = const [WalletPage(), NotificationPage(), NotificationDebugPage(), DebugTransactionPage()];
//     final pages = [
//       DashboardPage(),
//       WalletPage(),
//       // AnalyticsPage(),
//       // SettingsPage(),
//       Container(),
//       Container(),
//     ];

//     // final pages = const [DashboardPage(), WalletPage(), AnalyticsPage(), SettingsPage()];

//     return Scaffold(
//       body: IndexedStack(index: index, children: pages),

//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: index,
//         onTap: (i) {
//           ref.read(bottomNavIndexProvider.notifier).state = i;
//         },
//         unselectedItemColor: Colors.grey,
//         selectedItemColor: Colors.purple,
//         // items: const [
//         //   // BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Dashboard"),
//         //   BottomNavigationBarItem(icon: Icon(Icons.wallet), label: "Wallet"),
//         //   BottomNavigationBarItem(icon: Icon(Icons.notifications), label: "Notification"),
//         //   BottomNavigationBarItem(icon: Icon(Icons.bug_report), label: "Debug"),
//         //   BottomNavigationBarItem(icon: Icon(Icons.terminal), label: "Debug TRX"),
//         // ],
//         items: const [
//           BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: "Home"),
//           BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet_rounded), label: "Wallet"),
//           BottomNavigationBarItem(icon: Icon(Icons.bar_chart_rounded), label: "Analytics"),
//           BottomNavigationBarItem(icon: Icon(Icons.settings_rounded), label: "Settings"),
//         ],
//       ),
//     );
//   }
// }

import 'package:auto_finance/app/navigation/bottomnav_provider.dart';
import 'package:auto_finance/features/analytics/analytics_page.dart';
import 'package:auto_finance/features/dashboard/dashboard_page.dart';
import 'package:auto_finance/features/settings/settings_page.dart';
import 'package:auto_finance/features/transaction/pages/transaction_page.dart';
import 'package:auto_finance/features/wallet/pages/wallet_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppShell extends ConsumerWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(bottomNavIndexProvider);

    const pages = [DashboardPage(), WalletPage(), AnalyticsPage(), SettingsPage()];

    return Scaffold(
      body: IndexedStack(index: index, children: pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: (i) {
          ref.read(bottomNavIndexProvider.notifier).state = i;
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.purple,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet_rounded), label: "Wallet"),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart_rounded), label: "Analytics"),
          BottomNavigationBarItem(icon: Icon(Icons.settings_rounded), label: "Settings"),
        ],
      ),
    );
  }
}
