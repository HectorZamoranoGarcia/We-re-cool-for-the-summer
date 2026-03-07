import 'package:drift/drift.dart';

import 'sync_status.dart';

/// Enum representing major European retailers.
/// Drift maps this to an integer natively.
enum Supermarket {
  mercadona,
  lidl,
  carrefour,
  aldi,
  consum,
  spar,
  auchan,
  other
}

@DataClassName('Product')
class Products extends Table {
  TextColumn get barcode => text()();
  TextColumn get name => text()();
  TextColumn get brand => text().nullable()();
  TextColumn get imageUrl => text().nullable()();

  // Macronutrients (Per 100g/ml)
  RealColumn get caloriesPer100g => real().nullable()();
  RealColumn get proteinPer100g => real().nullable()();
  RealColumn get carbsPer100g => real().nullable()();
  RealColumn get fatsPer100g => real().nullable()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {barcode};
}

@DataClassName('PriceRecord')
class PriceRecords extends Table {
  IntColumn get id => integer().autoIncrement()();

  // Referential Integrity: Deleting a product cascades down to its prices.
  TextColumn get productBarcode => text().references(
        Products,
        #barcode,
        onDelete: KeyAction.cascade,
      )();

  // Maps the Dart Enum transparently to a database INT
  IntColumn get supermarketTag => intEnum<Supermarket>()();

  RealColumn get price => real()();
  TextColumn get currency => text().withDefault(const Constant('EUR'))();
  DateTimeColumn get recordedAt => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('PantryItem')
class PantryItems extends Table {
  IntColumn get id => integer().autoIncrement()();

  // Referential Integrity: Deleting a product purges it from the pantry.
  TextColumn get productBarcode => text().references(
        Products,
        #barcode,
        onDelete: KeyAction.cascade,
      )();

  // Metric tracking (Advanced UX for Recipe Engine)
  RealColumn get grams => real().withDefault(const Constant(100.0))();

  DateTimeColumn get addedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get expirationDate => dateTime().nullable()();

  // Supports FIFO logic
  BoolColumn get isConsumed => boolean().withDefault(const Constant(false))();

  // ── Hybrid-Sync columns ──────────────────────────────────────────────────
  // The UUID of the Supabase user who owns this record.
  // Null for items added before the user logs in (offline-first guest mode).
  TextColumn get userId => text().nullable()();

  // ISO-8601 timestamp updated on every local write.
  // The cloud sync engine uses this for Last-Write-Wins conflict resolution.
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  // Tracks whether this row needs to be pushed / deleted from Supabase.
  // Maps to [SyncStatus] via intEnum (0=synced, 1=pending_insert, etc.)
  IntColumn get syncStatus =>
      intEnum<SyncStatus>().withDefault(const Constant(1))()
  ; // Default = pendingInsert so offline items are queued for sync on login
}
