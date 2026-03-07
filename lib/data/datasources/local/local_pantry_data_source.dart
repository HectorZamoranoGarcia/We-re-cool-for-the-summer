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
      grams: Value(item.grams),
      addedAt: Value(item.addedAt),
      expirationDate: Value(item.expirationDate),
      isConsumed: Value(item.isConsumed),
    );
    await _pantryDao.addPantryItem(companion);
  }

  Future<void> consumePantryItem(int id) async {
    await _pantryDao.consumePantryItem(id);
  }

  Future<void> consumeProduct(String barcode, double gramsToConsume) async {
    await _pantryDao.consumeProductFifo(barcode, gramsToConsume);
  }

  Stream<List<PantryItemEntity>> watchActiveInventory() {
    return _pantryDao.getActiveInventory().map((rows) => rows.map((row) {
          return PantryItemEntity(
            id: row.id,
            productBarcode: row.productBarcode,
            grams: row.grams,
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
            grams: row.grams,
            addedAt: row.addedAt,
            expirationDate: row.expirationDate,
            isConsumed: row.isConsumed,
          );
        }).toList());
  }
}
