import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'price_history_controller.dart';

part 'cheapest_supermarket_controller.g.dart';

class CheapestPriceModel {
  final int supermarketId;
  final double lowestPrice;

  const CheapestPriceModel({
    required this.supermarketId,
    required this.lowestPrice,
  });
}

@riverpod
CheapestPriceModel? cheapestSupermarket(
  CheapestSupermarketRef ref,
  String barcode,
) {
  final historyAsync = ref.watch(priceHistoryProvider(barcode));

  return historyAsync.whenOrNull(
    data: (history) {
      if (history.isEmpty) {
        return null;
      }

      final cheapestRecord = history.reduce(
        (current, next) => current.price < next.price ? current : next,
      );

      return CheapestPriceModel(
        supermarketId: cheapestRecord.supermarketId,
        lowestPrice: cheapestRecord.price,
      );
    },
  );
}
