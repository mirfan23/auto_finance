class MerchantNameHelper {
  static String? suggest(String rawText) {
    final match = RegExp(
      r'\b(?:ke|kepada|di)\s+(.+)',
      caseSensitive: false,
    ).firstMatch(rawText);
    if (match == null) return null;

    var name = match.group(1)!.trim();
    name = name.replaceFirst(
      RegExp(
        r'\s+(?:butuh bantuan|silahkan|silakan|dengan|melalui|menggunakan)\b.*$',
        caseSensitive: false,
      ),
      '',
    );
    name = name.replaceFirst(RegExp(r'[.!?,;]+$'), '').trim();
    return name.isEmpty ? null : name;
  }

  static String normalize(String name) => name
      .toLowerCase()
      .replaceAll(RegExp(r'[^\p{L}\p{N}]+', unicode: true), ' ')
      .trim()
      .replaceAll(RegExp(r'\s+'), ' ');
}
