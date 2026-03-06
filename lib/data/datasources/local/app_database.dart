import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

import 'daos/pantry_dao.dart';
import 'daos/price_dao.dart';
import 'daos/product_dao.dart';
import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [Products, Supermarkets, PriceRecords, PantryItems],
  daos: [ProductDao, PantryDao, PriceDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        // Seed the database with core European chains upon first creation.
        await _seedSupermarkets();
      },
      beforeOpen: (details) async {
        // Enable foreign-key enforcement for referential integrity.
        await customStatement('PRAGMA foreign_keys = ON');
      },
    );
  }

  Future<void> _seedSupermarkets() async {
    final List<SupermarketsCompanion> initialChains = [
      const SupermarketsCompanion(
        name: Value('Consum'),
        countryCode: Value('ES'),
        iconAssetPath: Value('assets/icons/consum.png'),
      ),
      const SupermarketsCompanion(
        name: Value('Rewe'),
        countryCode: Value('DE'),
        iconAssetPath: Value('assets/icons/rewe.png'),
      ),
      const SupermarketsCompanion(
        name: Value('Aldi'),
        countryCode: Value('DE'),
        iconAssetPath: Value('assets/icons/aldi.png'),
      ),
      const SupermarketsCompanion(
        name: Value('Lidl'),
        countryCode: Value('DE'),
        iconAssetPath: Value('assets/icons/lidl.png'),
      ),
      const SupermarketsCompanion(
        name: Value('Carrefour'),
        countryCode: Value('FR'),
        iconAssetPath: Value('assets/icons/carrefour.png'),
      ),
    ];

    await batch((batch) {
      batch.insertAll(supermarkets, initialChains);
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
