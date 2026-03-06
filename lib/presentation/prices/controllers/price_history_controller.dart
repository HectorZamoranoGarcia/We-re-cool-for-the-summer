import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../domain/entities/price_record_entity.dart';
import '../../../core/di/repository_providers.dart';

part 'price_history_controller.g.dart';

@riverpod
Stream<List<PriceRecordEntity>> priceHistory(
  PriceHistoryRef ref,
  String barcode,
) {
  final repository = ref.watch(priceRepositoryProvider);
  return repository.watchPriceHistory(barcode);
}
