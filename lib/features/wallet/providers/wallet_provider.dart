import 'package:auto_finance/data/dao/wallet_dao.dart';
import 'package:auto_finance/domain/entities/wallet.dart';
import 'package:auto_finance/domain/usecases/wallet/apply_transaction_usecase.dart';
import 'package:auto_finance/domain/usecases/wallet/create_wallet_usecase.dart';
import 'package:auto_finance/domain/usecases/wallet/delete_wallet_usecase.dart';
import 'package:auto_finance/domain/usecases/wallet/update_wallet_balance_usecase.dart';
import 'package:auto_finance/domain/usecases/wallet/wallet_resolver_usecase.dart';
import 'package:auto_finance/features/transaction/providers/transaction_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final walletDaoProvider = Provider((ref) => WalletDao(ref.watch(dbProvider)));

final createWalletProvider = Provider((ref) => CreateWalletUseCase(ref.watch(walletDaoProvider)));

final deleteWalletProvider = Provider((ref) => DeleteWalletUseCase(ref.watch(walletDaoProvider)));

final updateWalletBalanceProvider = Provider((ref) => UpdateWalletBalanceUseCase(ref.watch(walletDaoProvider)));

final walletResolverProvider = Provider((ref) => WalletResolverUseCase(ref.watch(walletDaoProvider)));

final applyTransactionProvider = Provider((ref) => ApplyTransactionUseCase(ref.watch(walletDaoProvider)));

final walletStreamProvider = StreamProvider<List<Wallet>>((ref) {
  final dao = ref.watch(walletDaoProvider);

  return dao.watchAll().map(
    (rows) =>
        rows.map((e) => Wallet(id: e.id, name: e.name, bank: e.bank, balance: e.balance, active: e.active)).toList(),
  );
});
