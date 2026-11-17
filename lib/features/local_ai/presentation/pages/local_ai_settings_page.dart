import 'dart:async';

import 'package:auto_finance/app/theme.dart';
import 'package:auto_finance/features/local_ai/data/services/local_ai_service.dart';
import 'package:auto_finance/features/local_ai/data/local_ai_source_catalog.dart';
import 'package:auto_finance/features/notification/application/providers/notification_sync_provider.dart';
import 'package:auto_finance/features/notification/application/providers/notification_attention_provider.dart';
import 'package:auto_finance/features/wallet/application/providers/wallet_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LocalAiSettingsPage extends ConsumerStatefulWidget {
  const LocalAiSettingsPage({super.key});

  @override
  ConsumerState<LocalAiSettingsPage> createState() => _LocalAiSettingsPageState();
}

class _LocalAiSettingsPageState extends ConsumerState<LocalAiSettingsPage> {
  Map<String, dynamic> _modelStatus = const {'downloaded': false};
  List<Map<String, dynamic>> _sources = const [];
  Map<String, String> _selectedSources = const {};
  final TextEditingController _sourceSearchController = TextEditingController();
  String _sourceTypeFilter = 'Semua';
  StreamSubscription<Map<String, int>>? _progressSubscription;
  double? _downloadProgress;
  bool _loading = true;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _progressSubscription?.cancel();
    _sourceSearchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final values = await Future.wait([
        LocalAiService.modelStatus(),
        LocalAiService.getAvailableSources(),
        LocalAiService.selectedSourceWallets(),
      ]);
      if (!mounted) return;
      setState(() {
        _modelStatus = values[0] as Map<String, dynamic>;
        _sources = values[1] as List<Map<String, dynamic>>;
        _selectedSources = values[2] as Map<String, String>;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _loading = false);
      _showMessage('Pengaturan AI lokal belum bisa dimuat: $error');
    }
  }

  Future<void> _downloadModel() async {
    setState(() {
      _busy = true;
      _downloadProgress = 0;
    });
    _progressSubscription = LocalAiService.downloadProgress.listen((event) {
      final total = event['totalBytes'] ?? 0;
      final downloaded = event['downloadedBytes'] ?? 0;
      if (mounted && total > 0) {
        setState(() => _downloadProgress = downloaded / total);
      }
    });
    try {
      await LocalAiService.downloadModel();
      await _refreshModelStatus();
      if (mounted) _showMessage('Model AI lokal siap digunakan.');
    } catch (error) {
      if (mounted) _showMessage('Model belum berhasil diunduh: $error');
    } finally {
      await _progressSubscription?.cancel();
      _progressSubscription = null;
      if (mounted) {
        setState(() {
          _busy = false;
          _downloadProgress = null;
        });
      }
    }
  }

  Future<void> _deleteModel() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus model AI?'),
        content: const Text(
          'Model sekitar 347 MB akan dihapus dari perangkat. Sumber aplikasi yang memakai AI lokal juga akan dinonaktifkan.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Batal')),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Hapus model')),
        ],
      ),
    );
    if (confirmed != true) return;
    setState(() => _busy = true);
    try {
      await LocalAiService.saveSelectedSourceWallets({});
      ref.invalidate(notificationAttentionCountsProvider);
      await LocalAiService.deleteModel();
      await _refreshModelStatus();
      if (mounted) {
        setState(() => _selectedSources = {});
        _showMessage('Model dan sumber AI lokal sudah dihapus.');
      }
    } catch (error) {
      if (mounted) _showMessage('Model belum bisa dihapus: $error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _refreshModelStatus() async {
    final status = await LocalAiService.modelStatus();
    if (mounted) setState(() => _modelStatus = status);
  }

  Future<void> _selectWallet(String packageName, String? walletId) async {
    if (walletId == null) return;
    final next = Map<String, String>.from(_selectedSources);
    next[packageName] = walletId;
    setState(() => _selectedSources = next);
    try {
      final queued = await LocalAiService.saveSelectedSourceWallets(next);
      ref.invalidate(notificationAttentionCountsProvider);
      if (queued > 0) {
        await ref.read(notificationSyncProvider).sync();
      }
      if (mounted) {
        _showMessage(
          queued > 0
              ? '$queued notifikasi terbaru diproses ulang. Notifikasi berikutnya diproses otomatis.'
              : 'Sumber transaksi disimpan. Notifikasi berikutnya diproses otomatis.',
        );
      }
    } catch (error) {
      if (mounted) _showMessage('Sumber transaksi belum bisa disimpan: $error');
      await _load();
    }
  }

  Future<void> _removeSource(String packageName) async {
    final next = Map<String, String>.from(_selectedSources)..remove(packageName);
    setState(() => _selectedSources = next);
    try {
      await LocalAiService.saveSelectedSourceWallets(next);
      ref.invalidate(notificationAttentionCountsProvider);
      if (mounted) _showMessage('Sumber AI lokal dinonaktifkan.');
    } catch (error) {
      if (mounted) _showMessage('Sumber belum bisa dinonaktifkan: $error');
      await _load();
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final wallets = ref.watch(walletStreamProvider).valueOrNull ?? const [];
    final downloaded = _modelStatus['downloaded'] == true;
    final sources = _mergedSources
        .where((source) {
          final type = source['sourceType']?.toString() ?? 'Lainnya';
          final search = _sourceSearchController.text.trim().toLowerCase();
          final matchesType = _sourceTypeFilter == 'Semua' || type == _sourceTypeFilter;
          final matchesSearch =
              search.isEmpty ||
              source['label'].toString().toLowerCase().contains(search) ||
              source['packageName'].toString().toLowerCase().contains(search);
          return matchesType && matchesSearch;
        })
        .toList(growable: false);

    return Scaffold(
      appBar: AppBar(title: const Text('AI lokal & sumber transaksi')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
              children: [
                _ModelCard(
                  supported: LocalAiService.isSupported,
                  downloaded: downloaded,
                  busy: _busy,
                  progress: _downloadProgress,
                  onDownload: _downloadModel,
                  onDelete: _deleteModel,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.mint.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.lock_outline_rounded, color: AppColors.forest),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Model dipakai di perangkat. Isi notifikasi tidak dikirim ke layanan AI. Unduhan model hanya diperlukan sekali; setelah itu pemrosesan bisa berjalan offline.',
                          style: TextStyle(height: 1.45, color: AppColors.forestDark),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text('SUMBER NOTIFIKASI', style: Theme.of(context).textTheme.labelMedium),
                const SizedBox(height: 6),
                Text(
                  'Pilih aplikasi bank atau e-wallet yang ingin dicatat otomatis, lalu hubungkan ke dompetnya.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _sourceSearchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Cari bank atau e-wallet',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _sourceSearchController.text.isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'Hapus pencarian',
                            onPressed: () {
                              _sourceSearchController.clear();
                              setState(() {});
                            },
                            icon: const Icon(Icons.close_rounded),
                          ),
                    border: const OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  children: ['Semua', 'Bank', 'E-wallet']
                      .map((type) {
                        return ChoiceChip(
                          label: Text(type),
                          selected: _sourceTypeFilter == type,
                          onSelected: (_) => setState(() => _sourceTypeFilter = type),
                          showCheckmark: false,
                        );
                      })
                      .toList(growable: false),
                ),
                const SizedBox(height: 8),
                if (sources.isEmpty)
                  const _NoMatchingSources()
                else
                  for (final source in sources)
                    _SourceCard(
                      source: source,
                      wallets: wallets,
                      selectedWalletId: _selectedSources[source['packageName']],
                      enabled: downloaded && !_busy,
                      onWalletSelected: (walletId) => _selectWallet(source['packageName'].toString(), walletId),
                      onRemove: () => _removeSource(source['packageName'].toString()),
                    ),
                const SizedBox(height: 14),
                const Text(
                  'Daftar ini mencakup aplikasi populer meski belum terpasang atau belum pernah mengirim notifikasi. Aplikasi lain akan muncul otomatis setelah notifikasinya diterima. Parser yang sudah ada tetap dipakai; AI membantu sumber yang belum dikenali.',
                  style: TextStyle(color: AppColors.muted, height: 1.4),
                ),
              ],
            ),
    );
  }

  List<Map<String, dynamic>> get _mergedSources {
    final byPackage = <String, Map<String, dynamic>>{
      for (final source in LocalAiSourceCatalog.all)
        source['packageName'].toString(): {...source, 'notificationCount': 0},
    };
    for (final source in _sources) {
      final packageName = source['packageName'].toString();
      byPackage[packageName] = {
        ...?byPackage[packageName],
        ...source,
        'sourceType': byPackage[packageName]?['sourceType'] ?? 'Lainnya',
      };
    }
    return byPackage.values.toList(growable: false)
      ..sort((a, b) => a['label'].toString().compareTo(b['label'].toString()));
  }
}

class _ModelCard extends StatelessWidget {
  const _ModelCard({
    required this.supported,
    required this.downloaded,
    required this.busy,
    required this.progress,
    required this.onDownload,
    required this.onDelete,
  });

  final bool supported;
  final bool downloaded;
  final bool busy;
  final double? progress;
  final VoidCallback onDownload;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: AppColors.line),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.auto_awesome_rounded, color: AppColors.forest),
            const SizedBox(width: 10),
            Expanded(child: Text('Model AI lokal', style: Theme.of(context).textTheme.titleMedium)),
            Text(
              downloaded ? 'Siap' : 'Belum diunduh',
              style: TextStyle(color: downloaded ? AppColors.income : AppColors.muted),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          supported ? 'Qwen3 0.6B INT4 · unduhan sekitar 347 MB' : 'Pemrosesan AI lokal saat ini tersedia di Android.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        if (busy && progress != null) ...[
          const SizedBox(height: 14),
          LinearProgressIndicator(value: progress!.clamp(0, 1)),
          const SizedBox(height: 6),
          Text('${(progress! * 100).clamp(0, 100).round()}% diunduh'),
        ],
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: downloaded
              ? OutlinedButton.icon(
                  onPressed: busy ? null : onDelete,
                  icon: const Icon(Icons.delete_outline_rounded),
                  label: const Text('Hapus model dari perangkat'),
                )
              : FilledButton.icon(
                  onPressed: !supported || busy ? null : onDownload,
                  icon: busy
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.download_rounded),
                  label: Text(busy ? 'Mengunduh model…' : 'Unduh model AI lokal'),
                ),
        ),
      ],
    ),
  );
}

class _SourceCard extends StatelessWidget {
  const _SourceCard({
    required this.source,
    required this.wallets,
    required this.selectedWalletId,
    required this.enabled,
    required this.onWalletSelected,
    required this.onRemove,
  });

  final Map<String, dynamic> source;
  final List wallets;
  final String? selectedWalletId;
  final bool enabled;
  final ValueChanged<String?> onWalletSelected;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final packageName = source['packageName'].toString();
    final selectedWalletExists = wallets.any((wallet) => wallet.id == selectedWalletId);
    final value = selectedWalletExists ? selectedWalletId : null;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                source['sourceType'] == 'E-wallet'
                    ? Icons.account_balance_wallet_rounded
                    : Icons.account_balance_rounded,
                color: AppColors.forest,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(source['label'].toString(), style: Theme.of(context).textTheme.titleSmall),
                    Text(
                      (source['notificationCount'] as num? ?? 0) > 0
                          ? '$packageName · ${source['notificationCount']} notifikasi'
                          : '$packageName · belum ada notifikasi',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              if (selectedWalletId != null)
                IconButton(tooltip: 'Nonaktifkan sumber', onPressed: onRemove, icon: const Icon(Icons.close_rounded)),
            ],
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            initialValue: value,
            decoration: const InputDecoration(
              labelText: 'Catat ke dompet',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            hint: Text(enabled ? 'Pilih dompet' : 'Unduh model terlebih dahulu'),
            items: wallets
                .where((wallet) => wallet.active)
                .map<DropdownMenuItem<String>>(
                  (wallet) =>
                      DropdownMenuItem(value: wallet.id as String, child: Text('${wallet.name} · ${wallet.bank}')),
                )
                .toList(),
            onChanged: enabled ? onWalletSelected : null,
          ),
        ],
      ),
    );
  }
}

class _NoMatchingSources extends StatelessWidget {
  const _NoMatchingSources();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: AppColors.line),
    ),
    child: const Text(
      'Tidak ada aplikasi yang cocok. Aplikasi yang belum terdaftar akan muncul otomatis setelah notifikasinya diterima.',
      style: TextStyle(color: AppColors.muted, height: 1.4),
    ),
  );
}
