import 'package:auto_finance/app/navigation/bottomnav_provider.dart';
import 'package:auto_finance/features/notification_listener/pages/debug_transaction_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/dashboard/dashboard_page.dart';
import '../../features/notification_listener/pages/notification_page.dart';
import '../../features/notification_listener/pages/notification_test_page.dart';

class AppShell extends ConsumerWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(bottomNavIndexProvider);

    final pages = const [DashboardPage(), NotificationPage(), NotificationDebugPage(), DebugTransactionPage()];

    return Scaffold(
      body: IndexedStack(index: index, children: pages),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: (i) {
          ref.read(bottomNavIndexProvider.notifier).state = i;
        },
        unselectedItemColor: Colors.grey,
        selectedItemColor: Colors.purple,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Dashboard"),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: "Notification"),
          BottomNavigationBarItem(icon: Icon(Icons.bug_report), label: "Debug"),
          BottomNavigationBarItem(icon: Icon(Icons.terminal), label: "Debug TRX"),
        ],
      ),
    );
  }
}
