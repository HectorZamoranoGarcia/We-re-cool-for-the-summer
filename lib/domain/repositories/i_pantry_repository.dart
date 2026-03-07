import '../entities/pantry_item_entity.dart';

abstract interface class IPantryRepository {
  Future<void> addPantryItem(PantryItemEntity item);

  Future<void> consumePantryItem(int id);

  Future<void> consumeProduct(String barcode, double gramsToConsume);

  Stream<List<PantryItemEntity>> watchActiveInventory();

  Stream<List<PantryItemEntity>> watchExpiringSoon();
}
