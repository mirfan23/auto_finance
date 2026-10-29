import 'package:auto_finance/core/helpers/notification_access_helper.dart';
import 'package:auto_finance/core/services/notification_permission_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// class SplashPage extends StatefulWidget {
//   const SplashPage({super.key});

//   @override
//   State<SplashPage> createState() => _SplashPageState();
// }

// class _SplashPageState extends State<SplashPage> {
//   @override
//   void initState() {
//     super.initState();
//     _checkPermission();
//   }

//   Future<void> _checkPermission() async {
//     final enabled = await NotificationPermissionService.isEnabled();

//     if (!enabled) {
//       await NotificationAccessHelper.openNotifAccess();
//       return;
//     }

//     if (!mounted) return;

//     context.go('/');
//   }

//   @override
//   Widget build(BuildContext context) {
//     return const Scaffold(body: Center(child: CircularProgressIndicator()));
//   }
// }

import 'package:flutter_riverpod/flutter_riverpod.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkPermission();
    Future.microtask(_initialize);
  }

  Future<void> _checkPermission() async {
    final enabled = await NotificationPermissionService.isEnabled();

    if (!enabled) {
      await NotificationAccessHelper.openNotifAccess();
      return;
    }

    if (!mounted) return;

    context.go('/');
  }

  Future<void> _initialize() async {
    try {
      // await ref.read(notificationStartupSyncProvider.future);

      // if (!mounted) return;

      context.go("/");
    } catch (e) {
      debugPrint("❌ STARTUP SYNC ERROR => $e");

      if (!mounted) return;

      context.go("/");
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
