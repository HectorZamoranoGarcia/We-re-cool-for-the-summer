import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/di/repository_providers.dart';
import '../../../../domain/entities/product_entity.dart';

part 'scanner_controller.g.dart';

/// Sealed state machine for the barcode scanning flow.
sealed class ScannerState {
  const ScannerState();
}

/// No active scan in progress – camera is live.
class ScannerIdle extends ScannerState {
  const ScannerIdle();
}

/// A barcode has been read; now resolving from cache or remote.
class ScannerLoadingProduct extends ScannerState {
  final String productBarcode;
  const ScannerLoadingProduct(this.productBarcode);
}

/// Product resolved successfully (may be a generic placeholder if offline).
class ScannerSuccess extends ScannerState {
  final ProductEntity product;
  /// True when the product was found in the local Drift cache.
  final bool isCacheHit;

  const ScannerSuccess({required this.product, required this.isCacheHit});
}

/// An unrecoverable error occurred (product not found on OFF and not cached).
class ScannerError extends ScannerState {
  final String message;
  const ScannerError(this.message);
}

@riverpod
class ScannerController extends _$ScannerController {
  @override
  ScannerState build() => const ScannerIdle();

  Future<void> processBarcode(String productBarcode) async {
    if (state is ScannerLoadingProduct) return; // already in flight

    state = ScannerLoadingProduct(productBarcode);

    try {
      final repository = ref.read(productRepositoryProvider);

      // The repository runs:
      //   Step 1 – Drift cache look-up (isCacheHit)
      //   Step 2 – OFF API fetch (remoteProduct)
      //   Step 3 – saveToLocal() before returning
      // On network error it returns a Generic Product; never throws.
      final product = await repository.getOrFetchProduct(productBarcode);

      // Determine if this was a cache hit by checking whether OFF data is rich
      // (a generic placeholder has no calories/brand registered).
      final isCacheHit = product.brand != null || product.caloriesPer100g != null;

      state = ScannerSuccess(product: product, isCacheHit: isCacheHit);
    } catch (e) {
      state = ScannerError(e.toString());
    }
  }

  void reset() => state = const ScannerIdle();
}
