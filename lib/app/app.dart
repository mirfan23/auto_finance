import 'package:auto_finance/app/router.dart';
import 'package:auto_finance/features/notification_listener/providers/startup_provider.dart';
import 'package:auto_finance/features/notification_listener/services/notification_bus.dart';
import 'package:auto_finance/features/notification_listener/services/start_notification_listener.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _AppRootState();
}

class _AppRootState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      startNotificationListener(ref);
      NotificationBus.start(ref); // 🔥 INI WAJIB
      await ref.read(startupSyncProvider).run();
    });
  }

  @override
  Widget build(BuildContext context) {
    initializeDateFormatting('id');
    return MaterialApp.router(routerConfig: appRouter);
  }
}
