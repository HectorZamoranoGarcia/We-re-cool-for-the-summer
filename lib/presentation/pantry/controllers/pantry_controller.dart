import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/di/repository_providers.dart';
import '../../../core/di/use_case_providers.dart';
import '../../../domain/entities/pantry_item_entity.dart';

part 'pantry_controller.g.dart';

@riverpod
class PantryController extends _$PantryController {
  @override
  Stream<List<PantryItemEntity>> build() {
    final repository = ref.watch(pantryRepositoryProvider);
    return repository.watchActiveInventory();
  }

  Future<void> consumeItem(int id) async {
    try {
      final repository = ref.read(pantryRepositoryProvider);
      await repository.consumePantryItem(id);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Directly persists a fully-formed [PantryItemEntity] (used by the scanner
  /// confirmation sheet after the user has set grams and expiry).
  Future<void> addItem(PantryItemEntity item) async {
    try {
      final addUseCase = ref.read(addProductToPantryUseCaseProvider);
      await addUseCase.execute(item);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> scanAndAddItem(String barcode) async {
    final previousState = state;
    state = const AsyncValue.loading();

    try {
      final scanUseCase = ref.read(scanProductUseCaseProvider);
      final addUseCase = ref.read(addProductToPantryUseCaseProvider);

      final product = await scanUseCase.execute(barcode);

      final newItem = PantryItemEntity(
        id: 0, // Assigned by SQLite
        productBarcode: product.barcode,
        grams: 100.0, // Default to 100g per scan
        addedAt: DateTime.now(),
        expirationDate: DateTime.now().add(const Duration(days: 7)), // MVP dummy value
        isConsumed: false,
      );

      await addUseCase.execute(newItem);
    } catch (e, stackTrace) {
      state = previousState.copyWithPrevious(AsyncValue.error(e, stackTrace));
    }
  }
}
