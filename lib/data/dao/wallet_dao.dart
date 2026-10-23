import 'package:auto_finance/data/local/database/app_database.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

class WalletDao {
  final AppDatabase db;

  WalletDao(this.db);

  Stream<List<WalletTableData>> watchAll() {
    return db.select(db.walletTable).watch();
  }

  Future<List<WalletTableData>> getAll() {
    return db.select(db.walletTable).get();
  }

  Future<void> insert({
    required String id,
    required String name,
    required String bank,
    int balance = 0,
  }) async {
    await db
        .into(db.walletTable)
        .insert(
          WalletTableCompanion.insert(
            id: id,
            name: name,
            bank: bank,
            balance: Value(balance),
          ),
        );
  }

  Future<WalletTableData?> findByBank(String bank) async {
    final result = await (db.select(
      db.walletTable,
    )..where((t) => t.bank.equals(bank))).getSingleOrNull();

    return result;
  }

  Future<void> updateBalance(String id, int balance) async {
    await (db.update(db.walletTable)..where((t) => t.id.equals(id))).write(
      WalletTableCompanion(balance: Value(balance)),
    );
  }

  Future<void> delete(String id) async {
    await (db.delete(db.walletTable)..where((t) => t.id.equals(id))).go();
  }

  Future<void> addBalance(String id, int amount) async {
    final wallet = await (db.select(
      db.walletTable,
    )..where((t) => t.id.equals(id))).getSingle();

    await updateBalance(id, wallet.balance + amount);
  }

  Future<void> subtractBalance(String id, int amount) async {
    final wallet = await (db.select(
      db.walletTable,
    )..where((t) => t.id.equals(id))).getSingle();

    await updateBalance(id, wallet.balance - amount);
  }

  Future<void> update({required String id, String? name, int? balance}) async {
    await (db.update(db.walletTable)..where((t) => t.id.equals(id))).write(
      WalletTableCompanion(
        name: name == null ? const Value.absent() : Value(name),
        balance: balance == null ? const Value.absent() : Value(balance),
      ),
    );
  }

  Future<bool> adjustBalance({
    required String walletId,
    required String walletName,
    required int newBalance,
    required String note,
  }) {
    return db.transaction(() async {
      final wallet = await (db.select(
        db.walletTable,
      )..where((table) => table.id.equals(walletId))).getSingleOrNull();
      if (wallet == null) throw StateError('Dompet tidak ditemukan.');
      if (wallet.balance == newBalance) return false;

      await updateBalance(walletId, newBalance);
      await db
          .into(db.walletBalanceAdjustmentTable)
          .insert(
            WalletBalanceAdjustmentTableCompanion.insert(
              id: const Uuid().v4(),
              walletId: walletId,
              walletName: walletName,
              previousBalance: wallet.balance,
              newBalance: newBalance,
              note: Value(note.trim()),
              createdAt: DateTime.now(),
            ),
          );
      return true;
    });
  }

  Future<List<WalletBalanceAdjustmentTableData>> getBalanceAdjustments(
    String walletId,
  ) {
    return (db.select(db.walletBalanceAdjustmentTable)
          ..where((table) => table.walletId.equals(walletId))
          ..orderBy([(table) => OrderingTerm.desc(table.createdAt)]))
        .get();
  }
}
