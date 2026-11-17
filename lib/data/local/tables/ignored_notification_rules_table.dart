import 'package:drift/drift.dart';

/// Exact notification messages the user has explicitly marked as non-financial.
class IgnoredNotificationRulesTable extends Table {
  TextColumn get normalizedText => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {normalizedText};
}
