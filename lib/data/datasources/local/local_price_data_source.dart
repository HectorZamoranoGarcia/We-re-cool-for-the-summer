import 'package:drift/drift.dart';

import '../../../domain/entities/price_record_entity.dart';
import 'app_database.dart';
import 'daos/price_dao.dart';

class LocalPriceDataSource {
  final PriceDao _priceDao;

  LocalPriceDataSource(this._priceDao);

  Future<void> insertPriceRecord(PriceRecordEntity record) async {
    final companion = PriceRecordsCompanion(
      productBarcode: Value(record.productBarcode),
      supermarketId: Value(record.supermarketId),
      price: Value(record.price),
      currency: Value(record.currency),
      recordedAt: Value(record.recordedAt),
    );
    await _priceDao.insertPriceRecord(companion);
  }

  Stream<List<PriceRecordEntity>> watchPriceHistory(String barcode) {
    return _priceDao.getPriceHistoryForProduct(barcode).map((rows) => rows.map((row) {
          return PriceRecordEntity(
            id: row.id,
            productBarcode: row.productBarcode,
            supermarketId: row.supermarketId,
            price: row.price,
            currency: row.currency,
            recordedAt: row.recordedAt,
          );
        }).toList());
  }
}
