import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/entities/pantry_item_entity.dart';
import '../../../core/di/repository_providers.dart';
import '../models/macro_summary_model.dart';
import 'pantry_controller.dart';

part 'macro_aggregation_controller.g.dart';

/// Aggregates the macro nutritional totals across all active pantry stock.
/// Uses the formula: Total_N = sum( Grams * Macro_Value_Per_100g / 100 )
@riverpod
class PantryStats extends _$PantryStats {
  @override
  FutureOr<MacroSummaryModel> build() async {
    // ── Performance: Use .select() so we only rebuild when the actual active
    // list of items changes, ignoring other states like loading or errors.
    final items = ref.watch(
      pantryControllerProvider.select((state) => state.valueOrNull ?? []),
    );

    if (items.isEmpty) {
      return const MacroSummaryModel(
        totalCalories: 0.0,
        totalProtein: 0.0,
        totalCarbs: 0.0,
        totalFats: 0.0,
      );
    }

    final productRepo = ref.read(productRepositoryProvider);

    double pantryTotalCalories = 0.0;
    double totalProtein = 0.0;
    double totalCarbs = 0.0;
    double totalFats = 0.0;

    // Fetch the rich product data for every distinct barcode in the pantry.
    // In a real DB this would be a JOIN query, but for Clean Architecture MVP decoupled
    // domains, we fetch them via the repository orchestrator (which hits local DB cache).
    for (final item in items) {
      if (item.isConsumed) continue;

      try {
        final product = await productRepo.getOrFetchProduct(item.productBarcode);

        // Multiplier based on weight
        final factor = item.grams / 100.0;

        pantryTotalCalories += (product.caloriesPer100g ?? 0.0) * factor;
        totalProtein += (product.proteinPer100g ?? 0.0) * factor;
        totalCarbs += (product.carbsPer100g ?? 0.0) * factor;
        totalFats += (product.fatsPer100g ?? 0.0) * factor;
      } catch (e) {
        // If an item couldn't be resolved, we just skip its macros rather than crashing
        continue;
      }
    }

    return MacroSummaryModel(
      totalCalories: pantryTotalCalories,
      totalProtein: totalProtein,
      totalCarbs: totalCarbs,
      totalFats: totalFats,
    );
  }
}
