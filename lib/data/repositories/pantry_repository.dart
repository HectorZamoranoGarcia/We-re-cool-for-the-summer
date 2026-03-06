import '../../domain/entities/pantry_item_entity.dart';
import '../../domain/repositories/i_pantry_repository.dart';
import '../datasources/local/local_pantry_data_source.dart';

class PantryRepository implements IPantryRepository {
  final LocalPantryDataSource _localDataSource;

  PantryRepository(this._localDataSource);

  @override
  Future<void> addPantryItem(PantryItemEntity item) async {
    await _localDataSource.addPantryItem(item);
  }

  @override
  Future<void> consumePantryItem(int id) async {
    await _localDataSource.consumePantryItem(id);
  }

  @override
  Stream<List<PantryItemEntity>> watchActiveInventory() {
    return _localDataSource.watchActiveInventory();
  }

  @override
  Stream<List<PantryItemEntity>> watchExpiringSoon() {
    return _localDataSource.watchExpiringSoon();
  }
}
