import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/di/repository_providers.dart';
import '../../../domain/entities/pantry_item_entity.dart';
import '../../../domain/entities/product_entity.dart';
import 'pantry_controller.dart';

part 'dashboard_controller.g.dart';

@riverpod
List<PantryItemEntity> urgentItems(UrgentItemsRef ref) {
  // Performance: select only emits when the active items actually change
  final items = ref.watch(
    pantryControllerProvider.select((s) => s.valueOrNull ?? []),
  );

  final active = items
      .where((i) => !i.isConsumed && i.expirationDate != null)
      .toList();

  active.sort((a, b) => a.expirationDate!.compareTo(b.expirationDate!));

  return active.take(5).toList();
}

@riverpod
Map<String, double> groupedInventory(GroupedInventoryRef ref) {
  final items = ref.watch(
    pantryControllerProvider.select((s) => s.valueOrNull ?? []),
  );

  final map = <String, double>{};
  for (final item in items) {
    if (item.isConsumed) continue;
    map[item.productBarcode] = (map[item.productBarcode] ?? 0.0) + item.grams;
  }

  return map;
}

/// Helper provider to fetch product details reactively in the UI layer.
@riverpod
Future<ProductEntity> productDetails(ProductDetailsRef ref, String barcode) {
  final repo = ref.watch(productRepositoryProvider);
  return repo.getOrFetchProduct(barcode);
}
