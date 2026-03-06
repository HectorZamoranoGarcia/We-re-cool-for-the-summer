import '../../../domain/entities/product_entity.dart';

abstract class RemoteProductDataSource {
  Future<ProductEntity?> fetchProductByBarcode(String barcode);
}
