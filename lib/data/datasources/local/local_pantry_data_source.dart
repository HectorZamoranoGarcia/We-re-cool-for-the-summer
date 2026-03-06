import 'package:drift/drift.dart';

import '../../../domain/entities/pantry_item_entity.dart';
import 'app_database.dart';
import 'daos/pantry_dao.dart';

class LocalPantryDataSource {
  final PantryDao _pantryDao;

  LocalPantryDataSource(this._pantryDao);

  Future<void> addPantryItem(PantryItemEntity item) async {
    final companion = PantryItemsCompanion(
      productBarcode: Value(item.productBarcode),
      quantity: Value(item.quantity),
      addedAt: Value(item.addedAt),
      expirationDate: Value(item.expirationDate),
      isConsumed: Value(item.isConsumed),
    );
    await _pantryDao.addPantryItem(companion);
  }

  Future<void> consumePantryItem(int id) async {
    await _pantryDao.consumePantryItem(id);
  }

  Stream<List<PantryItemEntity>> watchActiveInventory() {
    return _pantryDao.getActiveInventory().map((rows) => rows.map((row) {
          return PantryItemEntity(
            id: row.id,
            productBarcode: row.productBarcode,
            quantity: row.quantity,
            addedAt: row.addedAt,
            expirationDate: row.expirationDate,
            isConsumed: row.isConsumed,
          );
        }).toList());
  }

  Stream<List<PantryItemEntity>> watchExpiringSoon() {
    return _pantryDao.getExpiringSoon().map((rows) => rows.map((row) {
          return PantryItemEntity(
            id: row.id,
            productBarcode: row.productBarcode,
            quantity: row.quantity,
            addedAt: row.addedAt,
            expirationDate: row.expirationDate,
            isConsumed: row.isConsumed,
          );
        }).toList());
  }
}
