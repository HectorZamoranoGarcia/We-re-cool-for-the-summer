import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables.dart';

part 'price_dao.g.dart';



@DriftAccessor(tables: [PriceRecords])
class PriceDao extends DatabaseAccessor<AppDatabase>
    with _$PriceDaoMixin {
  PriceDao(super.db);

  @override
  Future<void> insertPriceRecord(PriceRecordsCompanion record) async {
    await into(priceRecords).insert(record);
  }

  @override
  Stream<List<PriceRecord>> getPriceHistoryForProduct(String barcode) {
    return (select(priceRecords)
          ..where((tbl) => tbl.productBarcode.equals(barcode))
          ..orderBy([
            (t) => OrderingTerm(expression: t.recordedAt, mode: OrderingMode.desc)
          ]))
        .watch();
  }
}
