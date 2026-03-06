// ignore_for_file: lines_longer_than_80_chars

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:app_comidas/src/core/database/database_manager.dart';
import 'package:app_comidas/src/domain/domain.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  tearDown(() async {
    await DatabaseManager.instance.close();
  });

  group('Domain Repositories Integration', () {
    late Database db;
    late ProductRepository productRepo;
    late SupermarketRepository supermarketRepo;
    late PriceRecordRepository priceRepo;
    late PantryItemRepository pantryRepo;

    setUp(() async {
      await DatabaseManager.instance.close();
      db = await DatabaseManager.instance.database;
      productRepo = ProductRepository(db);
      supermarketRepo = SupermarketRepository(db);
      priceRepo = PriceRecordRepository(db);
      pantryRepo = PantryItemRepository(db);
    });

    test('Full CRUD cycle for Supermarket', () async {
      final supermarket = Supermarket(
        id: 0, // Ignored by auto-increment on insert
        name: 'Mercadona',
        countryCode: 'ES',
        iconAssetPath: 'assets/icons/mercadona.png',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final int id = await supermarketRepo.insertSupermarket(supermarket);
      expect(id, isPositive);

      final fetched = await supermarketRepo.findSupermarketById(id);
      expect(fetched, isNotNull);
      expect(fetched!.name, 'Mercadona');

      await supermarketRepo.updateSupermarket(fetched.copyWith(name: 'Mercadona Express'));
      final updated = await supermarketRepo.findSupermarketById(id);
      expect(updated!.name, 'Mercadona Express');

      await supermarketRepo.deleteSupermarket(id);
      final deleted = await supermarketRepo.findSupermarketById(id);
      expect(deleted, isNull);
    });

    test('Full CRUD cycle for Product with Nutrition Data', () async {
      final product = Product(
        barcode: '8480000123456',
        name: 'Leche Entera',
        brand: 'Hacendado',
        caloriesPer100g: 65.0,
        proteinPer100g: 3.1,
        carbsPer100g: 4.8,
        fatsPer100g: 3.6,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await productRepo.insertProduct(product);

      final fetched = await productRepo.findProductByBarcode('8480000123456');
      expect(fetched, isNotNull);
      expect(fetched!.name, 'Leche Entera');
      expect(fetched.caloriesPer100g, 65.0);

      await productRepo.updateProduct(fetched.copyWith(brand: 'Hacendado Premium'));
      final updated = await productRepo.findProductByBarcode('8480000123456');
      expect(updated!.brand, 'Hacendado Premium');

      await productRepo.deleteProduct('8480000123456');
      final deleted = await productRepo.findProductByBarcode('8480000123456');
      expect(deleted, isNull);
    });

    test('Cascading Delete: Deleting a Product removes its PriceRecords and PantryItems', () async {
      // 1. Setup Parent Entities
      final int smId = await supermarketRepo.insertSupermarket(Supermarket(
        id: 0,
        name: 'Eroski',
        countryCode: 'ES',
        iconAssetPath: 'assets/icons/eroski.png',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));

      final product = Product(
        barcode: '1111111111111',
        name: 'Test Product',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await productRepo.insertProduct(product);

      // 2. Setup Child Entities
      final priceId = await priceRepo.insertPriceRecord(PriceRecord(
        id: 0,
        productBarcode: product.barcode,
        supermarketId: smId,
        price: 2.50,
        currency: 'EUR',
        recordedAt: DateTime.now(),
        createdAt: DateTime.now(),
      ));

      final pantryId = await pantryRepo.insertPantryItem(PantryItem(
        id: 0,
        productBarcode: product.barcode,
        quantity: 2,
        addedAt: DateTime.now(),
        isConsumed: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));

      // Assert children exist
      expect((await priceRepo.fetchPriceHistoryForProduct(product.barcode)).length, 1);
      final pantryItemsPre = await pantryRepo.fetchAllPantryItems();
      expect(pantryItemsPre.any((p) => p.id == pantryId), isTrue);

      // 3. Act: Delete Product
      await productRepo.deleteProduct(product.barcode);

      // 4. Assert Cascading Deletes
      final priceHistoryPost = await priceRepo.fetchPriceHistoryForProduct(product.barcode);
      expect(priceHistoryPost, isEmpty); // Should be cascade deleted

      final pantryItemsPost = await pantryRepo.fetchAllPantryItems();
      expect(pantryItemsPost.any((p) => p.id == pantryId), isFalse); // Cascade deleted
    });
  });
}
