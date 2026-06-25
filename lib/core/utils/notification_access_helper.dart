import 'package:android_intent_plus/android_intent.dart';

class NotificationAccessHelper {
  static Future<void> openNotifAccess() async {
    const intent = AndroidIntent(action: 'android.settings.ACTION_NOTIFICATION_LISTENER_SETTINGS');

    await intent.launch();
  }
}
