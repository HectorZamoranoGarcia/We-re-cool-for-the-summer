import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

import 'daos/pantry_dao.dart';
import 'daos/price_dao.dart';
import 'daos/product_dao.dart';
import 'sync_status.dart';
import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [Products, PriceRecords, PantryItems],
  daos: [ProductDao, PantryDao, PriceDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        await _seedDummyData();
      },
      beforeOpen: (details) async {
        // Enable foreign-key enforcement for referential integrity.
        await customStatement('PRAGMA foreign_keys = ON');
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 3) {
          // v2 -> v3: Add hybrid-sync columns to pantry_items.
          await m.addColumn(pantryItems, pantryItems.userId);
          await m.addColumn(pantryItems, pantryItems.updatedAt);
          await m.addColumn(pantryItems, pantryItems.syncStatus);
        }
      },
    );
  }

  Future<void> _seedDummyData() async {
    final now = DateTime.now();

    // 1. DUMMY PRODUCTS
    final p1 = ProductsCompanion.insert(
      barcode: '8480000165039',
      name: 'Chicken Breast (Pechuga)',
      brand: const Value('Hacendado'),
      imageUrl: const Value('https://images.openfoodfacts.org/images/products/848/000/016/5039/front_es.12.400.jpg'),
      caloriesPer100g: const Value(110),
      proteinPer100g: const Value(23.0),
      carbsPer100g: const Value(0.0),
      fatsPer100g: const Value(2.0),
    );

    final p2 = ProductsCompanion.insert(
      barcode: '8412854000305',
      name: 'Almond Milk (Zero Sugar)',
      brand: const Value('Alpro'),
      imageUrl: const Value('https://images.openfoodfacts.org/images/products/841/285/400/0305/front_es.41.400.jpg'),
      caloriesPer100g: const Value(13),
      proteinPer100g: const Value(0.4),
      carbsPer100g: const Value(0.0),
      fatsPer100g: const Value(1.1),
    );

    final p3 = ProductsCompanion.insert(
      barcode: '4056489148002',
      name: 'Avocado 500g',
      brand: const Value('Lidl Nature'),
      caloriesPer100g: const Value(160),
      proteinPer100g: const Value(2.0),
      carbsPer100g: const Value(8.5),
      fatsPer100g: const Value(14.7),
    );

    final p4 = ProductsCompanion.insert(
      barcode: '8480017042835',
      name: 'Oatmeal (Copos de Avena)',
      brand: const Value('Consum'),
      caloriesPer100g: const Value(370),
      proteinPer100g: const Value(14.0),
      carbsPer100g: const Value(59.0),
      fatsPer100g: const Value(7.0),
    );

    await batch((b) {
      b.insertAll(products, [p1, p2, p3, p4]);

      // 2. DUMMY PRICE RECORDS (Creating price trends and cheapest comparisons)
      // Chicken Breast Prices
      b.insertAll(priceRecords, [
        PriceRecordsCompanion.insert(productBarcode: p1.barcode.value, supermarketTag: Supermarket.mercadona, price: 6.50, recordedAt: Value(now.subtract(const Duration(days: 14)))),
        PriceRecordsCompanion.insert(productBarcode: p1.barcode.value, supermarketTag: Supermarket.mercadona, price: 6.90, recordedAt: Value(now.subtract(const Duration(days: 7)))),
        PriceRecordsCompanion.insert(productBarcode: p1.barcode.value, supermarketTag: Supermarket.mercadona, price: 7.10, recordedAt: Value(now)), // Trend Up
        PriceRecordsCompanion.insert(productBarcode: p1.barcode.value, supermarketTag: Supermarket.lidl, price: 5.95, recordedAt: Value(now)), // Cheapest!
      ]);

      // Almond Milk Prices
      b.insertAll(priceRecords, [
        PriceRecordsCompanion.insert(productBarcode: p2.barcode.value, supermarketTag: Supermarket.carrefour, price: 2.15, recordedAt: Value(now.subtract(const Duration(days: 30)))),
        PriceRecordsCompanion.insert(productBarcode: p2.barcode.value, supermarketTag: Supermarket.carrefour, price: 1.99, recordedAt: Value(now.subtract(const Duration(days: 10)))),
        PriceRecordsCompanion.insert(productBarcode: p2.barcode.value, supermarketTag: Supermarket.consum, price: 2.20, recordedAt: Value(now)),
      ]);

      // Avocado Prices
      b.insertAll(priceRecords, [
        PriceRecordsCompanion.insert(productBarcode: p3.barcode.value, supermarketTag: Supermarket.lidl, price: 2.49, recordedAt: Value(now.subtract(const Duration(days: 5)))),
        PriceRecordsCompanion.insert(productBarcode: p3.barcode.value, supermarketTag: Supermarket.aldi, price: 2.29, recordedAt: Value(now)),
      ]);

      // 3. DUMMY PANTRY ITEMS (Testing FIFO Expiration colors)
      b.insertAll(pantryItems, [
        // Chicken - Expires TOMORROW (Critical - Red)
        PantryItemsCompanion.insert(productBarcode: p1.barcode.value, grams: const Value(500.0), expirationDate: Value(now.add(const Duration(days: 1)))),
        // Chicken - Consumed Already (Greyed out)
        PantryItemsCompanion.insert(productBarcode: p1.barcode.value, grams: const Value(250.0), isConsumed: const Value(true), expirationDate: Value(now.subtract(const Duration(days: 2)))),

        // Almond Milk - Expires in 4 Days (Urgent - Amber)
        PantryItemsCompanion.insert(productBarcode: p2.barcode.value, grams: const Value(1000.0), expirationDate: Value(now.add(const Duration(days: 4)))),
        // Almond Milk - Expires in 20 days (Safe - Green)
        PantryItemsCompanion.insert(productBarcode: p2.barcode.value, grams: const Value(1000.0), expirationDate: Value(now.add(const Duration(days: 20)))),

        // Avocado - No expiration Date (Safe/Neutral)
        PantryItemsCompanion.insert(productBarcode: p3.barcode.value, grams: const Value(300.0)),

        // Oatmeal - Safe completely
        PantryItemsCompanion.insert(productBarcode: p4.barcode.value, grams: const Value(2000.0), expirationDate: Value(now.add(const Duration(days: 180)))),
      ]);
    });
  }
}

/// Opens a [LazyDatabase] so that all real file I/O is deferred until
/// the first Drift query is executed, which Drift dispatches on a
/// background isolate via [NativeDatabase.createInBackground].
///
/// This keeps the Dart main thread completely free during app startup,
/// preventing the "Skipped N frames" jank caused by blocking I/O on the
/// main thread.
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    // The Android sqlite3 workaround MUST run before the native library
    // is touched for the first time, so it belongs here inside the lazy
    // closure (which executes on a background isolate on first use).
    if (Platform.isAndroid) {
      await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
    }

    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'pantry_pro.sqlite'));

    // Creates the database on a separate Dart isolate to avoid any risk
    // of blocking the UI thread during schema creation or migrations.
    return NativeDatabase.createInBackground(file);
  });
}
