import 'package:auto_finance/app/theme.dart';
import 'package:auto_finance/features/transaction/application/providers/transaction_filter_state_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class TransactionWeekSelector extends ConsumerWidget {
  const TransactionWeekSelector({super.key});

  static final _firstWeek = DateTime(2000, 1, 3);

  DateTime _weekStart(DateTime date) {
    final day = DateTime(date.year, date.month, date.day);
    return day.subtract(Duration(days: day.weekday - DateTime.monday));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weekStart = ref.watch(transactionWeekStartProvider);
    final thisWeekStart = _weekStart(DateTime.now());
    final isCurrentWeek = weekStart == thisWeekStart;
    final weekEnd = weekStart.add(const Duration(days: 6));
    final label = weekStart.month == weekEnd.month
        ? '${DateFormat('d', 'id').format(weekStart)}–${DateFormat('d MMM yyyy', 'id').format(weekEnd)}'
        : '${DateFormat('d MMM', 'id').format(weekStart)} – ${DateFormat('d MMM yyyy', 'id').format(weekEnd)}';

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Minggu sebelumnya',
            onPressed: weekStart.isAfter(_firstWeek)
                ? () => ref.read(transactionWeekStartProvider.notifier).state =
                      weekStart.subtract(const Duration(days: 7))
                : null,
            icon: const Icon(Icons.chevron_left_rounded),
          ),
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: weekStart,
                  firstDate: _firstWeek,
                  lastDate: DateTime.now(),
                  helpText: 'Pilih tanggal dalam minggu',
                );
                if (picked == null || !context.mounted) return;
                ref.read(transactionWeekStartProvider.notifier).state =
                    _weekStart(picked);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.line),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.calendar_month_rounded,
                      size: 18,
                      color: AppColors.forest,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        isCurrentWeek ? 'Minggu ini · $label' : label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          IconButton(
            tooltip: 'Minggu berikutnya',
            onPressed: weekStart.isBefore(thisWeekStart)
                ? () => ref.read(transactionWeekStartProvider.notifier).state =
                      weekStart.add(const Duration(days: 7))
                : null,
            icon: const Icon(Icons.chevron_right_rounded),
          ),
        ],
      ),
    );
  }
}
