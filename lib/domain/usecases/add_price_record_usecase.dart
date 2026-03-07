import '../entities/price_record_entity.dart';
import '../repositories/i_price_repository.dart';

/// Domain use case that validates and saves a new supermarket price reading.
/// Conforms to the prompt's requirement: receives barcode, price, and supermarketName.
///
/// Use [RecordSupermarketPriceUseCase] from the providers if you already have
/// a fully-formed [PriceRecordEntity]; use this for scanner-side input.
class AddPriceRecordUseCase {
  final IPriceRepository _repository;

  const AddPriceRecordUseCase(this._repository);

  Future<void> execute({
    required String barcode,
    required double price,
    required String supermarketName,
    String currency = 'EUR',
  }) async {
    if (price < 0) throw ArgumentError('Price cannot be negative.');
    if (barcode.isEmpty) throw ArgumentError('Barcode cannot be empty.');
    if (supermarketName.isEmpty) throw ArgumentError('Supermarket cannot be empty.');

    final record = PriceRecordEntity(
      id: 0,
      productBarcode: barcode,
      supermarketName: supermarketName,
      price: price,
      currency: currency,
      recordedAt: DateTime.now(),
    );

    await _repository.recordPrice(record);
  }
}
