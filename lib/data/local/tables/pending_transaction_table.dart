import 'package:drift/drift.dart';

class PendingTransactionsTable extends Table {
  TextColumn get id => text()();

  TextColumn get bank => text()();

  IntColumn get amount => integer()();

  TextColumn get category => text()();

  TextColumn get type => text()();

  TextColumn get rawText => text()();

  DateTimeColumn get time => dateTime()();

  BoolColumn get pending => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}
