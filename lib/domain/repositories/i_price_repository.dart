import '../entities/price_record_entity.dart';

abstract interface class IPriceRepository {
  Future<void> recordPrice(PriceRecordEntity record);

  Stream<List<PriceRecordEntity>> watchPriceHistory(String barcode);
}
