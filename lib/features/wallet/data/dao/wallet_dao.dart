import 'package:auto_finance/data/local/database/app_database.dart';
import 'package:auto_finance/features/wallet/domain/entities/wallet.dart'
    as entity;
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

  Future<WalletTableData?> getById(String id) {
    return (db.select(
      db.walletTable,
    )..where((table) => table.id.equals(id))).getSingleOrNull();
  }

  Future<void> insert({
    required String id,
    required String name,
    required String bank,
    int balance = 0,
    bool active = true,
  }) async {
    await db
        .into(db.walletTable)
        .insert(
          WalletTableCompanion.insert(
            id: id,
            name: name,
            bank: bank,
            balance: Value(balance),
            active: Value(active),
          ),
        );
  }

  /// Adds imported wallets without replacing existing wallets or balances.
  /// A matching ID or name + bank is treated as an existing wallet.
  Future<int> insertMissing(List<entity.Wallet> wallets) {
    return db.transaction(() async {
      final existing = await getAll();
      final existingIds = existing.map((wallet) => wallet.id).toSet();
      final existingNames = existing
          .map((wallet) => '${_key(wallet.name)}|${_key(wallet.bank)}')
          .toSet();
      var inserted = 0;

      for (final wallet in wallets) {
        final idExists = existingIds.contains(wallet.id);
        final nameExists = existingNames.contains(
          '${_key(wallet.name)}|${_key(wallet.bank)}',
        );
        if (idExists || nameExists) continue;

        await db
            .into(db.walletTable)
            .insert(
              WalletTableCompanion.insert(
                id: wallet.id,
                name: wallet.name,
                bank: wallet.bank,
                balance: Value(wallet.balance),
                active: Value(wallet.active),
              ),
            );
        existingIds.add(wallet.id);
        existingNames.add('${_key(wallet.name)}|${_key(wallet.bank)}');
        inserted++;
      }
      return inserted;
    });
  }

  static String _key(String value) => value.trim().toLowerCase();

  Future<WalletTableData?> findByBank(String bank) async {
    final wallets =
        await (db.select(db.walletTable)..where(
              (table) => table.bank.equals(bank) & table.active.equals(true),
            ))
            .get();
    if (wallets.isEmpty) return null;

    // A bank can have several wallets (for example, Jago's main wallet and
    // a separately tracked pocket). Notifications identify the bank, not the
    // pocket, so prefer the wallet whose name matches the bank label.
    final bankKey = _key(bank);
    final primary = wallets.where((wallet) => _key(wallet.name) == bankKey);
    if (primary.isNotEmpty) return primary.first;

    // Use an only available wallet. If several custom wallets match, do not
    // guess where a financial notification belongs.
    if (wallets.length == 1) return wallets.single;
    return null;
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
