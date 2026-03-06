import 'package:drift/drift.dart';

@DataClassName('Product')
class Products extends Table {
  TextColumn get barcode => text()();
  TextColumn get name => text()();
  TextColumn get brand => text().nullable()();
  TextColumn get imageUrl => text().nullable()();
  RealColumn get caloriesPer100g => real().nullable()();
  RealColumn get proteinPer100g => real().nullable()();
  RealColumn get carbsPer100g => real().nullable()();
  RealColumn get fatsPer100g => real().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {barcode};
}

@DataClassName('Supermarket')
class Supermarkets extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();
  TextColumn get countryCode => text()();
  TextColumn get iconAssetPath => text()();
}

@DataClassName('PriceRecord')
class PriceRecords extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get productBarcode => text().references(Products, #barcode)();
  IntColumn get supermarketId => integer().references(Supermarkets, #id)();
  RealColumn get price => real()();
  TextColumn get currency => text().withDefault(const Constant('EUR'))();
  DateTimeColumn get recordedAt => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('PantryItem')
class PantryItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get productBarcode => text().references(Products, #barcode)();
  IntColumn get quantity => integer().withDefault(const Constant(1))();
  DateTimeColumn get addedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get expirationDate => dateTime().nullable()();
  BoolColumn get isConsumed => boolean().withDefault(const Constant(false))();
}
