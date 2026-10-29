import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'notification_bus.dart';

void startNotificationListener(WidgetRef ref) {
  NotificationBus.start(ref);
}
