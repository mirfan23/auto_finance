import 'package:auto_finance/data/local/tables/notification_log_table.dart';
import 'package:auto_finance/data/local/tables/pending_transaction_table.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:io';

part 'app_database.g.dart';

class TransactionsTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get bank => text()();
  IntColumn get amount => integer()();
  TextColumn get type => text()();
  TextColumn get category => text()();
  TextColumn get rawText => text()();
  DateTimeColumn get time => dateTime()();
}

@DriftDatabase(tables: [TransactionsTable, NotificationLogsTable, PendingTransactionsTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  @override
  int get schemaVersion => 8;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },
    onUpgrade: (m, from, to) async {
      await m.createAll();
    },
  );

  static AppDatabase? _instance;

  static AppDatabase get instance {
    _instance ??= AppDatabase();
    return _instance!;
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'auto_finance.db'));
    return NativeDatabase(file);
  });
}
