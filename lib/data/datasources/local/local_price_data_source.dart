import 'package:drift/drift.dart';

import '../../../domain/entities/price_record_entity.dart';
import 'app_database.dart';
import 'daos/price_dao.dart';
import 'tables.dart';

class LocalPriceDataSource {
  final PriceDao _priceDao;

  LocalPriceDataSource(this._priceDao);

  Future<void> insertPriceRecord(PriceRecordEntity record) async {
    // Parse the supermarket name back to the enum, defaulting to .other
    final supermarketEnum = Supermarket.values.firstWhere(
      (e) => e.name == record.supermarketName,
      orElse: () => Supermarket.other,
    );
    final companion = PriceRecordsCompanion(
      productBarcode: Value(record.productBarcode),
      supermarketTag: Value(supermarketEnum),
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
            // Convert the stored enum back to a human-readable string name
            supermarketName: row.supermarketTag.name,
            price: row.price,
            currency: row.currency,
            recordedAt: row.recordedAt,
          );
        }).toList());
  }

  /// Returns a snapshot of all price records for [barcode], sorted by date DESC.
  Future<List<PriceRecordEntity>> getPriceHistory(String barcode) async {
    final rows = await _priceDao.getPriceHistoryForProduct(barcode).first;
    return rows.map((row) => PriceRecordEntity(
      id: row.id,
      productBarcode: row.productBarcode,
      supermarketName: row.supermarketTag.name,
      price: row.price,
      currency: row.currency,
      recordedAt: row.recordedAt,
    )).toList();
  }

  /// Returns the all-time cheapest price for [barcode], or null if no records.
  Future<double?> lowestPriceEver(String barcode) async {
    final history = await getPriceHistory(barcode);
    if (history.isEmpty) return null;
    return history.map((r) => r.price).reduce((a, b) => a < b ? a : b);
  }
}
