class NotificationTextMerger {
  static const _separator = '\n\nNotifikasi berikutnya:\n';

  static String merge(String current, String additional) {
    final currentText = current.trimRight();
    final additionalText = additional.trim();
    if (additionalText.isEmpty ||
        currentText == additionalText ||
        currentText.split(_separator).contains(additionalText)) {
      return current;
    }

    return '$currentText$_separator$additionalText';
  }
}
