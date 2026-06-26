import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

import '../local/database/app_database.dart';

class NotificationLogDao {
  final AppDatabase db;

  NotificationLogDao(this.db);

  Future<bool> exists(String fingerprint) async {
    final result = await (db.select(db.notificationLogsTable)..where((t) => t.fingerprint.equals(fingerprint))).get();

    return result.isNotEmpty;
  }

  Future<void> insert(Map<String, dynamic> data) async {
    debugPrint(
      "DRIFT INSERT => "
      "${data["packageName"]} | "
      "${data["title"]} | "
      "${data["text"]}",
    );

    final fingerprint = md5
        .convert(
          utf8.encode(
            '${data["packageName"]}'
            '${data["title"]}'
            '${data["text"]}'
            '${data["timestamp"]}',
          ),
        )
        .toString();

    if (await exists(fingerprint)) {
      debugPrint("DUPLICATE SKIPPED");
      return;
    }

    await db
        .into(db.notificationLogsTable)
        .insert(
          NotificationLogsTableCompanion.insert(
            packageName: data["packageName"] ?? "",
            title: data["title"] ?? "",
            rawText: data["text"] ?? "",
            timestamp: data["timestamp"],
            fingerprint: fingerprint,
          ),
        );

    debugPrint("INSERT SUCCESS");
  }

  Stream<List<NotificationLogsTableData>> watchAll() {
    return (db.select(db.notificationLogsTable)..orderBy([(t) => OrderingTerm.desc(t.id)])).watch();
  }

  Future<void> clear() async {
    await db.delete(db.notificationLogsTable).go();
  }
}
