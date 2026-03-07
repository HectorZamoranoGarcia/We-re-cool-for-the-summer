import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../domain/entities/price_record_entity.dart';
import '../../../core/di/use_case_providers.dart';

part 'price_input_controller.g.dart';

@riverpod
class PriceInputController extends _$PriceInputController {
  @override
  FutureOr<void> build() {}

  Future<void> savePrice(String barcode, String supermarketName, double price) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final recordSupermarketPriceUseCase = ref.read(recordSupermarketPriceUseCaseProvider);

      final entity = PriceRecordEntity(
        id: 0,
        productBarcode: barcode,
        supermarketName: supermarketName,
        price: price,
        currency: 'EUR',
        recordedAt: DateTime.now(),
      );

      await recordSupermarketPriceUseCase.execute(entity);
    });
  }
}
