import 'package:riverpod/riverpod.dart';
import 'infrastructure_providers.dart';

// Adjust these imports based on your actual data source implementations layer
import '../../data/datasources/local/local_product_data_source.dart';
import '../../data/datasources/remote/open_food_facts_data_source.dart';
import '../../data/datasources/local/local_pantry_data_source.dart';
import '../../data/datasources/local/local_price_data_source.dart';

final localProductDataSourceProvider = Provider<LocalProductDataSource>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return LocalProductDataSource(db.productDao);
});

final remoteProductDataSourceProvider = Provider<OpenFoodFactsDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return OpenFoodFactsDataSource(dio);
});

final localPantryDataSourceProvider = Provider<LocalPantryDataSource>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return LocalPantryDataSource(db.pantryDao);
});

final localPriceDataSourceProvider = Provider<LocalPriceDataSource>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return LocalPriceDataSource(db.priceDao);
});
