import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_finance/domain/usecases/transfer_pairing_usecase.dart';

final pairingProvider = Provider<TransferPairingUseCase>((ref) {
  return TransferPairingUseCase();
});
