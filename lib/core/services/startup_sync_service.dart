import 'package:auto_finance/features/notification/providers/notification_sync_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StartupSyncService {
  final Ref ref;

  StartupSyncService(this.ref);

  Future<void> run() async {
    try {
      await ref.read(notificationSyncProvider).sync();

      print("🚀 Startup sync completed");
    } catch (e) {
      print("🚀 Startup sync error: $e");
    }
  }
}
