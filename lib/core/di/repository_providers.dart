import 'package:riverpod/riverpod.dart';
import 'data_source_providers.dart';

// Domain Interfaces
import '../../domain/repositories/i_product_repository.dart';
import '../../domain/repositories/i_pantry_repository.dart';
import '../../domain/repositories/i_price_repository.dart';

// Data Implementations
import '../../data/repositories/product_repository.dart';
import '../../data/repositories/pantry_repository.dart';
import '../../data/repositories/price_repository.dart';

final productRepositoryProvider = Provider<IProductRepository>((ref) {
  final localDataSource = ref.watch(localProductDataSourceProvider);
  final remoteDataSource = ref.watch(remoteProductDataSourceProvider);

  return ProductRepository(
    localDataSource,
    remoteDataSource,
  );
});

final pantryRepositoryProvider = Provider<IPantryRepository>((ref) {
  final localDataSource = ref.watch(localPantryDataSourceProvider);

  return PantryRepository(
    localDataSource,
  );
});

final priceRepositoryProvider = Provider<IPriceRepository>((ref) {
  final localDataSource = ref.watch(localPriceDataSourceProvider);

  return PriceRepository(
    localDataSource,
  );
});
