import 'package:rendezvous_community/src/core/storage/local_values.dart';
import 'package:rendezvous_community/src/features/config/domain/repositories/promo_popup_history_repository.dart';

class PromoPopupHistoryRepositoryImpl implements PromoPopupHistoryRepository {
  PromoPopupHistoryRepositoryImpl(this._values, {this.maxEntries = 100});

  static const _prefix = 'promo_popups:';

  final LocalValues _values;
  final int maxEntries;

  @override
  Future<Map<String, DateTime>> load(String userId) async {
    final shown = (await _values.read('$_prefix$userId'))?['shown'];
    return {
      if (shown is Map)
        for (final entry in shown.entries)
          if (entry.key is String && entry.value is String && DateTime.tryParse(entry.value as String) != null)
            entry.key as String: DateTime.parse(entry.value as String),
    };
  }

  @override
  Future<void> save(String userId, Map<String, DateTime> shown) {
    final entries = shown.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return _values.write('$_prefix$userId', {
      'shown': {for (final entry in entries.take(maxEntries)) entry.key: entry.value.toUtc().toIso8601String()},
    });
  }
}
