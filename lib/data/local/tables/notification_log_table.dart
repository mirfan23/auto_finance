import 'package:drift/drift.dart';

class NotificationLogsTable extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get packageName => text()();
  TextColumn get title => text()();
  TextColumn get rawText => text()();
  TextColumn get timestamp => text()();

  TextColumn get fingerprint => text().unique()();
}
