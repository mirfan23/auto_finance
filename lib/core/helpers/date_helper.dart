import 'package:intl/intl.dart';

class DateHelper {
  static String sectionTitle(DateTime date) {
    final now = DateTime.now();

    final today = DateTime(now.year, now.month, now.day);

    final yesterday = today.subtract(const Duration(days: 1));

    final current = DateTime(date.year, date.month, date.day);

    if (current == today) {
      return "Hari Ini";
    }

    if (current == yesterday) {
      return "Kemarin";
    }

    return DateFormat("dd MMMM yyyy", "id").format(date);
  }
}
