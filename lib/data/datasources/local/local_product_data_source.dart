import 'package:drift/drift.dart';

import '../../../domain/entities/product_entity.dart';
import 'app_database.dart';
import 'daos/product_dao.dart';

class LocalProductDataSource {
  final ProductDao _productDao;

  LocalProductDataSource(this._productDao);

  Future<void> insertProduct(ProductEntity product) async {
    final companion = ProductsCompanion(
      barcode: Value(product.barcode),
      name: Value(product.name),
      brand: Value(product.brand),
      imageUrl: Value(product.imageUrl),
      caloriesPer100g: Value(product.caloriesPer100g),
      proteinPer100g: Value(product.proteinPer100g),
      carbsPer100g: Value(product.carbsPer100g),
      fatsPer100g: Value(product.fatsPer100g),
    );
    await _productDao.insertProduct(companion);
  }

  Future<ProductEntity?> getProductByBarcode(String barcode) async {
    final productRow = await _productDao.getProductByBarcode(barcode);
    if (productRow == null) return null;

    return ProductEntity(
      barcode: productRow.barcode,
      name: productRow.name,
      brand: productRow.brand,
      imageUrl: productRow.imageUrl,
      caloriesPer100g: productRow.caloriesPer100g,
      proteinPer100g: productRow.proteinPer100g,
      carbsPer100g: productRow.carbsPer100g,
      fatsPer100g: productRow.fatsPer100g,
    );
  }
}
