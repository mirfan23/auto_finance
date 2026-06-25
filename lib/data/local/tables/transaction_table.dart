import 'package:drift/drift.dart';

class TransactionsTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get bank => text()();
  IntColumn get amount => integer()();
  TextColumn get type => text()();
  TextColumn get category => text()();
  TextColumn get rawText => text()();
  DateTimeColumn get time => dateTime()();
  TextColumn get fingerprint => text().unique()();
}
