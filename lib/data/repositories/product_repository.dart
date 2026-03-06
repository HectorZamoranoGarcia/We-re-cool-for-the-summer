import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/i_product_repository.dart';
import '../datasources/local/local_product_data_source.dart';
import '../datasources/remote/remote_product_data_source.dart';

class ProductRepository implements IProductRepository {
  final LocalProductDataSource _localDataSource;
  final RemoteProductDataSource _remoteDataSource;

  ProductRepository(
    this._localDataSource,
    this._remoteDataSource,
  );

  @override
  Future<ProductEntity> getOrFetchProduct(String barcode) async {
    // 1. Try to fetch from local database first
    final localProduct = await _localDataSource.getProductByBarcode(barcode);
    if (localProduct != null) {
      return localProduct;
    }

    // 2. If not found locally, fetch from remote source
    final remoteProduct = await _remoteDataSource.fetchProductByBarcode(barcode);

    if (remoteProduct == null) {
      throw Exception('Product with barcode \$barcode not found remotely.');
    }

    // 3. Save the fetched product locally for future read-through caching
    await _localDataSource.insertProduct(remoteProduct);

    return remoteProduct;
  }
}
