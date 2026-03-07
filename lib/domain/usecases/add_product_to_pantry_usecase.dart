import '../entities/pantry_item_entity.dart';
import '../repositories/i_pantry_repository.dart';

class AddProductToPantryUseCase {
  final IPantryRepository _pantryRepository;

  const AddProductToPantryUseCase(this._pantryRepository);

  Future<void> execute(PantryItemEntity item) async {
    if (item.expirationDate != null && item.expirationDate!.isBefore(DateTime.now())) {
      throw StateError('Cannot add product to pantry with an expiration date in the past.');
    }
    if (item.grams <= 0) {
      throw ArgumentError('Grams must be greater than zero.');
    }

    await _pantryRepository.addPantryItem(item);
  }
}
