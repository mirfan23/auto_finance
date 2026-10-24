import 'package:auto_finance/app/theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MonthFilterBar extends StatelessWidget {
  const MonthFilterBar({
    super.key,
    required this.selectedMonth,
    required this.onChanged,
  });

  final DateTime? selectedMonth;
  final ValueChanged<DateTime?> onChanged;

  DateTime _shiftMonth(DateTime month, int offset) =>
      DateTime(month.year, month.month + offset);

  Future<void> _chooseMonth(BuildContext context) async {
    final now = DateTime.now();
    final selection = await showModalBottomSheet<_MonthSelection>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final months = List.generate(
          121,
          (index) => DateTime(now.year, now.month - index),
        );

        return SafeArea(
          child: Container(
            height: MediaQuery.sizeOf(context).height * 0.72,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Pilih bulan',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                        tooltip: 'Tutup',
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.calendar_view_month_rounded),
                  title: const Text('Semua bulan'),
                  trailing: selectedMonth == null
                      ? const Icon(Icons.check_rounded, color: AppColors.forest)
                      : null,
                  onTap: () =>
                      Navigator.pop(context, const _MonthSelection.all()),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView.builder(
                    itemCount: months.length,
                    itemBuilder: (context, index) {
                      final month = months[index];
                      final isSelected =
                          selectedMonth != null &&
                          selectedMonth!.year == month.year &&
                          selectedMonth!.month == month.month;
                      return ListTile(
                        title: Text(
                          DateFormat('MMMM yyyy', 'id').format(month),
                        ),
                        trailing: isSelected
                            ? const Icon(
                                Icons.check_rounded,
                                color: AppColors.forest,
                              )
                            : null,
                        onTap: () => Navigator.pop(
                          context,
                          _MonthSelection.month(month),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (selection == null) return;
    onChanged(selection.month);
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isCurrentMonth =
        selectedMonth != null &&
        selectedMonth!.year == now.year &&
        selectedMonth!.month == now.month;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          IconButton(
            onPressed: selectedMonth == null
                ? null
                : () => onChanged(_shiftMonth(selectedMonth!, -1)),
            tooltip: 'Bulan sebelumnya',
            icon: const Icon(Icons.chevron_left_rounded),
          ),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _chooseMonth(context),
              icon: const Icon(Icons.calendar_month_outlined, size: 18),
              label: Text(
                selectedMonth == null
                    ? 'Semua bulan'
                    : DateFormat('MMMM yyyy', 'id').format(selectedMonth!),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.ink,
                side: const BorderSide(color: AppColors.line),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          IconButton(
            onPressed: selectedMonth == null || isCurrentMonth
                ? null
                : () => onChanged(_shiftMonth(selectedMonth!, 1)),
            tooltip: 'Bulan berikutnya',
            icon: const Icon(Icons.chevron_right_rounded),
          ),
        ],
      ),
    );
  }
}

class _MonthSelection {
  const _MonthSelection.all() : month = null;
  const _MonthSelection.month(DateTime value) : month = value;

  final DateTime? month;
}
