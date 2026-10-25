import 'package:auto_finance/app/theme.dart';
import 'package:auto_finance/core/models/date_filter_selection.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateFilterBar extends StatelessWidget {
  const DateFilterBar({
    super.key,
    required this.selection,
    required this.onChanged,
    this.horizontalPadding = 20,
  });

  final DateFilterSelection selection;
  final ValueChanged<DateFilterSelection> onChanged;
  final double horizontalPadding;

  Future<void> _openFilterMenu(BuildContext context) async {
    final choice = await showModalBottomSheet<DateFilterKind>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.line,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Filter tanggal',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              _option(
                context: sheetContext,
                kind: DateFilterKind.all,
                title: 'Semua tanggal',
                subtitle: 'Tampilkan seluruh riwayat',
                icon: Icons.event_available_rounded,
              ),
              _option(
                context: sheetContext,
                kind: DateFilterKind.month,
                title: 'Pilih bulan',
                subtitle: selection.kind == DateFilterKind.month
                    ? DateFormat('MMMM yyyy', 'id').format(selection.month!)
                    : 'Tampilkan transaksi pada satu bulan',
                icon: Icons.calendar_view_month_rounded,
              ),
              _option(
                context: sheetContext,
                kind: DateFilterKind.range,
                title: 'Rentang tanggal',
                subtitle: selection.kind == DateFilterKind.range
                    ? _formatRange(selection.range!)
                    : 'Tentukan tanggal mulai dan akhir',
                icon: Icons.date_range_rounded,
              ),
            ],
          ),
        ),
      ),
    );
    if (choice == null) return;
    if (!context.mounted) return;

    if (choice == DateFilterKind.all) {
      onChanged(const DateFilterSelection.all());
    } else if (choice == DateFilterKind.month) {
      final month = await _chooseMonth(context);
      if (month != null && context.mounted) {
        onChanged(DateFilterSelection.month(month));
      }
    } else {
      final range = await _chooseRange(context);
      if (range != null && context.mounted) {
        onChanged(DateFilterSelection.range(range));
      }
    }
  }

  Widget _option({
    required BuildContext context,
    required DateFilterKind kind,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: AppColors.forest),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: selection.kind == kind
          ? const Icon(Icons.check_rounded, color: AppColors.forest)
          : null,
      onTap: () => Navigator.pop(context, kind),
    );
  }

  Future<DateTime?> _chooseMonth(BuildContext context) {
    final now = DateTime.now();
    return showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final months = List.generate(
          121,
          (index) => DateTime(now.year, now.month - index),
        );
        return SafeArea(
          child: Container(
            height: MediaQuery.sizeOf(sheetContext).height * 0.72,
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
                        onPressed: () => Navigator.pop(sheetContext),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView.builder(
                    itemCount: months.length,
                    itemBuilder: (context, index) {
                      final month = months[index];
                      final selected =
                          selection.kind == DateFilterKind.month &&
                          selection.month!.year == month.year &&
                          selection.month!.month == month.month;
                      return ListTile(
                        title: Text(
                          DateFormat('MMMM yyyy', 'id').format(month),
                        ),
                        trailing: selected
                            ? const Icon(
                                Icons.check_rounded,
                                color: AppColors.forest,
                              )
                            : null,
                        onTap: () => Navigator.pop(sheetContext, month),
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
  }

  Future<DateTimeRange?> _chooseRange(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: today,
      initialDateRange: selection.kind == DateFilterKind.range
          ? selection.range
          : DateTimeRange(start: today, end: today),
      helpText: 'Pilih rentang tanggal',
      cancelText: 'Batal',
      confirmText: 'Pilih',
      saveText: 'Pilih',
    );
  }

  String _formatRange(DateTimeRange range) {
    final format = DateFormat('d MMM yyyy', 'id');
    if (range.start.year == range.end.year &&
        range.start.month == range.end.month &&
        range.start.day == range.end.day) {
      return format.format(range.start);
    }
    return '${format.format(range.start)} – ${format.format(range.end)}';
  }

  String _label() {
    switch (selection.kind) {
      case DateFilterKind.all:
        return 'Semua tanggal';
      case DateFilterKind.month:
        return DateFormat('MMMM yyyy', 'id').format(selection.month!);
      case DateFilterKind.range:
        return _formatRange(selection.range!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(horizontalPadding, 0, horizontalPadding, 8),
      child: OutlinedButton.icon(
        onPressed: () => _openFilterMenu(context),
        icon: const Icon(Icons.calendar_month_outlined, size: 18),
        label: Text(_label(), maxLines: 1, overflow: TextOverflow.ellipsis),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.ink,
          side: const BorderSide(color: AppColors.line),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }
}
