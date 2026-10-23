import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final hideMoneyValuesProvider =
    StateNotifierProvider<MoneyVisibilityController, bool>(
      (ref) => MoneyVisibilityController(),
    );

class MoneyVisibilityController extends StateNotifier<bool> {
  MoneyVisibilityController() : super(true) {
    _restore();
  }

  static const _preferenceKey = 'hide_money_values';
  final Completer<void> _restored = Completer<void>();
  SharedPreferences? _preferences;

  Future<void> _restore() async {
    try {
      _preferences = await SharedPreferences.getInstance();
      state = _preferences?.getBool(_preferenceKey) ?? false;
    } catch (_) {
      state = false;
    } finally {
      _restored.complete();
    }
  }

  Future<void> toggle() async {
    await _restored.future;
    final hide = !state;
    state = hide;
    try {
      await _preferences?.setBool(_preferenceKey, hide);
    } catch (_) {
      // Keep the current setting for this app session if storage is unavailable.
    }
  }
}
