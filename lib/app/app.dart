import 'package:auto_finance/app/router.dart';
import 'package:auto_finance/features/notification_listener/services/notification_bus.dart';
import 'package:auto_finance/features/notification_listener/services/start_notification_listener.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _AppRootState();
}

class _AppRootState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      startNotificationListener(ref);
      NotificationBus.start(ref); // 🔥 INI WAJIB
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(routerConfig: appRouter);
  }
}
