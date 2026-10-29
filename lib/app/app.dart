import 'package:auto_finance/core/services/finance_widget_sync_service.dart';
import 'package:auto_finance/app/router.dart';
import 'package:auto_finance/app/theme.dart';
import 'package:auto_finance/core/helpers/category_helper.dart';
import 'package:auto_finance/features/transaction/domain/entities/transaction_categories.dart';
import 'package:auto_finance/features/transaction/domain/entities/transaction_type.dart';
import 'package:auto_finance/features/transaction/domain/usecases/categorize_transaction.dart';
import 'package:auto_finance/features/notification/application/services/notification_bus.dart';
import 'package:auto_finance/features/transaction/application/providers/startup_provider.dart';
import 'package:auto_finance/features/transaction/application/providers/transaction_provider.dart';
import 'package:auto_finance/features/wallet/application/providers/wallet_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _AppRootState();
}

class _AppRootState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      try {
        const goPayDuplicateRepairKey = 'gopayGooglePlay8880DuplicateRepairV1';
        final preferences = await SharedPreferences.getInstance();
        if (!(preferences.getBool(goPayDuplicateRepairKey) ?? false)) {
          final removedGoPayDuplicate = await ref
              .read(transactionDaoProvider)
              .reconcileReportedGoPayGooglePlayDuplicate();
          await preferences.setBool(goPayDuplicateRepairKey, true);
          debugPrint(
            'Reconciled $removedGoPayDuplicate reported GoPay Google Play duplicate(s).',
          );
        }

        final reconciledPocketMovements = await ref
            .read(transactionDaoProvider)
            .reconcileJagoPocketMovements();
        if (reconciledPocketMovements > 0) {
          debugPrint(
            'Reconciled $reconciledPocketMovements old Jago pocket movements.',
          );
        }

        final removedPromotions = await ref
            .read(transactionDaoProvider)
            .removeJagoPromotionalTransactions();
        if (removedPromotions > 0) {
          debugPrint(
            'Removed $removedPromotions Jago promotional notifications recorded as transactions.',
          );
        }

        final categorizer = CategorizeTransactionUseCase();
        await ref
            .read(transactionDaoProvider)
            .recategorizeOtherTransactions(
              (rawText) => categorizer(rawText).name,
            );
        final learnedUpdates = await ref
            .read(merchantCategoryRuleDaoProvider)
            .applyAllRulesToExistingTransactions();
        debugPrint(
          'Applied saved merchant categories to $learnedUpdates old transactions.',
        );
      } catch (error, stackTrace) {
        debugPrint('Transaction recategorization failed: $error\n$stackTrace');
      }

      NotificationBus.start(ref);
      await ref.read(startupSyncProvider).run();
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(walletStreamProvider, (_, _) => _syncFinanceWidget());
    ref.listen(transactionStreamProvider, (_, _) => _syncFinanceWidget());
    ref.listen(monthlyBudgetStreamProvider, (_, _) => _syncFinanceWidget());

    initializeDateFormatting('id');
    return MaterialApp.router(
      routerConfig: appRouter,
      theme: AppTheme.light,
      debugShowCheckedModeBanner: false,
    );
  }

  Future<void> _syncFinanceWidget() async {
    final wallets = ref.read(walletStreamProvider).valueOrNull;
    final transactions = ref.read(transactionStreamProvider).valueOrNull;
    final budgets = ref.read(monthlyBudgetStreamProvider).valueOrNull;
    if (wallets == null || transactions == null || budgets == null) return;

    final now = DateTime.now();
    final totalBalance = wallets.fold<int>(
      0,
      (total, wallet) => total + wallet.balance,
    );
    final monthlyTransactions = transactions.where(
      (transaction) =>
          transaction.type == TransactionType.expense &&
          transaction.time.year == now.year &&
          transaction.time.month == now.month,
    );
    final monthlyExpense = monthlyTransactions.fold<int>(
      0,
      (total, transaction) => total + transaction.amount,
    );
    final budgetItems =
        budgets.map((budget) {
          final category = TransactionCategory.values.firstWhere(
            (category) => category.name == budget.category,
            orElse: () => TransactionCategory.other,
          );
          final spent = monthlyTransactions
              .where((transaction) => transaction.category == category)
              .fold<int>(0, (total, transaction) => total + transaction.amount);
          return <String, Object>{
            'categoryKey': category.name,
            'category': CategoryHelper.title(category),
            'spent': spent,
            'limit': budget.monthlyLimit,
          };
        }).toList()..sort((a, b) {
          final aIndex = TransactionCategory.values.indexWhere(
            (category) => CategoryHelper.title(category) == a['category'],
          );
          final bIndex = TransactionCategory.values.indexWhere(
            (category) => CategoryHelper.title(category) == b['category'],
          );
          return aIndex.compareTo(bIndex);
        });

    try {
      await FinanceWidgetSyncService().updateSummary(
        totalBalance: totalBalance,
        monthlyExpense: monthlyExpense,
        budgetItems: budgetItems,
        updatedAt: now,
      );
    } catch (error, stackTrace) {
      debugPrint('Finance widget refresh failed: $error\n$stackTrace');
    }
  }
}
