import 'package:auto_finance/features/notification/application/providers/notification_sync_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StartupSyncService {
  final Ref ref;

  StartupSyncService(this.ref);

  Future<void> run() async {
    debugPrint("🚀 STARTUP SYNC START");

    try {
      await ref.read(notificationSyncProvider).sync();

      debugPrint("✅ STARTUP SYNC COMPLETED");
    } catch (e, stackTrace) {
      debugPrint("❌ STARTUP SYNC ERROR");
      debugPrint("$e");
      debugPrint("$stackTrace");
    }

    debugPrint("🚀 STARTUP SYNC END");
  }
}
