import 'package:auto_finance/features/wallet/data/dao/wallet_dao.dart';
import 'package:uuid/uuid.dart';

class CreateWalletUseCase {
  final WalletDao dao;

  const CreateWalletUseCase(this.dao);

  Future<void> call({required String name, required String bank, int balance = 0}) async {
    const uuid = Uuid();

    await dao.insert(id: uuid.v4(), name: name, bank: bank, balance: balance);
  }
}
