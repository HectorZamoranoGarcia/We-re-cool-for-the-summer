import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/entities/price_record_entity.dart';
import '../../../core/di/repository_providers.dart';

part 'price_history_controller.g.dart';

/// State class that bundles the full history with derived metrics.
class PriceHistoryState {
  final List<PriceRecordEntity> allRecords;

  /// Currently active supermarket filter; null means "all supermarkets".
  final String? supermarketFilter;

  const PriceHistoryState({
    this.allRecords = const [],
    this.supermarketFilter,
  });

  /// Filtered view used by the UI.
  List<PriceRecordEntity> get filtered {
    if (supermarketFilter == null) return allRecords;
    return allRecords
        .where((r) =>
            r.supermarketName.toLowerCase() == supermarketFilter!.toLowerCase())
        .toList();
  }

  /// All-time lowest price across any supermarket (the global minimum).
  double? get lowestPriceEver {
    if (allRecords.isEmpty) return null;
    return allRecords.map((r) => r.price).reduce((a, b) => a < b ? a : b);
  }

  /// fl_chart FlSpot-compatible list for the trend line.
  /// Returns records chronologically (oldest first) as (index, price) pairs.
  List<(double x, double y)> get priceTrendSeries {
    final sorted = [...filtered]
      ..sort((a, b) => a.recordedAt.compareTo(b.recordedAt));
    return sorted
        .asMap()
        .entries
        .map((e) => (e.key.toDouble(), e.value.price))
        .toList();
  }

  PriceHistoryState copyWith({
    List<PriceRecordEntity>? allRecords,
    String? supermarketFilter,
    bool clearFilter = false,
  }) {
    return PriceHistoryState(
      allRecords: allRecords ?? this.allRecords,
      supermarketFilter: clearFilter ? null : (supermarketFilter ?? this.supermarketFilter),
    );
  }
}

@riverpod
class PriceHistory extends _$PriceHistory {
  @override
  Stream<PriceHistoryState> build(String barcode) {
    final repository = ref.watch(priceRepositoryProvider);

    return repository.watchPriceHistory(barcode).map(
          (records) => PriceHistoryState(
            allRecords: records,
            supermarketFilter: state.valueOrNull?.supermarketFilter,
          ),
        );
  }

  void filterBySupermarket(String name) {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(current.copyWith(supermarketFilter: name));
  }

  void clearFilter() {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(current.copyWith(clearFilter: true));
  }
}

// Keep the old simple provider for backward compat (scanner + cheapest widget)
@riverpod
Stream<List<PriceRecordEntity>> rawPriceHistory(
  RawPriceHistoryRef ref,
  String barcode,
) {
  final repository = ref.watch(priceRepositoryProvider);
  return repository.watchPriceHistory(barcode);
}
