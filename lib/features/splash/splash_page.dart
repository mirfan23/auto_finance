import 'package:auto_finance/core/services/notification_permission_service.dart';
import 'package:auto_finance/features/debug/notification_page.dart' as NotificationAccessHelper;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkPermission();
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

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
