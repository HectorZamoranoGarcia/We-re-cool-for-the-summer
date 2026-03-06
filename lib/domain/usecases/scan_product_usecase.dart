import '../entities/product_entity.dart';
import '../repositories/i_product_repository.dart';

class ScanProductUseCase {
  final IProductRepository _productRepository;

  const ScanProductUseCase(this._productRepository);

  Future<ProductEntity> execute(String barcode) async {
    if (barcode.trim().isEmpty) {
      throw ArgumentError('Barcode cannot be empty');
    }
    return _productRepository.getOrFetchProduct(barcode.trim());
  }
}
