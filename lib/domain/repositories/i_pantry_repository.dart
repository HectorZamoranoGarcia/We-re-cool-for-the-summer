import '../entities/pantry_item_entity.dart';

abstract interface class IPantryRepository {
  Future<void> addPantryItem(PantryItemEntity item);

  Future<void> consumePantryItem(int id);

  Stream<List<PantryItemEntity>> watchActiveInventory();

  Stream<List<PantryItemEntity>> watchExpiringSoon();
}
