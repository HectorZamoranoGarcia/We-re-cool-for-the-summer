import '../entities/product_entity.dart';

abstract interface class IProductRepository {
  /// Fetches a product from the local store or a remote service if not found.
  Future<ProductEntity> getOrFetchProduct(String barcode);
}
