import '../../core/errors/exceptions.dart';
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
  Future<ProductEntity> getOrFetchProduct(String productBarcode) async {
    // ── Step 1: Cache look-up (Drift / SQLite) ─────────────────────────────
    final cachedProduct = await _localDataSource.getProductByBarcode(productBarcode);
    final isCacheHit = cachedProduct != null;

    if (isCacheHit) {
      return cachedProduct;
    }

    // ── Step 2: Remote fetch (Open Food Facts API) ─────────────────────────
    // Catches network errors and returns a fallback Generic Product so the
    // offline-first flow is never broken, even without internet.
    ProductEntity? remoteProduct;
    try {
      remoteProduct = await _remoteDataSource.fetchProductByBarcode(productBarcode);
    } on NetworkTimeoutException {
      return _buildGenericProduct(productBarcode);
    } on ServerException {
      return _buildGenericProduct(productBarcode);
    } catch (_) {
      return _buildGenericProduct(productBarcode);
    }

    if (remoteProduct == null) {
      // Product simply not found on OFF — let the caller deal with it cleanly.
      throw Exception('Product "$productBarcode" was not found on Open Food Facts.');
    }

    // ── Step 3: Persist to local DB before returning (Read-Through Cache) ───
    final saveToLocal = () => _localDataSource.insertProduct(remoteProduct!);
    await saveToLocal();

    return remoteProduct;
  }

  /// Creates a minimal named placeholder so the user can still log the item
  /// offline and enrich it later (name, brand, macros).
  ProductEntity _buildGenericProduct(String barcode) {
    return ProductEntity(
      barcode: barcode,
      name: 'Generic Product ($barcode)',
    );
  }
}
