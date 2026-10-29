import 'package:auto_finance/app/theme.dart';
import 'package:auto_finance/core/helpers/notification_access_helper.dart';
import 'package:auto_finance/core/services/data_export_service.dart';
import 'package:auto_finance/core/services/data_import_service.dart';
import 'package:auto_finance/core/services/notification_permission_service.dart';
import 'package:auto_finance/features/transaction/application/providers/transaction_provider.dart';
import 'package:auto_finance/features/wallet/application/providers/wallet_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage>
    with WidgetsBindingObserver {
  bool? _notificationAccessEnabled;
  bool _openingSettings = false;
  bool _exportingData = false;
  bool _importingData = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refreshAccess();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refreshAccess();
  }

  Future<void> _refreshAccess() async {
    final enabled = await NotificationPermissionService.isEnabled();
    if (!mounted) return;
    setState(() => _notificationAccessEnabled = enabled);
  }

  Future<void> _openAccessSettings() async {
    setState(() => _openingSettings = true);
    try {
      await NotificationAccessHelper.openNotifAccess();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Pengaturan tidak bisa dibuka: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _openingSettings = false);
    }
  }

  Future<void> _exportData() async {
    setState(() => _exportingData = true);
    try {
      final transactions = await ref.read(transactionDaoProvider).getAll();
      final wallets = await ref.read(walletDaoProvider).getAll();
      if (!mounted) return;
      await DataExportService.share(
        context: context,
        transactions: transactions,
        wallets: wallets,
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Data belum bisa diekspor: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _exportingData = false);
    }
  }

  Future<void> _importData() async {
    setState(() => _importingData = true);
    try {
      final selection = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        withData: true,
      );
      if (selection == null || selection.files.isEmpty) return;
      final bytes = selection.files.single.bytes;
      if (bytes == null) throw StateError('File tidak bisa dibaca.');

      final wallets = await ref.read(walletDaoProvider).getAll();
      final transactions = DataImportService.parseTransactionsCsv(
        bytes,
        wallets,
      );
      if (!mounted) return;
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Impor transaksi?'),
          content: Text(
            '${transactions.length} transaksi akan ditambahkan. Data yang sudah ada akan dilewati. Saldo dompet tidak berubah.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Impor'),
            ),
          ],
        ),
      );
      if (confirmed != true || !mounted) return;

      final result = await DataImportService.importTransactions(
        transactions: transactions,
        transactionDao: ref.read(transactionDaoProvider),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Impor selesai: ${result.imported} ditambahkan, ${result.skipped} duplikat dilewati.',
            ),
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Data belum bisa diimpor: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _importingData = false);
    }
  }

  Future<void> _importWalletData() async {
    setState(() => _importingData = true);
    try {
      final selection = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        withData: true,
      );
      if (selection == null || selection.files.isEmpty) return;
      final bytes = selection.files.single.bytes;
      if (bytes == null) throw StateError('File tidak bisa dibaca.');

      final wallets = DataImportService.parseWalletsCsv(bytes);
      if (!mounted) return;
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Impor dompet?'),
          content: Text(
            '${wallets.length} dompet akan diperiksa. Dompet yang belum ada akan ditambahkan beserta saldo dan statusnya. Dompet yang sudah ada tidak diubah.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Impor'),
            ),
          ],
        ),
      );
      if (confirmed != true || !mounted) return;

      final result = await DataImportService.importWallets(
        wallets: wallets,
        walletDao: ref.read(walletDaoProvider),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Impor dompet selesai: ${result.imported} ditambahkan, ${result.skipped} dompet yang sudah ada dilewati.',
            ),
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Dompet belum bisa diimpor: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _importingData = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final enabled = _notificationAccessEnabled;

    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          Text(
            'Agar pencatatan tetap berjalan',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 6),
          Text(
            'Kelola izin dan cara Auto Finance membaca notifikasi transaksi.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.line),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: enabled == true
                            ? AppColors.mint
                            : const Color(0xFFFFEEE9),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Icon(
                        Icons.notifications_active_outlined,
                        color: enabled == true
                            ? AppColors.forest
                            : AppColors.expense,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Akses notifikasi',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            enabled == null
                                ? 'Sedang memeriksa…'
                                : enabled
                                ? 'Aktif di perangkat ini'
                                : 'Belum diaktifkan',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    if (enabled != null)
                      Icon(
                        enabled ? Icons.check_circle : Icons.error_outline,
                        color: enabled ? AppColors.income : AppColors.expense,
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Izin ini diperlukan agar Android dapat meneruskan notifikasi bank dan e-wallet ke Auto Finance. Transaksi yang dikenali akan disimpan di database aplikasi.',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(height: 1.45),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _openingSettings ? null : _openAccessSettings,
                    icon: Icon(
                      enabled == true
                          ? Icons.settings_outlined
                          : Icons.lock_open_rounded,
                    ),
                    label: Text(
                      _openingSettings
                          ? 'Membuka pengaturan…'
                          : enabled == true
                          ? 'Kelola akses notifikasi'
                          : 'Aktifkan akses notifikasi',
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.mint.withValues(alpha: 0.65),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.lock_outline_rounded, color: AppColors.forest),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Data transaksi disimpan di perangkat ini. Jangan aktifkan akses notifikasi untuk aplikasi yang tidak kamu percaya.',
                    style: TextStyle(color: AppColors.forestDark, height: 1.45),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text('DIAGNOSIS', style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.line),
            ),
            child: ListTile(
              leading: const Icon(
                Icons.notifications_active_rounded,
                color: AppColors.forest,
              ),
              title: const Text('Riwayat notifikasi'),
              subtitle: const Text(
                'Periksa pesan yang ditangkap dan transaksi yang dibuat',
              ),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => context.push('/notifications/history'),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'DATA & CADANGAN',
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const SizedBox(height: 10),
          Container(
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
                    const Icon(
                      Icons.ios_share_rounded,
                      color: AppColors.forest,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Ekspor data',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'Bagikan salinan transaksi dan daftar dompet dalam format CSV. Isi notifikasi lengkap ikut disertakan.',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(height: 1.4),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _exportingData ? null : _exportData,
                    icon: _exportingData
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.file_download_outlined),
                    label: Text(
                      _exportingData
                          ? 'Menyiapkan file…'
                          : 'Ekspor transaksi & dompet',
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Divider(height: 24),
                Row(
                  children: [
                    const Icon(
                      Icons.move_to_inbox_outlined,
                      color: AppColors.forest,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Impor data',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'Pulihkan data dari file CSV Auto Finance.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _importingData ? null : _importData,
                    icon: _importingData
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.receipt_long_outlined),
                    label: Text(
                      _importingData
                          ? 'Mengimpor transaksi…'
                          : 'Impor transaksi dari CSV',
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _importingData ? null : _importWalletData,
                    icon: _importingData
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.account_balance_wallet_outlined),
                    label: Text(
                      _importingData
                          ? 'Mengimpor dompet…'
                          : 'Impor dompet dari CSV',
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text('TENTANG', style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.line),
            ),
            child: const Row(
              children: [
                Icon(Icons.account_balance_rounded, color: AppColors.forest),
                SizedBox(width: 12),
                Expanded(child: Text('Auto Finance')),
                Text('Pribadi'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
