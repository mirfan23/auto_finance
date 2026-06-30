import 'package:auto_finance/data/dao/wallet_dao.dart';

class CreateWalletUseCase {
  final WalletDao dao;

  CreateWalletUseCase(this.dao);

  Future<void> call({required String id, required String name, required String bank}) async {
    await dao.insert(id: id, name: name, bank: bank);
  }
}
