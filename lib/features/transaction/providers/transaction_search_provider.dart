import 'package:flutter_riverpod/flutter_riverpod.dart';

final transactionSearchProvider = StateProvider.autoDispose<String>((ref) => "");
