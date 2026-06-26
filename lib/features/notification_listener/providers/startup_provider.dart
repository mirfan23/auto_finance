import 'package:auto_finance/core/services/startup_sync_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final startupSyncProvider = Provider((ref) => StartupSyncService(ref));
