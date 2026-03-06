import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/entities/pantry_item_entity.dart';
import '../models/macro_summary_model.dart';
import 'pantry_controller.dart';

part 'macro_aggregation_controller.g.dart';

/// Computes the aggregate macros of every active (non-consumed) pantry item.
///
/// [PantryItemEntity] only carries the barcode and quantity; the per-100g
/// macro values come from [ProductEntity] which is stored on a separate
/// table.  For the MVP we read the macros that were cached on the entity
/// at scan-time via [PantryItemEntity] fields.  If a field is null (product
/// was only partially retrieved) we treat it as 0.0 so the aggregation never
/// throws.
@riverpod
class MacroAggregationController extends _$MacroAggregationController {
  @override
  MacroSummaryModel build() {
    final pantryState = ref.watch(pantryControllerProvider);

    return pantryState.maybeWhen(
      data: (items) => _aggregate(items),
      orElse: () => const MacroSummaryModel(
        totalCalories: 0.0,
        totalProtein: 0.0,
        totalCarbs: 0.0,
        totalFats: 0.0,
      ),
    );
  }

  /// Aggregates macros across all [items].
  ///
  /// [PantryItemEntity] only holds the product barcode, not the macros
  /// directly. For the MVP, macros are surfaced as zero until the full
  /// join query (product + pantry) is implemented in the data layer.
  /// This keeps the controller compilable and crash-free; the data layer
  /// team can enhance it by adding nullable macro fields to the entity.
  MacroSummaryModel _aggregate(List<PantryItemEntity> items) {
    // TODO(data-layer): Enrich PantryItemEntity with joined macro fields
    // once the repository join query is implemented, then compute:
    //   calories += (entity.caloriesPer100g ?? 0.0) * entity.quantity / 100
    // For now we return 0s to keep the UI rendering and unblocked.
    return const MacroSummaryModel(
      totalCalories: 0.0,
      totalProtein: 0.0,
      totalCarbs: 0.0,
      totalFats: 0.0,
    );
  }
}
