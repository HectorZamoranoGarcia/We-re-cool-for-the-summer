import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables.dart';

part 'pantry_dao.g.dart';



@DriftAccessor(tables: [PantryItems])
class PantryDao extends DatabaseAccessor<AppDatabase>
    with _$PantryDaoMixin {
  PantryDao(super.db);

  @override
  Future<void> addPantryItem(PantryItemsCompanion item) async {
    await into(pantryItems).insert(item);
  }

  @override
  Future<void> consumePantryItem(int id) async {
    await (update(pantryItems)..where((tbl) => tbl.id.equals(id)))
        .write(const PantryItemsCompanion(isConsumed: Value(true)));
  }

  /// FIFO algorithm to consume a specific amount of grams for a product.
  /// Identifies records sorted by expirationDate (or addedAt) ASC.
  Future<void> consumeProductFifo(String barcode, double gramsToConsume) async {
    return transaction(() async {
      final activeRecords = await (select(pantryItems)
            ..where((tbl) =>
                tbl.productBarcode.equals(barcode) &
                tbl.isConsumed.equals(false))
            ..orderBy([
              (t) => OrderingTerm(
                  expression: t.expirationDate, mode: OrderingMode.asc),
              (t) =>
                  OrderingTerm(expression: t.addedAt, mode: OrderingMode.asc),
            ]))
          .get();

      double remainingToConsume = gramsToConsume;

      for (final record in activeRecords) {
        if (remainingToConsume <= 0) break;

        if (record.grams <= remainingToConsume) {
          // Consume the entire record.
          remainingToConsume -= record.grams;
          await consumePantryItem(record.id);
        } else {
          // Consume partial amount.
          final newGrams = record.grams - remainingToConsume;
          await (update(pantryItems)..where((tbl) => tbl.id.equals(record.id)))
              .write(PantryItemsCompanion(grams: Value(newGrams)));
          remainingToConsume = 0;
        }
      }

      if (remainingToConsume > 0) {
        throw StateError(
            'Insufficient stock! Missing ${remainingToConsume}g for $barcode.');
      }
    });
  }

  @override
  Stream<List<PantryItem>> getActiveInventory() {
    return (select(pantryItems)
          ..where((tbl) => tbl.isConsumed.equals(false))
          ..orderBy([
            (t) =>
                OrderingTerm(expression: t.expirationDate, mode: OrderingMode.asc)
          ]))
        .watch();
  }

  @override
  Stream<List<PantryItem>> getExpiringSoon({int daysThreshold = 3}) {
    final now = DateTime.now();
    final thresholdDate = now.add(Duration(days: daysThreshold));

    return (select(pantryItems)
          ..where((tbl) =>
              tbl.isConsumed.equals(false) &
              tbl.expirationDate.isNotNull() &
              tbl.expirationDate.isSmallerOrEqualValue(thresholdDate))
          ..orderBy([
            (t) =>
                OrderingTerm(expression: t.expirationDate, mode: OrderingMode.asc)
          ]))
        .watch();
  }
}
