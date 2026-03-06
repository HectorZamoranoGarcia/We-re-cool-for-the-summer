import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables.dart';

part 'product_dao.g.dart';



@DriftAccessor(tables: [Products])
class ProductDao extends DatabaseAccessor<AppDatabase>
    with _$ProductDaoMixin {
  ProductDao(super.db);

  @override
  Future<void> insertProduct(ProductsCompanion product) async {
    await into(products).insert(product, mode: InsertMode.replace);
  }

  @override
  Future<Product?> getProductByBarcode(String barcode) async {
    return (select(products)..where((tbl) => tbl.barcode.equals(barcode)))
        .getSingleOrNull();
  }
}
