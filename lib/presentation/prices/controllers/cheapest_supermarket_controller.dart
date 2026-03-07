import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'price_history_controller.dart';

part 'cheapest_supermarket_controller.g.dart';

class CheapestPriceModel {
  final String supermarketName;
  final double lowestPrice;

  const CheapestPriceModel({
    required this.supermarketName,
    required this.lowestPrice,
  });
}

@riverpod
CheapestPriceModel? cheapestSupermarket(
  CheapestSupermarketRef ref,
  String barcode,
) {
  final historyAsync = ref.watch(rawPriceHistoryProvider(barcode));

  return historyAsync.whenOrNull(
    data: (history) {
      if (history.isEmpty) {
        return null;
      }

      final cheapestRecord = history.reduce(
        (current, next) => current.price < next.price ? current : next,
      );

      return CheapestPriceModel(
        supermarketName: cheapestRecord.supermarketName,
        lowestPrice: cheapestRecord.price,
      );
    },
  );
}
