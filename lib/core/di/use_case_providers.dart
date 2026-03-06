import 'package:riverpod/riverpod.dart';
import 'repository_providers.dart';

import '../../domain/usecases/scan_product_usecase.dart';
import '../../domain/usecases/add_product_to_pantry_usecase.dart';
import '../../domain/usecases/record_supermarket_price_usecase.dart';

final scanProductUseCaseProvider = Provider<ScanProductUseCase>((ref) {
  final productRepository = ref.watch(productRepositoryProvider);
  return ScanProductUseCase(productRepository);
});

final addProductToPantryUseCaseProvider = Provider<AddProductToPantryUseCase>((ref) {
  final pantryRepository = ref.watch(pantryRepositoryProvider);
  return AddProductToPantryUseCase(pantryRepository);
});

final recordSupermarketPriceUseCaseProvider = Provider<RecordSupermarketPriceUseCase>((ref) {
  final priceRepository = ref.watch(priceRepositoryProvider);
  return RecordSupermarketPriceUseCase(priceRepository);
});
