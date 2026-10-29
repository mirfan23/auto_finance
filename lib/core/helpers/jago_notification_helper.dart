class JagoNotificationHelper {
  /// True when a notification describes money moving between Jago pockets.
  /// Jago describes some pocket movements with both source and destination
  /// ("memindahkan ... dari kantong A ke kantong B"), and others with only
  /// the named pocket because the main pocket is implied ("menarik ... dari
  /// kantong tabungan").
  static bool isPocketMovement(String text) {
    final lower = text.toLowerCase();
    final explicitMovement =
        lower.contains('memindahkan') ||
        lower.contains('dipindahkan') ||
        lower.contains('pemindahan');
    final pocketMentions = RegExp(r'\bkantong\b').allMatches(lower).length;

    final namesBothPockets =
        explicitMovement &&
        pocketMentions >= 2 &&
        lower.contains('dari') &&
        lower.contains('ke');

    // "Menarik dari kantong" means moving funds out of a Jago pocket into
    // the implicitly understood main Jago pocket. Require the pocket phrase
    // so ordinary cash withdrawals are not mistaken for internal transfers.
    final withdrawFromPocket =
        lower.contains('menarik') && lower.contains('dari kantong');

    return namesBothPockets || withdrawFromPocket;
  }

  static bool isPromotional(String text) {
    final lower = text.toLowerCase();
    final firstPurchaseBonus =
        lower.contains('bonus') && lower.contains('pembelian pertama');
    final bonusForYou =
        lower.contains('bonus') &&
        lower.contains('buat kamu') &&
        (lower.contains('s.d') || lower.contains('sampai dengan'));
    final conditionalBonus =
        lower.contains('dapetin bonus') &&
        lower.contains('bayar pakai') &&
        lower.contains('jago syariah');

    return firstPurchaseBonus || bonusForYou || conditionalBonus;
  }
}
