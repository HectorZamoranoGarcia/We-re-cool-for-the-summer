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
