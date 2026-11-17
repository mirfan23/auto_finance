import 'package:auto_finance/app/theme.dart';
import 'package:auto_finance/features/notification/application/providers/notification_attention_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class NotificationAttentionShortcut extends ConsumerWidget {
  const NotificationAttentionShortcut({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final counts = ref.watch(notificationAttentionCountsProvider);
    final total = counts.valueOrNull?.total;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
      child: Material(
        color: AppColors.mint.withValues(alpha: 0.42),
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => context.push('/notifications/action-required'),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            child: Row(
              children: [
                const Icon(
                  Icons.notifications_active_outlined,
                  color: AppColors.forest,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Notifikasi perlu ditinjau',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        counts.isLoading
                            ? 'Memeriksa notifikasi…'
                            : counts.hasError
                            ? 'Ketuk untuk membuka daftar'
                            : total == 0
                            ? 'Tidak ada notifikasi yang menunggu'
                            : '$total notifikasi menunggu tindakan',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                if (total != null && total > 0) ...[
                  const SizedBox(width: 8),
                  Badge(
                    label: Text(total > 99 ? '99+' : '$total'),
                    backgroundColor: AppColors.expense,
                    textColor: Colors.white,
                  ),
                ] else if (counts.hasError)
                  const Icon(Icons.chevron_right_rounded)
                else if (total == 0)
                  const Icon(Icons.check_circle_outline_rounded),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
