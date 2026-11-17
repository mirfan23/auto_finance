import 'dart:convert';

import 'package:auto_finance/app/theme.dart';
import 'package:auto_finance/core/helpers/category_helper.dart';
import 'package:auto_finance/core/models/date_filter_selection.dart';
import 'package:auto_finance/core/widgets/date_filter_bar.dart';
import 'package:auto_finance/data/local/database/app_database.dart';
import 'package:auto_finance/features/notification/domain/entities/received_notification.dart';
import 'package:auto_finance/features/transaction/domain/entities/transaction.dart';
import 'package:auto_finance/features/transaction/domain/entities/transaction_type.dart';
import 'package:auto_finance/features/notification/application/providers/notification_history_provider.dart';
import 'package:auto_finance/features/notification/application/providers/notification_attention_provider.dart';
import 'package:auto_finance/features/notification/application/providers/notification_sync_provider.dart';
import 'package:auto_finance/features/notification/application/providers/notification_stream_provider.dart';
import 'package:auto_finance/features/transaction/application/providers/transaction_provider.dart';
import 'package:auto_finance/features/local_ai/data/services/local_ai_service.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fx_helper/formatter_helper.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

enum _HistoryFilter {
  all,
  recorded,
  noTransaction,
  actionable,
  processing,
  needsConfirmation,
}

class NotificationHistoryPage extends ConsumerStatefulWidget {
  const NotificationHistoryPage({super.key, this.attentionOnly = false});

  final bool attentionOnly;

  @override
  ConsumerState<NotificationHistoryPage> createState() =>
      _NotificationHistoryPageState();
}

class _NotificationHistoryPageState
    extends ConsumerState<NotificationHistoryPage> {
  _HistoryFilter _filter = _HistoryFilter.all;
  DateFilterSelection _dateFilter = const DateFilterSelection.all();
  bool _processingQueue = false;
  Set<String> _aiSourcePackages = const {};

  @override
  void initState() {
    super.initState();
    if (widget.attentionOnly) {
      _filter = _HistoryFilter.actionable;
      _loadAiSourcePackages();
    }
  }

  Future<void> _loadAiSourcePackages() async {
    final sources = await LocalAiService.selectedSourceWallets();
    if (!mounted) return;
    setState(() => _aiSourcePackages = sources.keys.toSet());
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(notificationStreamProvider, (_, _) {
      ref.invalidate(notificationHistoryProvider);
    });

    final notifications = ref.watch(notificationHistoryProvider);
    final transactions = ref.watch(transactionStreamProvider);
    final appLogs = ref.watch(notificationLogStreamProvider);
    final attentionCounts = widget.attentionOnly
        ? ref.watch(notificationAttentionCountsProvider).valueOrNull
        : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.attentionOnly
              ? 'Notifikasi perlu ditinjau'
              : 'Riwayat notifikasi',
        ),
        actions: [
          IconButton(
            tooltip: 'Proses antrean tertunda',
            onPressed: _processingQueue ? null : _processPendingQueue,
            icon: _processingQueue
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.play_arrow_rounded),
          ),
          IconButton(
            tooltip: 'Muat ulang',
            onPressed: () =>
                ref.read(notificationHistoryProvider.notifier).refresh(),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: notifications.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.forest),
        ),
        error: (error, _) => _HistoryError(
          error: error,
          onRetry: () => ref.invalidate(notificationHistoryProvider),
        ),
        data: (historyState) => transactions.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.forest),
          ),
          error: (error, _) => _HistoryError(
            error: error,
            onRetry: () => ref.invalidate(notificationHistoryProvider),
          ),
          data: (savedTransactions) => appLogs.when(
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.forest),
            ),
            error: (error, _) => _HistoryError(
              error: error,
              onRetry: () => ref.invalidate(notificationHistoryProvider),
            ),
            data: (logs) => _buildHistory(
              historyState,
              savedTransactions,
              logs,
              attentionCounts,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHistory(
    NotificationHistoryState historyState,
    List<Transaction> transactions,
    List<NotificationLogsTableData> logs,
    NotificationAttentionCounts? attentionCounts,
  ) {
    final items = historyState.notifications;
    final logFingerprints = logs.map((log) => log.fingerprint).toSet();
    final relevantItems = items
        .where((notification) => _isRelevantNotification(notification))
        .toList();
    final entries = relevantItems.map((notification) {
      return _HistoryEntry(
        notification: notification,
        transaction: _findTransaction(notification, transactions),
        handedToFlutter: logFingerprints.contains(_fingerprint(notification)),
      );
    }).toList();

    final dateFilteredEntries = entries
        .where((entry) => _dateFilter.contains(entry.notification.time))
        .toList();
    final recordedCount = dateFilteredEntries
        .where((entry) => entry.transaction != null)
        .length;
    final processingEntries = dateFilteredEntries
        .where(
          (entry) => entry.transaction == null && !entry.notification.processed,
        )
        .toList();
    final confirmationEntries = dateFilteredEntries
        .where(
          (entry) => entry.transaction == null && entry.notification.processed,
        )
        .toList();
    final useGlobalCounts =
        widget.attentionOnly &&
        _dateFilter.kind == DateFilterKind.all &&
        attentionCounts != null;
    final processingCount = useGlobalCounts
        ? attentionCounts.processing
        : processingEntries.length;
    final confirmationCount = useGlobalCounts
        ? attentionCounts.needsConfirmation
        : confirmationEntries.length;
    final actionableCount = processingCount + confirmationCount;
    final visibleEntries = switch (_filter) {
      _HistoryFilter.all => dateFilteredEntries,
      _HistoryFilter.recorded =>
        dateFilteredEntries
            .where((entry) => entry.transaction != null)
            .toList(),
      _HistoryFilter.noTransaction =>
        dateFilteredEntries
            .where((entry) => entry.transaction == null)
            .toList(),
      _HistoryFilter.actionable =>
        dateFilteredEntries
            .where((entry) => entry.transaction == null)
            .toList(),
      _HistoryFilter.processing => processingEntries,
      _HistoryFilter.needsConfirmation => confirmationEntries,
    };

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.attentionOnly
                    ? 'Periksa notifikasi yang belum masuk transaksi'
                    : 'Notifikasi bank & e-wallet',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 5),
              Text(
                widget.attentionOnly
                    ? 'Tinjau antrean yang tertunda atau pesan yang belum tercatat sebagai transaksi.'
                    : 'Hanya menampilkan Jago, BCA, Gojek/GoPay, dan Shopee/ShopeePay.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 14),
              DateFilterBar(
                selection: _dateFilter,
                horizontalPadding: 0,
                onChanged: (selection) =>
                    setState(() => _dateFilter = selection),
              ),
              Wrap(
                spacing: 8,
                children: [
                  if (widget.attentionOnly) ...[
                    _FilterChip(
                      label: 'Semua perlu ditinjau ($actionableCount)',
                      selected: _filter == _HistoryFilter.actionable,
                      onTap: () =>
                          setState(() => _filter = _HistoryFilter.actionable),
                    ),
                    _FilterChip(
                      label: 'Menunggu pemrosesan ($processingCount)',
                      selected: _filter == _HistoryFilter.processing,
                      onTap: () =>
                          setState(() => _filter = _HistoryFilter.processing),
                    ),
                    _FilterChip(
                      label: 'Perlu konfirmasi ($confirmationCount)',
                      selected: _filter == _HistoryFilter.needsConfirmation,
                      onTap: () => setState(
                        () => _filter = _HistoryFilter.needsConfirmation,
                      ),
                    ),
                  ] else ...[
                    _FilterChip(
                      label: 'Semua (${dateFilteredEntries.length})',
                      selected: _filter == _HistoryFilter.all,
                      onTap: () => setState(() => _filter = _HistoryFilter.all),
                    ),
                    _FilterChip(
                      label: 'Tercatat ($recordedCount)',
                      selected: _filter == _HistoryFilter.recorded,
                      onTap: () =>
                          setState(() => _filter = _HistoryFilter.recorded),
                    ),
                    _FilterChip(
                      label:
                          'Belum ada transaksi (${dateFilteredEntries.length - recordedCount})',
                      selected: _filter == _HistoryFilter.noTransaction,
                      onTap: () => setState(
                        () => _filter = _HistoryFilter.noTransaction,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Memuat riwayat bertahap • ${items.length} notifikasi dimuat',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () =>
                ref.read(notificationHistoryProvider.notifier).refresh(),
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              itemCount:
                  (visibleEntries.isEmpty ? 1 : visibleEntries.length) +
                  (historyState.hasMore || historyState.loadMoreError != null
                      ? 1
                      : 0),
              itemBuilder: (context, index) {
                if (visibleEntries.isEmpty && index == 0) {
                  final message = entries.isEmpty
                      ? widget.attentionOnly
                            ? 'Belum ada notifikasi yang perlu ditinjau.'
                            : 'Belum ada notifikasi dari Jago, BCA, Gojek/GoPay, atau Shopee/ShopeePay.'
                      : dateFilteredEntries.isEmpty
                      ? 'Tidak ada notifikasi pada rentang tanggal ini.'
                      : 'Tidak ada notifikasi pada pilihan ini.';
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 36),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.notifications_none_rounded,
                          size: 44,
                          color: AppColors.muted,
                        ),
                        const SizedBox(height: 12),
                        Text(message, textAlign: TextAlign.center),
                      ],
                    ),
                  );
                }

                if (index < visibleEntries.length) {
                  return _NotificationCard(entry: visibleEntries[index]);
                }

                if (historyState.isLoadingMore) {
                  return const Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (historyState.loadMoreError != null) {
                  return TextButton.icon(
                    onPressed: () => ref
                        .read(notificationHistoryProvider.notifier)
                        .retryLoadMore(),
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Gagal memuat. Coba lagi'),
                  );
                }
                return TextButton.icon(
                  onPressed: () =>
                      ref.read(notificationHistoryProvider.notifier).loadMore(),
                  icon: const Icon(Icons.expand_more_rounded),
                  label: const Text('Muat notifikasi lebih lama'),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  bool _isRelevantNotification(ReceivedNotification notification) {
    final packageName = notification.packageName.toLowerCase();
    const packageHints = ['jago', 'bca', 'gojek', 'gopay', 'shopee'];
    return packageHints.any(packageName.contains) ||
        (widget.attentionOnly &&
            _aiSourcePackages.contains(notification.packageName));
  }

  Future<void> _processPendingQueue() async {
    setState(() => _processingQueue = true);
    try {
      final summary = await ref.read(notificationSyncProvider).sync();
      await ref.read(notificationHistoryProvider.notifier).refresh();
      ref.invalidate(notificationAttentionCountsProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${summary.attempted} notifikasi diperiksa: '
            '${summary.completed} selesai, '
            '${summary.stillWaiting} masih tertunda.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Antrean belum bisa diproses: $error')),
      );
    } finally {
      if (mounted) setState(() => _processingQueue = false);
    }
  }

  String _fingerprint(ReceivedNotification notification) => md5
      .convert(
        utf8.encode(
          '${notification.packageName}'
          '${notification.title}'
          '${notification.text}'
          '${notification.timestamp}',
        ),
      )
      .toString();

  Transaction? _findTransaction(
    ReceivedNotification notification,
    List<Transaction> transactions,
  ) {
    Transaction? closest;
    var closestDifference = const Duration(days: 36500);

    for (final transaction in transactions) {
      final exactText = transaction.rawText == notification.text;
      final transferText =
          transaction.rawText.contains(notification.text) &&
          notification.text.isNotEmpty;
      if (!exactText && !transferText) continue;

      final difference = transaction.time.difference(notification.time).abs();
      final maxDifference = exactText
          ? const Duration(seconds: 6)
          : const Duration(minutes: 2);
      if (difference <= maxDifference && difference < closestDifference) {
        closest = transaction;
        closestDifference = difference;
      }
    }
    return closest;
  }
}

class _HistoryEntry {
  const _HistoryEntry({
    required this.notification,
    required this.transaction,
    required this.handedToFlutter,
  });

  final ReceivedNotification notification;
  final Transaction? transaction;
  final bool handedToFlutter;
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ChoiceChip(
    label: Text(label),
    selected: selected,
    onSelected: (_) => onTap(),
    selectedColor: AppColors.mint,
    labelStyle: TextStyle(
      color: selected ? AppColors.forestDark : AppColors.muted,
      fontSize: 12,
      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
    ),
    side: BorderSide(color: selected ? AppColors.mint : AppColors.line),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
  );
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.entry});

  final _HistoryEntry entry;

  @override
  Widget build(BuildContext context) {
    final notification = entry.notification;
    final transaction = entry.transaction;
    final status = _status(entry);
    final title = notification.title.trim().isEmpty
        ? _appLabel(notification.packageName)
        : notification.title;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        leading: CircleAvatar(
          backgroundColor: status.color.withValues(alpha: 0.12),
          child: Icon(status.icon, color: status.color, size: 19),
        ),
        title: Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_dateLabel(notification.time)),
              const SizedBox(height: 5),
              _StatusLabel(label: status.label, color: status.color),
            ],
          ),
        ),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              _appLabel(notification.packageName),
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: AppColors.canvas,
              borderRadius: BorderRadius.circular(14),
            ),
            child: SelectableText(
              notification.text.isEmpty
                  ? '(Tidak ada isi pesan)'
                  : notification.text,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(height: 1.45),
            ),
          ),
          const SizedBox(height: 12),
          if (transaction != null)
            _LinkedTransaction(transaction: transaction)
          else if (notification.processed && entry.handedToFlutter)
            const _ExplanationNote(
              text:
                  'Notifikasi sudah diterima dan diperiksa aplikasi, tetapi tidak ada transaksi yang cocok. Pesan lengkap di atas bisa membantu mencari penyebabnya.',
            )
          else if (!notification.processed)
            const _ExplanationNote(
              text: 'Notifikasi masih menunggu pemrosesan oleh AutoFinance.',
            )
          else
            const _ExplanationNote(
              text:
                  'Android menandai notifikasi ini selesai, tetapi tidak ada catatan pemrosesan di AutoFinance. Notifikasi dari aplikasi yang tidak didukung juga akan berstatus seperti ini.',
            ),
          const SizedBox(height: 8),
          Text(
            'ID notifikasi: ${notification.id}',
            style: Theme.of(context).textTheme.labelMedium,
          ),
        ],
      ),
    );
  }

  _NotificationStatus _status(_HistoryEntry entry) {
    final transaction = entry.transaction;
    if (transaction != null) {
      final kind = switch (transaction.type) {
        TransactionType.income => 'Pemasukan',
        TransactionType.expense => 'Pengeluaran',
        TransactionType.transfer => 'Transfer',
      };
      return _NotificationStatus(
        label:
            'Tercatat sebagai $kind • ${CategoryHelper.title(transaction.category)}',
        color: AppColors.income,
        icon: Icons.check_circle_rounded,
      );
    }
    if (!entry.notification.processed) {
      return const _NotificationStatus(
        label: 'Menunggu pemrosesan',
        color: Color(0xFFB7791F),
        icon: Icons.hourglass_top_rounded,
      );
    }
    if (entry.handedToFlutter) {
      return const _NotificationStatus(
        label: 'Diperiksa, belum ada transaksi',
        color: AppColors.expense,
        icon: Icons.warning_amber_rounded,
      );
    }
    return const _NotificationStatus(
      label: 'Selesai di Android, belum tercatat di aplikasi',
      color: AppColors.muted,
      icon: Icons.info_outline_rounded,
    );
  }

  String _dateLabel(DateTime time) =>
      DateFormat('dd MMM yyyy, HH:mm', 'id').format(time);

  String _appLabel(String packageName) {
    final parts = packageName.split('.').where((part) => part.isNotEmpty);
    return parts.isEmpty ? 'Aplikasi tidak dikenal' : parts.last;
  }
}

class _NotificationStatus {
  const _NotificationStatus({
    required this.label,
    required this.color,
    required this.icon,
  });

  final String label;
  final Color color;
  final IconData icon;
}

class _StatusLabel extends StatelessWidget {
  const _StatusLabel({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(Icons.circle, size: 7, color: color),
      const SizedBox(width: 6),
      Expanded(
        child: Text(
          label,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ],
  );
}

class _LinkedTransaction extends StatelessWidget {
  const _LinkedTransaction({required this.transaction});

  final Transaction transaction;

  @override
  Widget build(BuildContext context) {
    final sign = transaction.type == TransactionType.income ? '+' : '-';
    final color = switch (transaction.type) {
      TransactionType.income => AppColors.income,
      TransactionType.expense => AppColors.expense,
      TransactionType.transfer => AppColors.transfer,
    };
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 11, 8, 11),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Transaksi yang cocok',
                  style: TextStyle(fontSize: 11, color: AppColors.muted),
                ),
                const SizedBox(height: 3),
                Text(
                  '$sign${FormatterHelper.formatRupiah(transaction.amount)} • ${CategoryHelper.title(transaction.category)}',
                  style: TextStyle(color: color, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => context.push('/transaction/${transaction.id}'),
            child: const Text('Lihat'),
          ),
        ],
      ),
    );
  }
}

class _ExplanationNote extends StatelessWidget {
  const _ExplanationNote({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: AppColors.mint.withValues(alpha: 0.55),
      borderRadius: BorderRadius.circular(13),
    ),
    child: Text(
      text,
      style: const TextStyle(
        color: AppColors.forestDark,
        fontSize: 12,
        height: 1.4,
      ),
    ),
  );
}

class _HistoryError extends StatelessWidget {
  const _HistoryError({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: AppColors.expense,
            size: 34,
          ),
          const SizedBox(height: 10),
          const Text('Riwayat notifikasi belum bisa dimuat.'),
          const SizedBox(height: 4),
          Text(
            '$error',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Coba lagi'),
          ),
        ],
      ),
    ),
  );
}
