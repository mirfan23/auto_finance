import 'package:auto_finance/core/services/notification_db_service.dart';
import 'package:auto_finance/features/notification/domain/entities/received_notification.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const notificationHistoryPageSize = 100;

class NotificationHistoryState {
  const NotificationHistoryState({
    required this.notifications,
    required this.hasMore,
    this.isLoadingMore = false,
    this.loadMoreError,
  });

  final List<ReceivedNotification> notifications;
  final bool hasMore;
  final bool isLoadingMore;
  final String? loadMoreError;

  NotificationHistoryState copyWith({
    List<ReceivedNotification>? notifications,
    bool? hasMore,
    bool? isLoadingMore,
    String? loadMoreError,
    bool clearLoadMoreError = false,
  }) => NotificationHistoryState(
    notifications: notifications ?? this.notifications,
    hasMore: hasMore ?? this.hasMore,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    loadMoreError: clearLoadMoreError
        ? null
        : loadMoreError ?? this.loadMoreError,
  );
}

final notificationHistoryProvider =
    AsyncNotifierProvider.autoDispose<
      NotificationHistoryController,
      NotificationHistoryState
    >(NotificationHistoryController.new);

class NotificationHistoryController
    extends AutoDisposeAsyncNotifier<NotificationHistoryState> {
  @override
  Future<NotificationHistoryState> build() => _loadPage(offset: 0);

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _loadPage(offset: 0));
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null ||
        !current.hasMore ||
        current.isLoadingMore ||
        current.loadMoreError != null) {
      return;
    }

    state = AsyncData(current.copyWith(isLoadingMore: true));
    try {
      final nextPage = await _loadPage(offset: current.notifications.length);
      state = AsyncData(
        current.copyWith(
          notifications: [...current.notifications, ...nextPage.notifications],
          hasMore: nextPage.hasMore,
          isLoadingMore: false,
          clearLoadMoreError: true,
        ),
      );
    } catch (error) {
      state = AsyncData(
        current.copyWith(isLoadingMore: false, loadMoreError: error.toString()),
      );
    }
  }

  Future<void> retryLoadMore() async {
    final current = state.valueOrNull;
    if (current == null || current.isLoadingMore) return;
    state = AsyncData(
      current.copyWith(clearLoadMoreError: true, isLoadingMore: false),
    );
    await loadMore();
  }

  Future<NotificationHistoryState> _loadPage({required int offset}) async {
    final maps = await NotificationDbService.getAllNotifications(
      offset: offset,
      limit: notificationHistoryPageSize,
    );
    final notifications = maps
        .map(ReceivedNotification.fromMap)
        .toList(growable: false);
    return NotificationHistoryState(
      notifications: notifications,
      hasMore: notifications.length == notificationHistoryPageSize,
    );
  }
}
