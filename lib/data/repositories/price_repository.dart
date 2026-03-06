import '../../domain/entities/price_record_entity.dart';
import '../../domain/repositories/i_price_repository.dart';
import '../datasources/local/local_price_data_source.dart';

class PriceRepository implements IPriceRepository {
  final LocalPriceDataSource _localDataSource;

  PriceRepository(this._localDataSource);

  @override
  Future<void> recordPrice(PriceRecordEntity record) async {
    await _localDataSource.insertPriceRecord(record);
  }

  @override
  Stream<List<PriceRecordEntity>> watchPriceHistory(String barcode) {
    return _localDataSource.watchPriceHistory(barcode);
  }
}
