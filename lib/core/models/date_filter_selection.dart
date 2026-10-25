import 'package:flutter/material.dart';

enum DateFilterKind { all, month, range }

class DateFilterSelection {
  const DateFilterSelection.all()
    : kind = DateFilterKind.all,
      month = null,
      range = null;

  const DateFilterSelection.month(DateTime value)
    : kind = DateFilterKind.month,
      month = value,
      range = null;

  const DateFilterSelection.range(DateTimeRange value)
    : kind = DateFilterKind.range,
      month = null,
      range = value;

  final DateFilterKind kind;
  final DateTime? month;
  final DateTimeRange? range;

  bool contains(DateTime date) {
    switch (kind) {
      case DateFilterKind.all:
        return true;
      case DateFilterKind.month:
        return date.year == month!.year && date.month == month!.month;
      case DateFilterKind.range:
        final value = range!;
        final start = DateTime(
          value.start.year,
          value.start.month,
          value.start.day,
        );
        final endExclusive = DateTime(
          value.end.year,
          value.end.month,
          value.end.day + 1,
        );
        return !date.isBefore(start) && date.isBefore(endExclusive);
    }
  }
}
