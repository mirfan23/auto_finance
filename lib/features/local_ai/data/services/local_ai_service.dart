import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalAiService {
  static const _channel = MethodChannel('auto_finance/local_ai');
  static const _events = EventChannel('auto_finance/local_ai_events');
  static const _sourceKey = 'local_ai_source_wallets_v1';

  static bool get isSupported => Platform.isAndroid;

  static Stream<Map<String, int>> get downloadProgress => _events
      .receiveBroadcastStream()
      .map((event) => Map<String, int>.from(event as Map));

  static Future<Map<String, dynamic>> modelStatus() async {
    if (!isSupported) return {'downloaded': false, 'sizeBytes': 0};
    final status = await _channel.invokeMapMethod<String, dynamic>(
      'modelStatus',
    );
    return status ?? {'downloaded': false, 'sizeBytes': 0};
  }

  static Future<int> downloadModel() async =>
      (await _channel.invokeMethod<num>('downloadModel'))?.toInt() ?? 0;

  static Future<void> deleteModel() async {
    await _channel.invokeMethod<bool>('deleteModel');
  }

  static Future<String> parseNotification({
    required String sourceApp,
    required String title,
    required String text,
  }) async {
    final prompt =
        '''You classify one Android notification from a bank or e-wallet in Indonesia.
Return exactly one JSON object, no markdown and no explanation, with keys:
{"is_transaction":boolean,"amount":integer|null,"type":"income"|"expense"|"transfer"|null,"category":"food"|"laundry"|"electricity"|"shopping"|"transport"|"bills"|"housing"|"entertainment"|"health"|"education"|"salary"|"investment"|"topup"|"transfer"|"cashback"|"gift"|"other","merchant":string}
Rules: use only information explicitly present in the notification. Never invent an amount. If no explicit transaction amount exists, set is_transaction=false and amount=null. Promotions, reminders, OTPs, balance-only messages, and marketing are not transactions. Deposits/refunds received are income. Payments and money sent externally are expense. Moving money between pockets belonging to the same bank is transfer. If a field is uncertain, use null for type and set is_transaction=false. Use integer rupiah without separators. Category must be one of the listed values; use other if unsure.
Source app: $sourceApp
Title: $title
Notification text: $text
JSON:''';
    return (await _channel.invokeMethod<String>('parseNotification', {
          'prompt': prompt,
        })) ??
        '';
  }

  static Future<List<Map<String, dynamic>>> getAvailableSources() async {
    if (!isSupported) return const [];
    final result = await const MethodChannel(
      'notification_db',
    ).invokeMethod<List<dynamic>>('getNotificationSources');
    return result
            ?.map((item) => Map<String, dynamic>.from(item as Map))
            .toList(growable: false) ??
        const [];
  }

  static Future<Map<String, String>> selectedSourceWallets() async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(_sourceKey);
    if (raw == null) return {};
    try {
      return Map<String, String>.from(jsonDecode(raw) as Map);
    } on FormatException {
      return {};
    }
  }

  static Future<int> saveSelectedSourceWallets(
    Map<String, String> selections,
  ) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_sourceKey, jsonEncode(selections));
    return await const MethodChannel('notification_db').invokeMethod<int>(
          'requeueAiSourceNotifications',
          {'packageNames': selections.keys.toList(growable: false)},
        ) ??
        0;
  }
}
