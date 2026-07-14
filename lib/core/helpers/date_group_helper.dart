import 'package:intl/intl.dart';

class DateGroupHelper {
  static String label(DateTime date) {
    final now = DateTime.now();

    final today = DateTime(now.year, now.month, now.day);

    final target = DateTime(date.year, date.month, date.day);

    final diff = today.difference(target).inDays;

    if (diff == 0) {
      return "Hari Ini";
    }

    if (diff == 1) {
      return "Kemarin";
    }

    return DateFormat("dd MMMM yyyy", "id_ID").format(date);
  }
}
