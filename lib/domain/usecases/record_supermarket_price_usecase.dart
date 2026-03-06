import '../entities/price_record_entity.dart';
import '../repositories/i_price_repository.dart';

class RecordSupermarketPriceUseCase {
  final IPriceRepository _priceRepository;

  const RecordSupermarketPriceUseCase(this._priceRepository);

  Future<void> execute(PriceRecordEntity record) async {
    if (record.price < 0) {
      throw ArgumentError('Price cannot be negative.');
    }
    if (record.currency.isEmpty) {
      throw ArgumentError('Currency is required.');
    }

    await _priceRepository.recordPrice(record);
  }
}
