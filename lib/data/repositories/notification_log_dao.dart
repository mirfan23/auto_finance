import 'package:drift/drift.dart';

import '../local/database/app_database.dart';

class NotificationLogDao {
  final AppDatabase db;

  NotificationLogDao(this.db);

  Future<void> insert(Map<String, dynamic> data) {
    return db
        .into(db.notificationLogsTable)
        .insert(
          NotificationLogsTableCompanion.insert(
            packageName: data["packageName"] ?? "",
            title: data["title"] ?? "",
            rawText: data["rawText"] ?? "",
            timestamp: data["timestamp"]?.toString() ?? "",
          ),
        );
  }

  Stream<List<NotificationLogsTableData>> watchAll() {
    return (db.select(db.notificationLogsTable)..orderBy([(t) => OrderingTerm.desc(t.id)])).watch();
  }
}
