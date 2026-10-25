import 'package:auto_finance/domain/entities/transaction_categories.dart';
import 'package:auto_finance/core/helpers/jago_notification_helper.dart';

class CategorizeTransactionUseCase {
  TransactionCategory call(String text) {
    final lower = text.toLowerCase();

    if (_containsAny(lower, [
      'top up',
      'top-up',
      'topup',
      'pengisian saldo',
      'isi saldo',
      'isi ulang',
    ])) {
      return TransactionCategory.topup;
    }

    if (JagoNotificationHelper.isPocketMovement(text)) {
      return TransactionCategory.transfer;
    }

    if (_containsAny(lower, [
      'laundry',
      'laundromat',
      'dry clean',
      'dry-clean',
      'binatu',
      'cuci pakaian',
    ])) {
      return TransactionCategory.laundry;
    }

    if (_containsAny(lower, [
      'listrik',
      'pln',
      'token listrik',
      'electricity',
    ])) {
      return TransactionCategory.electricity;
    }

    if (_containsAny(lower, [
      'transfer',
      'kiriman',
      'pindah dana',
      'pemindahan dana',
    ])) {
      return TransactionCategory.transfer;
    }

    if (_containsAny(lower, [
      'pln',
      'telkom',
      'pdam',
      'tagihan',
      'listrik',
      'internet',
      'pulsa',
      'bill payment',
    ])) {
      return TransactionCategory.bills;
    }

    if (_containsAny(lower, [
      'gofood',
      'grabfood',
      'shopeefood',
      'nasi bebek',
      'songkam',
      'mcd',
      'mcdonald',
      'kfc',
      'resto',
      'restaurant',
      'food',
      'makanan',
      'minuman',
      'dining',
      'food court',
      'foodcourt',
      'kopi',
      'coffee',
      'cafe',
      'warung',
      'groceries',
      'grocery',
      'sembako',
      'bahan makanan',
      'bahan pokok',
    ])) {
      return TransactionCategory.food;
    }

    if (_containsAny(lower, [
      'gocar',
      'goride',
      'grab',
      'transit',
      'transport',
      'transportation',
      'taxi',
      'parkir',
      'parking',
      'tol',
      'kereta',
      'bus',
    ])) {
      return TransactionCategory.transport;
    }

    if (_containsAny(lower, [
      'apotek',
      'farmasi',
      'pharmacy',
      'hospital',
      'rumah sakit',
      'klinik',
      'clinic',
    ])) {
      return TransactionCategory.health;
    }

    if (_containsAny(lower, [
      'sekolah',
      'school',
      'universitas',
      'university',
      'kuliah',
      'education',
    ])) {
      return TransactionCategory.education;
    }

    if (_containsAny(lower, ['gaji', 'salary', 'payroll', 'upah'])) {
      return TransactionCategory.salary;
    }

    if (_containsAny(lower, [
      'reksa dana',
      'investasi',
      'investment',
      'saham',
      'bibit',
    ])) {
      return TransactionCategory.investment;
    }

    if (_containsAny(lower, ['cashback', 'cash back', 'uang kembali'])) {
      return TransactionCategory.cashback;
    }

    if (_containsAny(lower, ['hadiah', 'gift', 'donasi', 'donation'])) {
      return TransactionCategory.gift;
    }

    if (_containsAny(lower, [
      'shopee',
      'tokopedia',
      'lazada',
      'shopping',
      'belanja',
      'retail',
      'marketplace',
      'toko',
      'purchase',
      'membayar',
      'dibayar',
      'payment',
      'paid',
    ])) {
      return TransactionCategory.shopping;
    }

    return TransactionCategory.other;
  }

  bool _containsAny(String text, List<String> keywords) =>
      keywords.any(text.contains);
}
