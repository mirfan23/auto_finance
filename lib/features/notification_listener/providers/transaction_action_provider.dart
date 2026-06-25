import 'dart:convert';

import 'package:auto_finance/core/utils/transaction_fingerprint_helper.dart';
import 'package:auto_finance/data/dao/pending_transaction_dao.dart';
import 'package:auto_finance/domain/entities/pending_transaction.dart';
import 'package:auto_finance/domain/usecases/transfer_pairing_usecase.dart';
import 'package:auto_finance/features/notification_listener/providers/pairing_provider.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_finance/data/local/database/app_database.dart';
import 'package:auto_finance/domain/usecases/transaction_pipeline_usecase.dart';
import 'package:auto_finance/domain/usecases/duplicate_transaction_usecase.dart';
import 'transaction_provider.dart';

final pipelineProvider = Provider((ref) => TransactionPipelineUseCase());

final duplicateProvider = Provider((ref) => DuplicateTransactionUseCase());

final pendingDaoProvider = Provider((ref) => PendingTransactionDao(ref.watch(dbProvider)));

final transactionActionProvider = Provider<TransactionAction>((ref) {
  return TransactionAction(
    db: ref.watch(dbProvider),
    pipeline: ref.watch(pipelineProvider),
    duplicate: ref.watch(duplicateProvider),
    pairing: ref.watch(pairingProvider),
    pendingDao: ref.watch(pendingDaoProvider),
  );
});

class TransactionAction {
  final AppDatabase db;
  final TransactionPipelineUseCase pipeline;
  final DuplicateTransactionUseCase duplicate;
  final TransferPairingUseCase pairing;
  final PendingTransactionDao pendingDao;

  TransactionAction({
    required this.db,
    required this.pipeline,
    required this.duplicate,
    required this.pairing,
    required this.pendingDao,
  });

  Future<void> handle(Map data) async {
    final incoming = pipeline(data);

    if (incoming == null) return;

    final alreadyExist = await pendingDao.exists(incoming.bank, incoming.amount, incoming.type, incoming.rawText);

    if (alreadyExist) {
      print("duplicate pending ignored");
      return;
    }

    // simpan dulu ke pending table
    await pendingDao.insert(incoming);

    // ambil semua pending=true
    final rows = await pendingDao.getPending();

    final pendingList = rows.map((e) {
      return PendingTransaction(
        id: e.id,
        bank: e.bank,
        amount: e.amount,
        type: e.type,
        rawText: e.rawText,
        time: e.time,
        pending: e.pending,
      );
    }).toList();

    final pair = pairing.process(incoming, pendingList.where((e) => e.id != incoming.id).toList());

    if (pair == null) {
      print("⏳ waiting pair");
      return;
    }

    final debit = pair.debit!;
    final credit = pair.credit!;
    final fingerprint = TransactionFingerprint.generate(
      bank: "${debit.bank}→${credit.bank}",
      amount: debit.amount,
      type: "transfer",
      rawText: "${debit.rawText}${credit.rawText}",
    );
    // hapus dari pending table
    await pendingDao.deleteMany([debit.id, credit.id]);

    // buat transfer
    await db
        .into(db.transactionsTable)
        .insert(
          TransactionsTableCompanion.insert(
            bank: "${debit.bank} → ${credit.bank}",
            amount: debit.amount,
            type: "transfer",
            category: "transfer",
            rawText: "${debit.rawText}\n${credit.rawText}",
            time: credit.time,
            fingerprint: fingerprint,
          ),
        );

    print("✅ transfer created");
  }
}

// class TransactionAction {
//   final AppDatabase db;
//   final TransactionPipelineUseCase pipeline;
//   final DuplicateTransactionUseCase duplicate;
//   final TransferPairingUseCase pairing;

//   TransactionAction({required this.db, required this.pipeline, required this.duplicate, required this.pairing});

//   // Future<void> handle(Map data, List<Transaction> existing) async {
//   //   final pending = pipeline(data);
//   //   if (pending == null) return;

//   //   final pairs = pairing.process(pending);

//   //   if (pairs.isEmpty) return;

//   //   final pair = pairs.first;

//   //   final debit = pair.debit;
//   //   final credit = pair.credit;

//   //   if (debit == null || credit == null) return;

//   //   final trx = debit.amount; // total amount sama

//   //   await db
//   //       .into(db.transactionsTable)
//   //       .insert(
//   //         TransactionsTableCompanion.insert(
//   //           bank: "${debit.bank} → ${credit.bank}",
//   //           amount: trx,
//   //           type: "transfer",
//   //           category: "transfer",
//   //           rawText: "${debit.rawText} | ${credit.rawText}",
//   //           time: credit.time,
//   //         ),
//   //       );

//   //   print("✅ PAIRED TRANSACTION CREATED");
//   // }
//   Future<void> handle(Map data, List<Transaction> existing) async {
//     final pending = pipeline(data);

//     if (pending == null) return;

//     final pairs = pairing.process(pending);

//     if (pairs.isNotEmpty) {
//       final pair = pairs.first;

//       await db
//           .into(db.transactionsTable)
//           .insert(
//             TransactionsTableCompanion.insert(
//               bank: "${pair.debit!.bank} → ${pair.credit!.bank}",
//               amount: pair.debit!.amount,
//               type: "transfer",
//               category: "transfer",
//               rawText: "${pair.debit!.rawText} | ${pair.credit!.rawText}",
//               time: pair.credit!.time,
//             ),
//           );

//       return;
//     }

//     // BELUM ADA PASANGAN
//     await db
//         .into(db.transactionsTable)
//         .insert(
//           TransactionsTableCompanion.insert(
//             bank: pending.bank,
//             amount: pending.amount,
//             type: pending.type,
//             category: "unknown",
//             rawText: pending.rawText,
//             time: pending.time,
//           ),
//         );
//     print("✅ SINGLE TRANSACTION CREATED");
//   }
// }
